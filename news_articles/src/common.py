"""
common.py — 多源新闻入库共用模块。
被 03_crawl_news_akshare.py / 03_crawl_news_rss.py 调用，未来其它源也复用它。

职责：
  1) enrich(text): 纯规则关键词提取，返回 (topic, tags, summary, impact_score)
     —— 与平台无关，推文/新闻/快讯都吃纯文本即可。
  2) upsert_news(rows): 把抓取结果写入 public.news_articles。
     - 以 source_url 为唯一键，冲突时只更新正文（不重复插入）
     - 写完后对每条跑 enrich，回填 topic/tags/ai_summary/impact_score

字段约定（所有爬虫统一产出这个 dict）：
  title, original_title, content, original_content,
  source_url, source_name, author, original_lang,
  platform, raw_json, pub_date
"""
import os
import re

import psycopg2

# ---------------- 品种 / 主题词典 ----------------
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
    ("原油", ["crude", "wti", "brent", "原油", "石油"]),
    ("黄金", ["gold", "黄金", "bullion"]),
    ("白银", ["silver", "白银"]),
    ("铜", ["copper", "铜"]),
    ("铝", ["aluminium", "aluminum", "铝"]),
    ("锌", ["zinc", "锌"]),
    ("镍", ["nickel", "镍"]),
    ("橡胶", ["rubber", "橡胶"]),
    ("铁矿石", ["iron ore", "铁矿石"]),
    ("螺纹钢", ["rebar", "螺纹钢"]),
    ("天然气", ["natural gas", "lng", "天然气"]),
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
    "俄罗斯": ["russia", "russian", "俄罗斯"],
    "澳大利亚": ["australia", "australian", "澳洲"],
}
BULL = ["higher", "rise", "rose", "gain", "gains", "record", "surge", "jump",
        "up", "bull", "利好", "上升", "增加", "增长", "高于", "上调", "上涨"]
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
    for sep in [". ", "\n", "! ", "? ", "。", "；", ";"]:
        if sep in s:
            s = s.split(sep)[0]
            break
    return s[:200].strip()


def enrich(text: str):
    """纯文本 → (topic, tags, summary, impact_score)。平台无关，所有源复用。"""
    text = text or ""
    topics = detect_topics(text)
    countries = detect_countries(text)
    direction = "利好" if detect_impact(text) > 0 else (
        "利空" if detect_impact(text) < 0 else "中性")
    summary = make_summary(text)
    topic = "/".join(topics) if topics else "其他"
    tags = ",".join(topics + countries + [direction])
    return topic, tags, summary, detect_impact(text)


def upsert_news(rows):
    """写入 news_articles。source_url 唯一键，冲突更新正文；随后回填提取字段。"""
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        return 1
    if not rows:
        print("imported_rows = 0 (无新数据)")
        return 0

    sql = """
        insert into public.news_articles (
            title, original_title, content, original_content,
            source_url, source_name, author, original_lang,
            platform, raw_json, pub_date
        ) values (
            %(title)s, %(original_title)s, %(content)s, %(original_content)s,
            %(source_url)s, %(source_name)s, %(author)s, %(original_lang)s,
            %(platform)s, %(raw_json)s, %(pub_date)s
        )
        on conflict (source_url) do update set
            content = excluded.content,
            original_content = excluded.original_content,
            author = excluded.author,
            updated_at = now()
    """
    with psycopg2.connect(database_url) as conn:
        with conn.cursor() as cur:
            cur.executemany(sql, rows)
            # 结构化提取回填
            for r in rows:
                text = r.get("content") or ""
                topic, tags, summary, impact = enrich(text)
                cur.execute(
                    """update public.news_articles set
                           title = coalesce(nullif(title, ''), %(sum)s),
                           ai_summary = %(sum)s,
                           topic = %(topic)s,
                           tags = %(tags)s,
                           impact_score = %(imp)s
                       where source_url = %(url)s""",
                    {"sum": summary, "topic": topic, "tags": tags,
                     "imp": impact, "url": r["source_url"]},
                )
            cur.execute(
                "select count(*) from public.news_articles where platform=%s",
                (rows[0]["platform"],),
            )
            total = cur.fetchone()[0]
    print(f"imported_rows = {len(rows)}  platform_total({rows[0]['platform']}) = {total}")
    return 0
