import html
import json
import math
import re
import sqlite3
import time
from calendar import monthrange
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Dict, Iterable

import requests


BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"
RAW_DIR = BASE_DIR / "raw"
DB_PATH = DATA_DIR / "raw_cninfo_announcements.sqlite"
RAW_JSONL_PATH = RAW_DIR / "cninfo_hedging_raw.jsonl"

QUERY_URL = "https://www.cninfo.com.cn/new/hisAnnouncement/query"
PDF_BASE_URL = "https://static.cninfo.com.cn/"
KEYWORD = "套期保值"
PAGE_SIZE = 30
BEIJING_TZ = timezone(timedelta(hours=8))

HEADERS = {
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
    "Origin": "https://www.cninfo.com.cn",
    "Referer": "https://www.cninfo.com.cn/new/commonUrl/pageOfSearch?url=disclosure/list/search",
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
    ),
    "X-Requested-With": "XMLHttpRequest",
}


def clean_text(value) -> str:
    if value is None:
        return ""
    text = html.unescape(str(value))
    text = re.sub(r"</?em>", "", text, flags=re.IGNORECASE)
    text = re.sub(r"<[^>]+>", "", text)
    return re.sub(r"\s+", " ", text).strip()


def millis_to_date(value) -> str:
    if not value:
        return ""
    return datetime.fromtimestamp(int(value) / 1000, tz=BEIJING_TZ).date().isoformat()


def build_payload(page_num: int, date_range: str) -> Dict[str, str]:
    return {
        "pageNum": str(page_num),
        "pageSize": str(PAGE_SIZE),
        "column": "szse",
        "tabName": "fulltext",
        "plate": "",
        "stock": "",
        "searchkey": KEYWORD,
        "secid": "",
        "category": "",
        "trade": "",
        "seDate": date_range,
        "sortName": "",
        "sortType": "",
        "isHLtitle": "true",
    }


def request_page(session: requests.Session, page_num: int, date_range: str, retries: int = 5) -> Dict:
    last_error = None
    for attempt in range(1, retries + 1):
        try:
            response = session.post(
                QUERY_URL,
                data=build_payload(page_num, date_range),
                headers=HEADERS,
                timeout=30,
            )
            response.raise_for_status()
            return response.json()
        except Exception as exc:
            last_error = exc
            time.sleep(min(2 ** attempt, 20))
    raise RuntimeError(f"Failed page {page_num} for {date_range}: {last_error}")


def normalize_item(item: Dict) -> Dict:
    adjunct_url = clean_text(item.get("adjunctUrl"))
    return {
        "announcement_id": int(clean_text(item.get("announcementId"))),
        "announcement_date": millis_to_date(item.get("announcementTime")),
        "announcement_time_ms": item.get("announcementTime"),
        "stock_code": clean_text(item.get("secCode")),
        "company_name": clean_text(item.get("secName") or item.get("tileSecName")),
        "announcement_title": clean_text(item.get("announcementTitle")),
        "pdf_url": PDF_BASE_URL + adjunct_url if adjunct_url else "",
        "org_id": clean_text(item.get("orgId")),
        "page_column": clean_text(item.get("pageColumn")),
        "adjunct_size_kb": item.get("adjunctSize"),
        "adjunct_type": clean_text(item.get("adjunctType")),
    }


def init_db(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        create table if not exists raw_announcements (
            announcement_id integer primary key,
            announcement_date text not null,
            announcement_time_ms integer,
            stock_code text,
            company_name text,
            announcement_title text not null,
            pdf_url text not null,
            org_id text,
            page_column text,
            adjunct_size_kb integer,
            adjunct_type text
        )
        """
    )
    conn.commit()


def upsert_rows(conn: sqlite3.Connection, rows: Iterable[Dict]) -> int:
    count = 0
    for row in rows:
        conn.execute(
            """
            insert into raw_announcements (
                announcement_id, announcement_date, announcement_time_ms, stock_code,
                company_name, announcement_title, pdf_url, org_id, page_column,
                adjunct_size_kb, adjunct_type
            )
            values (
                :announcement_id, :announcement_date, :announcement_time_ms, :stock_code,
                :company_name, :announcement_title, :pdf_url, :org_id, :page_column,
                :adjunct_size_kb, :adjunct_type
            )
            on conflict(announcement_id) do update set
                announcement_date=excluded.announcement_date,
                announcement_time_ms=excluded.announcement_time_ms,
                stock_code=excluded.stock_code,
                company_name=excluded.company_name,
                announcement_title=excluded.announcement_title,
                pdf_url=excluded.pdf_url,
                org_id=excluded.org_id,
                page_column=excluded.page_column,
                adjunct_size_kb=excluded.adjunct_size_kb,
                adjunct_type=excluded.adjunct_type
            """,
            row,
        )
        count += 1
    conn.commit()
    return count


def crawl(start_year: int = 2004) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    init_db(conn)
    session = requests.Session()
    today = datetime.now(BEIJING_TZ).date()
    total_rows = 0

    with RAW_JSONL_PATH.open("w", encoding="utf-8") as raw_file:
        for year in range(today.year, start_year - 1, -1):
            for month in range(12, 0, -1):
                if year == today.year and month > today.month:
                    continue
                start_date = f"{year}-{month:02d}-01"
                last_day = monthrange(year, month)[1]
                end_date = f"{year}-{month:02d}-{last_day:02d}"
                if year == today.year and month == today.month:
                    end_date = today.isoformat()
                date_range = f"{start_date}~{end_date}"

                first = request_page(session, 1, date_range)
                total = int(first.get("totalAnnouncement") or first.get("totalRecordNum") or 0)
                if total == 0:
                    print(f"{date_range}: 0")
                    time.sleep(0.05)
                    continue
                pages = max(1, int(first.get("totalpages") or 0), math.ceil(total / PAGE_SIZE))
                for page_num in range(1, pages + 1):
                    data = first if page_num == 1 else request_page(session, page_num, date_range)
                    items = data.get("announcements") or []
                    for item in items:
                        raw_file.write(json.dumps(item, ensure_ascii=False) + "\n")
                    rows = [normalize_item(item) for item in items if item.get("announcementId")]
                    total_rows += upsert_rows(conn, rows)
                    print(f"{date_range} page {page_num}/{pages}: {len(rows)}")
                    time.sleep(0.2)

    final_count = conn.execute("select count(*) from raw_announcements").fetchone()[0]
    conn.close()
    print(f"fetched_rows={total_rows}")
    print(f"unique_announcements={final_count}")
    print(f"database={DB_PATH}")


if __name__ == "__main__":
    crawl()
