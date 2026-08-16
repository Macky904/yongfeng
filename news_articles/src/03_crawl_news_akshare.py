"""
03_crawl_news_akshare.py — 用 AkShare 抓国内期货/大宗商品财经新闻，写入 news_articles。

数据源（免费、零密钥）：AkShare 聚合的公开源。
  - futures_news_shmet  上海金属网期货新闻（含金属/能源品种，期货向最强）
  - stock_news_main_cx  财新主站新闻（宏观/产业/商品相关）
  - news_cctv           央视财经新闻

运行：
  $env:DATABASE_URL="postgresql://..."
  python src/03_crawl_news_akshare.py          # 抓全部已配置源
  python src/03_crawl_news_akshare.py --dry    # 只打印前 3 条，不写库（供审核）

说明：AkShare 底层走 requests，自动读取系统 HTTPS_PROXY（沙箱出网需代理）。
"""
import argparse
import hashlib
import json
import re
import sys
from datetime import datetime
from pathlib import Path

import akshare as ak
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[0]))
from common import upsert_news  # noqa: E402

# ---- 源配置：(akshare函数名, 参数, source_name, original_lang, 列映射) ----
# 列映射键：date / title / text / link（缺哪列就留 None，脚本自动兜底）
SOURCES = [
    ("futures_news_shmet", {}, "上海金属网", "zh",
     {"date": "发布时间", "text": "内容", "title": None, "link": None}),
    ("stock_news_main_cx", {}, "财新", "zh",
     {"title": "summary", "link": "url", "date": None, "text": None}),
    ("news_cctv", {}, "央视财经", "zh",
     {"date": "date", "title": "title", "text": "content", "link": None}),
]


def parse_date(val):
    if val is None or (isinstance(val, float) and pd.isna(val)):
        return None
    s = str(val).strip().replace("T", " ").replace("Z", "")
    s = re.sub(r"[+-]\d{2}:?\d{2}$", "", s)  # 去掉 +08:00 这类时区尾巴
    if not s or s.lower() in ("nan", "nat", "none"):
        return None
    for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M", "%Y-%m-%d",
               "%Y/%m/%d %H:%M:%S", "%Y/%m/%d"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    return None


def fetch_source(func_name, params, source_name, lang, col_map, limit=50):
    try:
        func = getattr(ak, func_name)
        df = func(**params)
    except AttributeError:
        print(f"akshare_func_missing func={func_name} (跳过)")
        return []
    except Exception as exc:
        print(f"akshare_fetch_failed func={func_name} reason={exc}")
        return []

    if not isinstance(df, pd.DataFrame) or df.empty:
        print(f"akshare_empty func={func_name}")
        return []

    c_date = col_map.get("date")
    c_title = col_map.get("title")
    c_text = col_map.get("text")
    c_link = col_map.get("link")
    if c_date and c_date not in df.columns:
        c_date = None
    if c_title and c_title not in df.columns:
        c_title = None
    if c_text and c_text not in df.columns:
        c_text = None
    if c_link and c_link not in df.columns:
        c_link = None

    rows = []
    for _, row in df.head(limit).iterrows():
        text = str(row.get(c_text, "")).strip() if c_text else ""
        title = str(row.get(c_title, "")).strip() if c_title else ""
        if not title and text:
            title = text[:30]  # 无标题列时取正文前 30 字当标题
        link = str(row.get(c_link, "")).strip() if c_link else ""
        if not title and not text:
            continue
        # 无链接时用稳定哈希造唯一键，避免跨次重复
        if link:
            source_url = link
        else:
            h = hashlib.md5((source_name + title).encode("utf-8")).hexdigest()[:12]
            source_url = f"akshare://{source_name}/{h}"
        pub = parse_date(row.get(c_date)) if c_date else None
        content = text or title
        rows.append({
            "title": title,
            "original_title": title,
            "content": content,
            "original_content": content,
            "source_url": source_url,
            "source_name": source_name,
            "author": source_name,
            "original_lang": lang,
            "platform": "web_scrape",
            "raw_json": json.dumps({"title": title, "link": link, "text": text},
                                   ensure_ascii=False, default=str),
            "pub_date": pub,
        })
    print(f"source={source_name} func={func_name} rows={len(rows)}")
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry", action="store_true", help="只打印前 3 条，不写库")
    ap.add_argument("--limit", type=int, default=50, help="每个源最多抓取条数")
    args = ap.parse_args()

    rows = []
    for func_name, params, source_name, lang, col_map in SOURCES:
        rows.extend(fetch_source(func_name, params, source_name, lang, col_map, limit=args.limit))

    seen, uniq = set(), []
    for r in rows:
        if r["source_url"] in seen:
            continue
        seen.add(r["source_url"])
        uniq.append(r)
    rows = uniq

    if args.dry:
        print(f"\n=== DRY RUN: 共 {len(rows)} 条，仅展示前 5 条 ===")
        for r in rows[:5]:
            print(f"[{r['source_name']}] {r['title']}")
            print(f"    {r['source_url']}  |  {r['pub_date']}")
            print(f"    {r['content'][:100]}")
        return 0

    return upsert_news(rows)


if __name__ == "__main__":
    raise SystemExit(main())
