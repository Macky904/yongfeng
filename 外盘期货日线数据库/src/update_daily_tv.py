"""外盘期货日线数据库 — 从 TradingView 免费行情(游客 WS)每日增量更新。

对 public.futures_kline_daily 中每个已有 contract_code（= TradingView 符号，如
CBOT:ZC1! / CBOT:ZSQ2026）：
  1) 拉最近 ~45 根 1D 日线（无需登录，wss://data.tradingview.com）
  2) 只接受北京时间上一完整交易日及更早的日线，绝不把仍在交易的
     "当天日线"作为正式收盘数据写入
  3) 次日抓取时回补 / 覆盖上一完整交易日，修正此前意外提前运行时可能
     写入的盘中日线
  4) 末尾窗口函数重算 MA5/10/20/30（CTE 在全表算窗口，只 UPDATE 近窗行，不破坏历史）
日志写入 <项目根>/logs/update_daily_tv_YYYY-MM-DD.log。

依赖：websocket-client, psycopg2, pandas(可选)。连接串取环境变量 DATABASE_URL。
"""
import json
import logging
import os
import random
import re
import string
import sys
import time
from datetime import datetime, timezone, timedelta
from pathlib import Path

import psycopg2
from websocket import create_connection

BASE_DIR = Path(__file__).resolve().parents[1]
LOGS = BASE_DIR / "logs"
LOGS.mkdir(exist_ok=True)
BEIJING_TZ = timezone(timedelta(hours=8))

WS = "wss://data.tradingview.com/socket.io/websocket"
RE = re.compile(r"~m~(\d+)~m~")

N_BARS = 45           # 每次拉取的日线根数（覆盖任何漏跑间隙，含周末/假期）
MA_RECENT_DAYS = 45   # MA 重算的近窗天数（> ma30 缓冲）

# 速率限制保护：TradingView 免费游客端对短时间内的请求数有限制，
# 突发请求约 30+ 笔后会对新连接返回 10060 超时。以下参数用于"慢一点、失败快退避"。
WS_TIMEOUT = 10            # 单笔 WS 连接超时(秒)，超时即视为被限流 -> 快速失败而非干等
RETRY_SLEEP = 2            # 单次重试间隔(秒)
INTER_DELAY = (2.0, 3.5)  # 合约之间的随机间隔(秒下限,上限)，拉开请求节奏避限流
COOLDOWN_AFTER = 3         # 连续失败达到此次数 -> 整段冷却
COOLDOWN_SEC = 45          # 冷却时长(秒)，让限流窗口过去

log = logging.getLogger("update_daily_tv")


# ---------------- TradingView 游客客户端 ----------------
def _pf(m):
    return f"~m~{len(m)}~m~{m}"


def _parse(s):
    out = []
    for L in map(int, RE.findall(s)):
        s = s.lstrip(f"~m~{L}~m~")
        b = s[:L]
        s = s[L:]
        if not b.startswith("h"):
            try:
                out.append(json.loads(b))
            except Exception:
                pass
    return out


def fetch_tv(symbol: str, interval: str = "1D", n_bars: int = N_BARS, retries: int = 3):
    """返回 [(bar_time_sec, o, h, l, c, vol), ...]。失败返回 []。"""
    last_err = None
    for attempt in range(1, retries + 1):
        ws = None
        try:
            ws = create_connection(WS, timeout=WS_TIMEOUT, header={"Origin": "https://www.tradingview.com"})
            cs = "cs_" + "".join(random.choice(string.ascii_letters) for _ in range(12))
            ws.send(_pf(json.dumps({"m": "chart_create_session", "p": [cs, ""]})))
            ws.send(_pf(json.dumps({
                "m": "resolve_symbol",
                "p": [cs, "sds_sym_1",
                      '={"symbol":"%s","adjustment":"splits","session":"extended"}' % symbol],
            })))
            ws.send(_pf(json.dumps({
                "m": "create_series", "p": [cs, "s1", "s1", "sds_sym_1", interval, n_bars, ""],
            })))
            bars, t0 = [], time.time()
            while time.time() - t0 < 40:
                try:
                    raw = ws.recv()
                except Exception:
                    break
                for r in _parse(raw):
                    if r.get("m") == "series_completed":
                        try:
                            ws.close()
                        except Exception:
                            pass
                        return bars
                    if r.get("m") == "timescale_update":
                        for k, v in r["p"][1].items():
                            for x in v.get("s", []):
                                bars.append(tuple(x["v"]))
            try:
                ws.close()
            except Exception:
                pass
            return bars
        except Exception as exc:  # noqa: BLE001
            last_err = exc
            log.warning("fetch_tv attempt=%d/%d symbol=%s err=%s", attempt, retries, symbol, exc)
            try:
                if ws:
                    ws.close()
            except Exception:
                pass
            time.sleep(RETRY_SLEEP)
    return None


def previous_business_day(day):
    """返回北京时间的前一工作日。

    这里是统一的报告 / 入库截止口径，而不是把 TradingView 的原始交易日
    标签整体减一天。不同交易所的节假日仍以数据源实际是否返回该日 K 线为准。
    """
    candidate = day - timedelta(days=1)
    while candidate.weekday() >= 5:
        candidate -= timedelta(days=1)
    return candidate


def completed_trade_day(now=None):
    """可写入正式表的最新完整交易日（按北京时间）。"""
    now = now or datetime.now(BEIJING_TZ)
    if now.tzinfo is None:
        now = now.replace(tzinfo=BEIJING_TZ)
    return previous_business_day(now.astimezone(BEIJING_TZ).date())


# ---------------- 主流程 ----------------
def load_contracts(url: str):
    """返回 [(code, ctype, exch, xcode, variety, cmd, symbol_id, dmax), ...]。"""
    with psycopg2.connect(url, connect_timeout=15) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT f.contract_code, f.contract_type, f.exchange, f.exchange_code,
                       f.variety, f.contract_month_date, f.symbol_id,
                       (SELECT max(trade_date) FROM public.futures_kline_daily f2
                        WHERE f2.contract_code = f.contract_code) AS dmax
                FROM (SELECT DISTINCT ON (contract_code) *
                      FROM public.futures_kline_daily
                      ORDER BY contract_code, trade_date DESC) f
                ORDER BY f.contract_code
                """
            )
            return cur.fetchall()


def upsert_contract(url: str, meta, bars, completed_through):
    """写入已完成日线，并回写最近两个完整交易日。

    `trade_date` 始终保留 TradingView 原始日线的交易日标签。`completed_through`
    只决定当次运行最多允许写到哪一天：北京时间 8 月 21 日运行时，最多写入
    8 月 20 日。因而即使有人在 8 月 20 日晚间手动运行，也不会把美国盘中
    的 8 月 20 日日线写入正式库。每次额外回写截止日前一工作日，确保
    网络恢复后的延迟补跑也能覆盖此前可能残留的盘中值。
    """
    code, ctype, exch, xcode, variety, cmd, symbol_id, dmax = meta
    refresh_from = previous_business_day(completed_through)
    new_rows = []
    for b in bars:
        d = datetime.fromtimestamp(b[0], tz=timezone.utc).date()
        if d > completed_through:
            continue
        # 正常只追加新日期；另外总是回写最近两个完整交易日，以便将
        # 早前意外写入的盘中 K 线替换成最终收盘 K 线。若有多日漏跑，
        # 则保留 dmax 之后的全部数据用于补齐。
        if dmax is not None and d <= dmax and d < refresh_from:
            continue
        new_rows.append((
            code, ctype, exch, xcode, variety, d,
            float(b[1]), float(b[2]), float(b[3]), float(b[4]),
            int(b[5]) if b[5] is not None else 0,
            cmd, symbol_id,
        ))
    if not new_rows:
        return 0
    with psycopg2.connect(url, connect_timeout=15) as conn:
        with conn.cursor() as cur:
            # 一个成功返回的日线序列才会触发删除，避免源端临时无数据时误删。
            # 删除回写窗口及其后的旧值，再写入本次经截止日过滤后的结果；这样可
            # 自动清理盘中运行残留的“未来日期”，并修正延迟发现的盘中值。
            cur.execute(
                "DELETE FROM public.futures_kline_daily WHERE contract_code=%s AND trade_date >= %s",
                (code, refresh_from),
            )
            cur.executemany(
                """
                INSERT INTO public.futures_kline_daily
                  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
                   open_price, high_price, low_price, close_price, volume,
                   contract_month_date, symbol_id, created_at, updated_at)
                VALUES (%s,%s,%s,%s,%s,%s, %s,%s,%s,%s,%s, %s,%s, now(), now())
                """,
                new_rows,
            )
        conn.commit()
    return len(new_rows)


def recompute_ma(url: str):
    recent_start = (datetime.now(timezone.utc).date() - timedelta(days=MA_RECENT_DAYS)).isoformat()
    with psycopg2.connect(url, connect_timeout=15) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                WITH ma AS (
                  SELECT id,
                         AVG(close_price) OVER w5  AS ma5,
                         AVG(close_price) OVER w10 AS ma10,
                         AVG(close_price) OVER w20 AS ma20,
                         AVG(close_price) OVER w30 AS ma30
                  FROM public.futures_kline_daily
                  WINDOW w5  AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 4  PRECEDING AND CURRENT ROW),
                         w10 AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 9  PRECEDING AND CURRENT ROW),
                         w20 AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW),
                         w30 AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
                )
                UPDATE public.futures_kline_daily t
                SET ma5=ma.ma5, ma10=ma.ma10, ma20=ma.ma20, ma30=ma.ma30
                FROM ma WHERE t.id = ma.id AND t.trade_date >= %s
                """,
                (recent_start,),
            )
            n = cur.rowcount
        conn.commit()
    return n


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[
            logging.FileHandler(
                LOGS / f"update_daily_tv_{datetime.now(BEIJING_TZ):%Y-%m-%d}.log",
                encoding="utf-8",
            ),
            logging.StreamHandler(),
        ],
    )
    url = os.environ.get("DATABASE_URL")
    if not url:
        log.error("missing_DATABASE_URL = true")
        return 1

    try:
        contracts = load_contracts(url)
    except Exception as exc:  # noqa: BLE001
        log.exception("load_contracts FAILED: %s", exc)
        return 1
    completed_through = completed_trade_day()
    log.info(
        "=== update_daily_tv START: %d contracts; completed_through=%s (Beijing previous business day) ===",
        len(contracts), completed_through,
    )
    total_new = 0
    updated = 0
    failed = []
    consec_fail = 0
    for i, meta in enumerate(contracts, 1):
        code = meta[0]
        try:
            bars = fetch_tv(code)
            if bars is None:                      # 拉取失败（被限流/网络抖动）
                bars = []
                failed.append(code)
                consec_fail += 1
                log.warning("[%d/%d] %s fetch failed (consec=%d)", i, len(contracts), code, consec_fail)
            else:
                consec_fail = 0
                n = upsert_contract(url, meta, bars, completed_through)
                if n > 0:
                    total_new += n
                    updated += 1
                    log.info("[%d/%d] %s +%d rows", i, len(contracts), code, n)
                else:
                    log.info("[%d/%d] %s no new", i, len(contracts), code)
        except Exception as exc:  # noqa: BLE001
            failed.append(code)
            consec_fail += 1
            log.exception("[%d/%d] %s FAILED: %s", i, len(contracts), code, exc)
        # 速率限制保护：连续失败达到阈值 -> 整段冷却，避免无限重试把任务拖到超时
        if consec_fail >= COOLDOWN_AFTER:
            log.warning("连续 %d 个合约失败，疑似触发限流，冷却 %ds ...", consec_fail, COOLDOWN_SEC)
            time.sleep(COOLDOWN_SEC)
            consec_fail = 0
        time.sleep(random.uniform(*INTER_DELAY))
    try:
        ma_n = recompute_ma(url)
        log.info("MA recomputed for %s recent rows", ma_n)
    except Exception as exc:  # noqa: BLE001
        log.exception("MA recompute FAILED: %s", exc)
    log.info("=== DONE: +%d rows across %d contracts; failed=%s ===", total_new, updated, failed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
