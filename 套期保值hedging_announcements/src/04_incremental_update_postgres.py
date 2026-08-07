import importlib.util
import math
import os
import sqlite3
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path

import psycopg2


BASE_DIR = Path(__file__).resolve().parents[1]
SRC_DIR = BASE_DIR / "src"
DATA_DIR = BASE_DIR / "data"
RAW_DB_PATH = DATA_DIR / "raw_cninfo_announcements.sqlite"
BEIJING_TZ = timezone(timedelta(hours=8))


def load_module(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


crawl_mod = load_module(SRC_DIR / "01_crawl_cninfo_hedging.py", "crawl_cninfo_hedging")
enrich_mod = load_module(SRC_DIR / "02_enrich_and_build_database.py", "enrich_hedging")


def parse_dates():
    """确定抓取日期范围。

    硬性约束：无论默认值还是手工传参，抓取区间的结束日期都不得超过
    运行当天（北京时间）。即 8 月 7 日运行，最多只抓到 8 月 7 日，
    绝不会去抓 8 月 8 日及以后的公告。
    """
    today = datetime.now(BEIJING_TZ).date()
    today_str = today.isoformat()
    default_start = today - timedelta(days=1)

    start_date = sys.argv[1] if len(sys.argv) > 1 else default_start.isoformat()
    end_date = sys.argv[2] if len(sys.argv) > 2 else today_str

    # 上限裁剪：任何一端都不允许晚于今天
    if start_date > today_str:
        print(f"start_date {start_date} 晚于今天，已裁剪为 {today_str}")
        start_date = today_str
    if end_date > today_str:
        print(f"end_date {end_date} 晚于今天，已裁剪为 {today_str}")
        end_date = today_str
    if start_date > end_date:
        start_date = end_date

    return start_date, end_date, today_str


def drop_future_rows(rows, today_str: str):
    """丢弃公告日期晚于今天的记录。

    巨潮网在傍晚常会放出「次日披露」的公告（例如 8 月 7 日 19:00 已能
    看到日期标记为 8 月 8 日的公告）。按用户要求，这类未来日期的数据
    一律不入库，留到那一天再抓。
    """
    kept, dropped = [], []
    for row in rows:
        date_value = (row.get("announcement_date") or "").strip()
        if date_value and date_value > today_str:
            dropped.append(row)
        else:
            kept.append(row)

    print(f"today = {today_str}")
    print(f"dropped_future_rows = {len(dropped)}")
    if dropped:
        preview = sorted({r.get("announcement_date", "") for r in dropped})
        print(f"dropped_future_dates = {', '.join(preview)}")
    return kept


def crawl_range(start_date: str, end_date: str):
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(RAW_DB_PATH)
    crawl_mod.init_db(conn)

    date_range = f"{start_date}~{end_date}"
    session = crawl_mod.requests.Session()
    first = crawl_mod.request_page(session, 1, date_range)
    total = int(first.get("totalAnnouncement") or first.get("totalRecordNum") or 0)
    pages = max(1, int(first.get("totalpages") or 0), math.ceil(total / crawl_mod.PAGE_SIZE))
    all_rows = []

    for page_num in range(1, pages + 1):
        data = first if page_num == 1 else crawl_mod.request_page(session, page_num, date_range)
        items = data.get("announcements") or []
        rows = [crawl_mod.normalize_item(item) for item in items if item.get("announcementId")]
        all_rows.extend(rows)
        crawl_mod.upsert_rows(conn, rows)
        print(f"{date_range} page {page_num}/{pages}: {len(rows)}")
        time.sleep(0.2)

    conn.close()
    return all_rows


def load_market_info():
    try:
        return enrich_mod.fetch_region_industry()
    except Exception as exc:
        market_info = enrich_mod.load_cached_region_industry()
        if not market_info:
            raise
        print(f"used_cached_region_industry=true reason={exc}")
        return market_info


def enrich_rows(raw_rows, market_info):
    final_rows = []
    for row in sorted(raw_rows, key=lambda item: (item["announcement_date"], item["announcement_time_ms"] or 0, item["announcement_id"])):
        stock_code = row["stock_code"] or None
        info = market_info.get(stock_code or "", {})
        industry = info.get("industry") or None
        if industry == "-":
            industry = None
        province = info.get("province") or enrich_mod.detect_province(
            enrich_mod.normalize_text(row["company_name"], row["announcement_title"])
        ) or None
        if province not in enrich_mod.VALID_PROVINCES:
            province = None
        commodity = enrich_mod.infer_commodity(row["company_name"], industry or "", row["announcement_title"]) or None
        final_rows.append(
            {
                "announcement_id": int(row["announcement_id"]),
                "announcement_date": row["announcement_date"],
                "stock_code": stock_code,
                "company_name": row["company_name"] or None,
                "industry": industry,
                "province": province,
                "announcement_title": row["announcement_title"],
                "pdf_url": row["pdf_url"],
                "commodity": commodity,
            }
        )
    return final_rows


def upsert_postgres(rows):
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        print("请先在 PowerShell 设置 $env:DATABASE_URL")
        return 1

    if not rows:
        print("imported_rows = 0")
        return 0

    sql = """
        insert into public.hedging_announcements (
            announcement_id, announcement_date, stock_code, company_name,
            industry, province, announcement_title, pdf_url, commodity
        )
        values (
            %(announcement_id)s, %(announcement_date)s, %(stock_code)s, %(company_name)s,
            %(industry)s, %(province)s, %(announcement_title)s, %(pdf_url)s, %(commodity)s
        )
        on conflict (announcement_id) do update set
            announcement_date = excluded.announcement_date,
            stock_code = excluded.stock_code,
            company_name = excluded.company_name,
            industry = excluded.industry,
            province = excluded.province,
            announcement_title = excluded.announcement_title,
            pdf_url = excluded.pdf_url,
            commodity = excluded.commodity
    """
    with psycopg2.connect(database_url) as conn:
        with conn.cursor() as cur:
            cur.executemany(sql, rows)
            cur.execute("select count(*), min(announcement_date), max(announcement_date) from public.hedging_announcements")
            total_count, min_date, max_date = cur.fetchone()

    print(f"imported_rows = {len(rows)}")
    print(f"total_rows = {total_count}")
    print(f"date_range = {min_date} ~ {max_date}")
    return 0


def main():
    start_date, end_date, today_str = parse_dates()
    raw_rows = crawl_range(start_date, end_date)
    print(f"crawled_rows = {len(raw_rows)}")

    # 第二道防线：即使接口返回了未来日期的公告，也在入库前剔除
    raw_rows = drop_future_rows(raw_rows, today_str)

    market_info = load_market_info()
    final_rows = enrich_rows(raw_rows, market_info)
    print(f"fetched_rows = {len(raw_rows)}")
    return upsert_postgres(final_rows)


if __name__ == "__main__":
    raise SystemExit(main())
