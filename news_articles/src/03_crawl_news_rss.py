"""
03_crawl_news_rss.py — 抓取国际大宗商品/期货新闻 RSS，写入 public.news_articles。

数据源（权威大宗商品机构，免费、零密钥，配合 common.is_relevant 只收商品相关）：
  - Investing.com 商品期货新闻（news_11.rss，大量转载 Reuters 原文）
  - Investing.com 商品分析评论（commodities.rss）
  - Bloomberg 市场新闻（markets feed，含 oil/gold 等商品）
  - CNBC 商品期货（Futures & Commodities）
  - U.S. EIA Today in Energy（美国能源信息署官方能源快讯）

说明：
  1) Reuters 官方免费 RSS 已于早前停用（商品新闻转为付费 LSEG 产品），
     故通过 Investing 商品板块转载的 Reuters 原文获取；author 含 "Reuters" 时
     来源自动标为 Reuters。
  2) 入库前统一经 common.is_relevant 商品关键词白名单过滤，只留商品期货相关，
     拦截个股/鸡汤/地震/债券等无关内容。
  3) requests 自动读取系统 HTTPS_PROXY，沙箱出网需走代理。

运行：
  $env:DATABASE_URL="postgresql://..."
  python src/03_crawl_news_rss.py          # 抓全部已配置的 RSS
  python src/03_crawl_news_rss.py --dry    # 只打印前几条，不写库（供审核）
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
FEEDS = [
    ("Investing.com", "https://www.investing.com/rss/news_11.rss", "en"),
    ("Investing.com", "https://www.investing.com/rss/commodities.rss", "en"),
    ("Bloomberg", "https://feeds.bloomberg.com/markets/news.rss", "en"),
    ("CNBC", "https://www.cnbc.com/id/15839171/device/rss/rss.html", "en"),
    ("U.S. EIA", "https://www.eia.gov/rss/todayinenergy.xml", "en"),
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
}


def resolve_source(name: str, author: str):
    """根据 author 识别 Reuters/Bloomberg 转载，归属到真实来源机构。"""
    a = (author or "").lower()
    if "reuters" in a:
        return "Reuters"
    if "bloomberg" in a:
        return "Bloomberg"
    return name


def fetch_feed(name: str, url: str, lang: str, limit: int = 20):
    """抓取单个 RSS，返回构造好的行列表。"""
    try:
        resp = requests.get(url, headers=HEADERS, timeout=25)
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
        source_name = resolve_source(name, author)
        raw = {
            "title": title,
            "link": link,
            "summary": summary,
            "published": e.get("published"),
            "author": author,
        }
        rows.append({
            "title": title,
            "original_title": title,
            "content": content,
            "original_content": content,
            "source_url": link,
            "source_name": source_name,
            "author": author,
            "original_lang": lang,
            "pub_date": pub,
        })
    print(f"feed={name} url={url} entries={len(parsed.entries)} kept={len(rows)}")
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry", action="store_true", help="只打印前几条，不写库")
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
        print(f"\n=== DRY RUN: 共 {len(rows)} 条，仅展示前 5 条 ===")
        for r in rows[:5]:
            print(f"[{r['source_name']}] {r['title']}")
            print(f"    {r['source_url']}  |  {r['pub_date']}")
            print(f"    {r['content'][:120]}")
        return 0

    return upsert_news(rows)


if __name__ == "__main__":
    raise SystemExit(main())
