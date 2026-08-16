"""
02_enrich_twitter.py — 对 news_articles(platform='twitter') 做结构化提取，
弥补"只存原文、多个字段填了一模一样"的问题：

  - topic:        提取主题/品种（大豆/玉米/小麦/USDA报告/出口销售/基金持仓…）
  - tags:         提取标签（品种 + 国家 + 方向 利好/利空/中性）
  - ai_summary:   一句话摘要（去 emoji、取首句）
  - impact_score: 影响方向分（-100 利空 ~ +100 利好；0 中性）
  - 同时修正冗余：original_title 存原文前200，title 存摘要（两者不再相同）

只处理 ai_summary 为空的行，可重复运行（增量）。
纯规则关键词提取，不依赖外部模型，即时免费。若以后要更通顺的 LLM 摘要，
可在此脚本基础上替换 make_summary / detect_* 为模型调用。

运行：
  $env:DATABASE_URL="postgresql://..."
  python src/02_enrich_twitter.py
"""
import json
import os
import re

import psycopg2

# ---- 品种 / 主题词典 ----
TOPIC_RULES = [
    ("USDA报告", ["usda"]),
    ("出口销售", ["export sales", "export", "sales"]),
    ("基金持仓", ["fund", "cftc", "managed money", "持仓", "position"]),
    ("大豆", ["soybean", "soybeans", "soy", "大豆", "soymeal", "soybean meal", "豆粕"]),
    ("玉米", ["corn", "maize", "玉米"]),
    ("小麦", ["wheat", "小麦"]),
    ("棉花", ["cotton", "棉花"]),
    ("糖", ["sugar", "糖"]),
    ("畜牧", ["cattle", "beef", "牛", "hog", "pork", "猪", "livestock"]),
    ("油菜籽", ["canola", "油菜"]),
]
COUNTRY_RULES = {
    "美国": ["u.s.", "us ", "united states", "america"],
    "中国": ["china", "chinese", "中国"],
    "巴西": ["brazil", "brazilian", "巴西"],
    "阿根廷": ["argentina", "阿根廷"],
    "法国": ["france", "french", "法国"],
    "乌克兰": ["ukraine", "乌克兰"],
    "印度": ["india", "印度"],
    "欧盟": ["eu ", "european"],
}
BULL = ["higher", "rise", "rose", "gain", "gains", "record", "surge", "jump",
        "up", "bull", "利好", "上升", "增加", "增长", "高于", "上调"]
BEAR = ["lower", "drop", "dropped", "fall", "fell", "cut", "decline",
        "declined", "bear", "bearish", "利空", "下降", "减少", "低于", "下调", "下滑"]
STRONG = ["record", "surge", "jump", "huge", "sharp", "big", "大幅", "猛", "飙升"]
WEAK = ["slight", "modest", "small", "little", "小幅", "略微"]

EMOJI_RE = re.compile(
    r"[\U0001F000-\U0001FAFF\U00002600-\U000027BF\U0001F1E6-\U0001F1FF]"
)


def detect_topics(text: str):
    t = text.lower()
    return [name for name, kws in TOPIC_RULES if any(k in t for k in kws)]


def detect_countries(text: str):
    t = text.lower()
    return [name for name, kws in COUNTRY_RULES.items() if any(k in t for k in kws)]


def detect_impact(text: str):
    t = text.lower()
    bull = sum(1 for w in BULL if w in t)
    bear = sum(1 for w in BEAR if w in t)
    if bull == bear:
        return 0
    if any(w in t for w in STRONG):
        strength = 60
    elif any(w in t for w in WEAK):
        strength = 30
    else:
        strength = 45
    return strength if bull > bear else -strength


def make_summary(text: str):
    s = EMOJI_RE.sub("", text).strip()
    s = re.sub(r"\s+", " ", s)
    for sep in [". ", "\n", "! ", "? ", "。"]:
        if sep in s:
            s = s.split(sep)[0]
            break
    return s[:200].strip()


def enrich(text: str):
    topics = detect_topics(text)
    countries = detect_countries(text)
    direction = "利好" if detect_impact(text) > 0 else (
        "利空" if detect_impact(text) < 0 else "中性")
    summary = make_summary(text)
    topic = "/".join(topics) if topics else "其他"
    tags = ",".join(topics + countries + [direction])
    return topic, tags, summary, detect_impact(text)


def main():
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        return 1
    conn = psycopg2.connect(database_url)
    cur = conn.cursor()
    cur.execute(
        "select id, raw_json, title from public.news_articles "
        "where platform=%s and (ai_summary is null or ai_summary='')",
        ("twitter",),
    )
    rows = cur.fetchall()
    print(f"to_enrich = {len(rows)}")
    n = 0
    for rid, raw_json, old_title in rows:
        try:
            raw = json.loads(raw_json) if raw_json else {}
        except Exception:
            raw = {}
        text = raw.get("text") or old_title or ""
        topic, tags, summary, impact = enrich(text)
        original_title = text[:200]
        title = (summary or text)[:200]
        cur.execute(
            """update public.news_articles set
                   title=%s, original_title=%s, ai_summary=%s,
                   topic=%s, tags=%s, impact_score=%s
               where id=%s""",
            (title, original_title, summary, topic, tags, impact, rid),
        )
        n += 1
    conn.commit()
    print(f"enriched = {n}")
    cur.execute(
        "select count(distinct topic), count(distinct tags), "
        "count(distinct impact_score), count(distinct ai_summary) "
        "from public.news_articles where platform=%s",
        ("twitter",),
    )
    print("distinct_after:", cur.fetchone())
    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
