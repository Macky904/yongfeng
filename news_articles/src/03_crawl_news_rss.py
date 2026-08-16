"""
03_crawl_news_rss.py — 抓取国际期货/大宗商品新闻 RSS，写入 public.news_articles。

数据源（免费、零密钥）：
  - Investing.com   新闻 RSS
  - Kitco           贵金属/大宗商品新闻 RSS
  - MarketWatch     综合财经 RSS

运行：
  $env:DATABASE_URL="postgresql://..."
  python src/03_crawl_news_rss.py          # 抓全部已配置的 RSS
  python src/03_crawl_news_rss.py --dry    # 只打印前 3 条，不写库（供审核）

说明：requests 自动读取系统 HTTPS_PROXY，沙箱出网需走代理（与 twscrape 同理）。
"""
import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import feedparser
import requests

sys.path.insert(0, str(Path(__file__).resolve().parents[0]))
from common import upsert_news  # noqa: E402

# ---- RSS 源配置：(source_name, url, original_lang) ----
# 注：Kitco RSS 目前返回空（已失效），Investing 商品 RSS 404，故先用以下两个稳定源。
FEEDS = [
    ("Investing.com", "https://www.investing.com/rss/news.rss", "en"),
    ("MarketWatch", "https://feeds.content.dowjones.io/public/rss/mw_topstories", "en"),
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
}


def fetch_feed(name: str, url: str, lang: str, limit: int = 20):
    """抓取单个 RSS，返回构造好的行列表。"""
    try:
        resp = requests.get(url, headers=HEADERS, timeout=20)
        resp.raise_for_status()
    except Exception as exc:
        print(f"feed_failed name={name} url={url} reason={exc}")
        return []
    parsed = feedparser.parse(resp.content)
    rows = []
    for e in parsed.entries[:limit]:
        title = (e.get("title") or "").strip()
        link = (e.get("link") or "").strip()
        summary = (e.get("summary") or e.get("description") or "").strip()
        content = summary
        if not link:
            continue
        pub = None
        if getattr(e, "published_parsed", None):
            pub = datetime(*e.published_parsed[:6], tzinfo=timezone.utc)
        elif getattr(e, "updated_parsed", None):
            pub = datetime(*e.updated_parsed[:6], tzinfo=timezone.utc)
        author = e.get("author") or name
        raw = {
            "title": title,
            "link": link,
            "summary": summary,
            "published": e.get("published"),
        }
        rows.append({
            "title": title,
            "original_title": title,
            "content": content,
            "original_content": content,
            "source_url": link,
            "source_name": name,
            "author": author,
            "original_lang": lang,
            "platform": "rss",
            "raw_json": json.dumps(raw, ensure_ascii=False, default=str),
            "pub_date": pub,
        })
    print(f"feed={name} url={url} entries={len(parsed.entries)} kept={len(rows)}")
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry", action="store_true", help="只打印前 3 条，不写库")
    ap.add_argument("--limit", type=int, default=20, help="每个源最多抓取条数")
    args = ap.parse_args()

    rows = []
    for name, url, lang in FEEDS:
        rows.extend(fetch_feed(name, url, lang, limit=args.limit))

    # 同一次运行内按 source_url 去重
    seen, uniq = set(), []
    for r in rows:
        if r["source_url"] in seen:
            continue
        seen.add(r["source_url"])
        uniq.append(r)
    rows = uniq

    if args.dry:
        print(f"\n=== DRY RUN: 共 {len(rows)} 条，仅展示前 3 条 ===")
        for r in rows[:3]:
            print(f"[{r['source_name']}] {r['title']}")
            print(f"    {r['source_url']}  |  {r['pub_date']}")
            print(f"    {r['content'][:120]}")
        return 0

    return upsert_news(rows)


if __name__ == "__main__":
    raise SystemExit(main())
