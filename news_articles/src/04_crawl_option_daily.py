"""
下载 三油两粕 期权日线数据并写入 Supabase 表 public.option_daily。
数据来源：akshare（新浪财经商品期权分支 option_commodity_*_sina），因大商所/郑商所官网
被 WAF 拦截（412 JS 挑战），无法走 option_hist_dce/czce，故采用新浪路径。
覆盖品种（新浪支持名）：
    豆粕期权 -> 豆粕期权
    豆油期权 -> 豆油期权
    菜油期权 -> 菜籽油期权
    菜粕期权 -> 菜籽粕期权
    棕榈油期权 -> 新浪未收录，暂缺（需后续用交易所/付费源补齐）
合约范围：每个品种的全部看涨/看跌期权合约（全部行权价）。
时间范围：2026-07-01 起（含）至今。
"""
import os
import re
import sys
import time
import socket
import random
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed
import psycopg2
import akshare as ak
from datetime import date
from pathlib import Path

# 安全网：所有网络请求最多 25s 超时，避免无超时的请求在后台无限挂起
socket.setdefaulttimeout(25)

DATABASE_URL = os.environ["DATABASE_URL"]
START = date(2026, 7, 1)
BASE_DIR = Path(__file__).resolve().parents[1]
LOG_DIR = BASE_DIR / "logs"
LOG_DIR.mkdir(exist_ok=True)
LOG = logging.getLogger("option_daily")
# 新浪接口有访问频率限制。4 个并发连接将原本逐个等待的合约请求缩短为约 1/4，
# 同时仍保留每个请求的重试机制；可用 OPTION_WORKERS=1 临时退回串行。
OPTION_WORKERS = max(1, min(int(os.environ.get("OPTION_WORKERS", "4")), 6))

# 用户想要的品种 -> akshare/新浪实际品种名
VARIETY_MAP = {
    "豆粕期权": "豆粕期权",
    "豆油期权": "豆油期权",
    "菜油期权": "菜籽油期权",
    "菜粕期权": "菜籽粕期权",
    # "棕榈油期权": "棕榈油期权",  # 新浪未收录，跳过
}

CODE_RE = re.compile(r"^([a-z]+\d+)([CP])(\d+)$")


def enumerate_codes(variety_sina: str):
    """返回 [(symbol, type, underlying, strike), ...]"""
    out = []
    try:
        unders = ak.option_commodity_contract_sina(symbol=variety_sina)["合约"].tolist()
    except Exception as e:
        print(f"  [WARN] contract_sina failed {variety_sina}: {e}")
        return out
    for u in unders:
        try:
            tbl = ak.option_commodity_contract_table_sina(symbol=variety_sina, contract=u)
            calls = tbl["看涨合约-看涨期权合约"].dropna().tolist()
            puts = tbl["看跌合约-看跌期权合约"].dropna().tolist()
        except Exception as e:
            print(f"  [WARN] table failed {variety_sina}/{u}: {e}")
            calls, puts = [], []
        time.sleep(0.25)
        for code in calls + puts:
            m = CODE_RE.match(str(code).strip())
            if not m:
                continue
            out.append((code, m.group(2), m.group(1), int(m.group(3))))
    return out


def fetch_history(code: str):
    """返回该合约 2026-07-01 起的日线行 [(trade_date, o, h, l, c, v), ...]"""
    for attempt in range(3):
        try:
            df = ak.option_commodity_hist_sina(symbol=code)
            rows = []
            for _, r in df.iterrows():
                d = r["date"]
                if isinstance(d, str):
                    d = date.fromisoformat(d[:10])
                if d < START:
                    continue
                rows.append((
                    d,
                    float(r["open"]) if r["open"] == r["open"] else None,
                    float(r["high"]) if r["high"] == r["high"] else None,
                    float(r["low"]) if r["low"] == r["low"] else None,
                    float(r["close"]) if r["close"] == r["close"] else None,
                    int(float(r["volume"])) if r["volume"] == r["volume"] else 0,
                ))
            return rows
        except Exception as e:
            if attempt < 2:
                time.sleep(0.5 + random.random())
            else:
                print(f"  [WARN] hist failed {code}: {e}")
    return []


def upsert(rows):
    """每次用全新连接、execute_values 真批量写入（单条多值 INSERT），避免逐行 round-trip 卡死。"""
    from psycopg2.extras import execute_values
    sql = """
    INSERT INTO public.option_daily
      (variety, symbol, option_type, underlying, strike, trade_date,
       "open", high, low, close, volume)
    VALUES %s
    ON CONFLICT (symbol, trade_date) DO UPDATE SET
       "open"=EXCLUDED."open", high=EXCLUDED.high, low=EXCLUDED.low,
       close=EXCLUDED.close, volume=EXCLUDED.volume, updated_at=now()
    """
    n = 0
    try:
        with psycopg2.connect(DATABASE_URL) as conn:
            with conn.cursor() as cur:
                cur.execute("SET statement_timeout=60000")
                execute_values(cur, sql, rows, page_size=500)
            conn.commit()
        n = len(rows)
    except Exception as e:
        print(f"  [ERROR] upsert failed: {e}")
        raise
    return n


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[
            logging.FileHandler(LOG_DIR / f"option_daily_{date.today().isoformat()}.log", encoding="utf-8"),
            logging.StreamHandler(),
        ],
    )
    dry = "--dry" in sys.argv
    total = 0
    LOG.info("=== option daily update START (workers=%d) ===", OPTION_WORKERS)
    for variety, sina_name in VARIETY_MAP.items():
        t0 = time.time()
        codes = enumerate_codes(sina_name)
        print(f"\n[{variety}] ({sina_name}) 合约数={len(codes)}")
        rows = []
        # 同一品种内并发抓取、在主线程汇总，避免共享数据库连接。
        with ThreadPoolExecutor(max_workers=OPTION_WORKERS, thread_name_prefix="option") as pool:
            future_meta = {
                pool.submit(fetch_history, sym): (sym, otype, underlying, strike)
                for sym, otype, underlying, strike in codes
            }
            for i, future in enumerate(as_completed(future_meta), 1):
                sym, otype, underlying, strike = future_meta[future]
                try:
                    hist = future.result()
                except Exception as exc:  # 单个合约失败不阻断当日其它合约
                    LOG.warning("history worker failed %s: %s", sym, exc)
                    hist = []
                rows.extend(
                    (variety, sym, otype, underlying, strike, d, o, h, l, c, v)
                    for d, o, h, l, c, v in hist
                )
                if i % 50 == 0 or i == len(codes):
                    LOG.info("[%s] processed %d/%d contracts, rows=%d", variety, i, len(codes), len(rows))
        print(f"[{variety}] 抓取行数={len(rows)}  用时 {time.time()-t0:.1f}s")
        if dry:
            if rows:
                print("  sample:", rows[0])
            continue
        n = upsert(rows)
        total += n
        print(f"[{variety}] 已写入 {n} 行")
    LOG.info("=== option daily update DONE. total rows=%d ===", total)
    print(f"\nDONE. 总写入行数={total}")


if __name__ == "__main__":
    main()
