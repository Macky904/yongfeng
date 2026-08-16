"""
探索脚本：离线加载 x_oils_monitor/sample_tweets.json，打印映射结果。
不连库，仅验证字段与打分逻辑。

用法（在 news_articles 目录）：
  python 探索脚本/probe_x_oils_sample.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MON = ROOT / "x_oils_monitor"
sys.path.insert(0, str(MON / "src"))

from mapper import map_tweet_to_news  # noqa: E402
from scoring import calc_impact_score, extract_tags, is_oils_related  # noqa: E402


def main() -> None:
    path = MON / "sample_tweets.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    tweets = data.get("tweets") or data
    print(f"样本数: {len(tweets)}\n")
    for t in tweets:
        text = t.get("text", "")
        ok = is_oils_related(text)
        score = t.get("impact_score")
        if score is None:
            score = calc_impact_score(text, t.get("likes", 0), t.get("reposts", 0))
        row = map_tweet_to_news(t, topic="农产品-油脂", impact_score=float(score))
        if t.get("ai_summary"):
            row["ai_summary"] = t["ai_summary"]
        print("=" * 60)
        print("oils_related:", ok, "| score:", row["impact_score"], "| tags:", row["tags"])
        print("title:", row["title"][:100])
        print("url  :", row["source_url"])
        print("sum  :", (row.get("ai_summary") or "")[:120])
    print("\nOK — 字段映射与 sample 一致即可进入 monitor_x_oils.py / upsert")


if __name__ == "__main__":
    main()
