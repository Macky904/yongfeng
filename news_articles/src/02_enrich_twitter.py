"""
02_enrich_twitter.py — 对 news_articles 里 twitter 来源做结构化提取，
弥补"只存原文、多个字段填了一模一样"的问题：

  - topic:        提取主题/品种（复用 common.COMMODITY_RULES，金属/能源/黑色/化工/新能源全覆盖）
  - tags:         提取标签（品种 + 国家 + 方向 利好/利空/中性）
  - ai_summary:   一句话摘要（去 emoji、取首句）
  - impact_score: 影响方向分（负=利空 ~ 正=利好；0 中性）

只处理 ai_summary 为空的行，可重复运行（增量）。
纯规则关键词提取，不依赖外部模型，即时免费。

运行：
  $env:DATABASE_URL="postgresql://..."
  python src/02_enrich_twitter.py
"""
import json
import os
import sys
from pathlib import Path

import psycopg2

sys.path.insert(0, str(Path(__file__).resolve().parents[0]))
from common import enrich as _enrich  # noqa: E402


def enrich(text: str):
    """与 common 保持一致：title+text 合并判断。推文无独立标题，title 传空。"""
    return _enrich(text, "")


def main():
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        return 1
    conn = psycopg2.connect(database_url, connect_timeout=15)
    cur = conn.cursor()
    # 只回填 twitter 来源、且 ai_summary 为空的行（增量可重跑）
    cur.execute(
        "select id, content, title from public.news_articles "
        "where source_name='twitter' and (ai_summary is null or ai_summary='')"
    )
    rows = cur.fetchall()
    print(f"to_enrich = {len(rows)}")
    n = 0
    for rid, content, old_title in rows:
        text = (content or old_title or "")
        topic, tags, summary, impact = enrich(text)
        title = (summary or text)[:200]
        cur.execute(
            """update public.news_articles set
                   title=%s, ai_summary=%s,
                   topic=%s, tags=%s, impact_score=%s
               where id=%s""",
            (title, summary, topic, tags, impact, rid),
        )
        n += 1
    conn.commit()
    print(f"enriched = {n}")
    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
