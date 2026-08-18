"""
common.py — 多源新闻入库共用模块。
被 03_crawl_news_akshare.py / 03_crawl_news_rss.py 调用，未来其它源也复用它。

职责：
  1) is_relevant(text): 商品关键词白名单过滤——命中期货/大宗商品品种词才判定相关，
     用于在入库前拦截"地震/债券/个股/个人理财"等无关内容（治本）。
  2) enrich(text, title): 纯规则关键词提取，返回 (topic, tags, summary, impact_score)
     —— 与平台无关，推文/新闻/快讯都吃纯文本即可。
  3) upsert_news(rows): 先按 is_relevant 过滤，再写入 public.news_articles。
     - 以 source_url 为唯一键，冲突时只更新正文（不重复插入）
     - 写完后对每条跑 enrich，回填 topic/tags/ai_summary/impact_score

字段约定（所有爬虫统一产出这个 dict）：
  title, original_title, content, original_content,
  source_url, source_name, author, original_lang,
  pub_date
"""
import os
import re

import psycopg2

# ---------------- 商品品种词典（统一一份，供过滤 + 打标签共用）----------------
# 每个品种 -> 命中关键词（中英文，全部小写匹配）。过滤与 topic 标签共用本表，
# 保证"能入库的新闻一定能打出 topic"，topic='其他' 就等价于无关垃圾。
COMMODITY_RULES = [
    # 贵金属
    ("黄金", ["gold", "黄金", "bullion", "伦敦金"]),
    ("白银", ["silver", "白银"]),
    ("铂钯", ["platinum", "铂", "palladium", "钯"]),
    # 基本金属
    ("铜", ["copper", "铜"]),
    ("铝", ["aluminum", "aluminium", "铝"]),
    ("锌", ["zinc", "锌"]),
    ("镍", ["nickel", "镍"]),
    ("铅锡", ["铅", "锡"]),
    # 黑色
    ("铁矿石", ["iron ore", "铁矿石", "铁精粉"]),
    ("矿业", ["mining", "miner", "矿业", "采矿"]),
    ("螺纹钢", ["rebar", "螺纹钢", "热卷", "热轧", "冷轧", "线材"]),
    ("焦煤焦炭", ["焦炭", "焦煤", "coke", "coking coal"]),
    ("动力煤", ["动力煤", "煤炭", "coal"]),
    ("不锈钢", ["不锈钢"]),
    ("硅铁锰硅", ["硅铁", "锰硅"]),
    # 能源
    ("原油", ["crude", "crude oil", "crudeoil", "oil", "原油", "石油", "wti", "brent", "布伦特"]),
    ("成品油", ["fuel oil", "diesel", "gasoline", "petrol", "jet fuel", "heating oil",
                "petroleum", "petroleum products", "refiner", "refining", "refinery", "成品油", "柴油", "汽油"]),
    ("燃料油", ["燃料油", "燃油"]),
    ("沥青", ["沥青", "bitumen"]),
    ("天然气", ["natural gas", "天然气", "lng"]),
    # 农产品
    ("大豆", ["soybean", "soy", "大豆", "豆粕", "soymeal", "豆油", "soybean oil"]),
    ("玉米", ["corn", "maize", "玉米"]),
    ("小麦", ["wheat", "小麦"]),
    ("棉花", ["cotton", "棉花"]),
    ("白糖", ["sugar", "食糖", "白糖", "糖"]),
    ("油脂", ["棕榈油", "palm oil", "canola", "油菜籽", "菜籽", "菜油", "菜粕"]),
    ("生猪", ["生猪", "猪", "hog", "pork"]),
    ("畜牧", ["cattle", "beef", "牛肉", "livestock"]),
    ("鸡蛋", ["鸡蛋", "蛋鸡"]),
    ("苹果红枣", ["苹果", "红枣", "花生"]),
    # 化工
    ("橡胶", ["rubber", "橡胶"]),
    ("甲醇", ["甲醇", "methanol"]),
    ("PTA", ["pta"]),
    ("乙二醇", ["乙二醇"]),
    ("塑料", ["pvc", "plastic", "plastics", "聚丙烯", "聚氯乙烯", "塑料", "聚乙烯"]),
    ("尿素", ["尿素", "urea"]),
    ("纯碱玻璃", ["纯碱", "soda ash", "玻璃"]),
    ("苯乙烯", ["苯乙烯", "styrene"]),
    # 新能源 / 有色
    ("锂", ["lithium", "锂", "碳酸锂"]),
    ("钴", ["cobalt", "钴"]),
    ("工业硅", ["工业硅", "多晶硅", "有机硅"]),
    ("新能源", ["battery", "电池", "锂电池", "锂电", "储能", "新能源", "电动"]),
    # 高精度专题 / 机构
    ("USDA报告", ["usda"]),
    ("农业天气", ["drought", "crop progress", "crop condition", "precipitation", "monsoon",
                "enso", "el nino", "la nina", "weather", "干旱", "降水", "作物进度", "作物优良率"]),
    ("出口销售", ["export sales", "export sale"]),
    ("基金持仓", ["cftc", "managed money", "持仓"]),
    ("OPEC", ["opec"]),
    ("交易所动态", ["lme", "shfe", "comex", "nymex", "cbot", "交割", "基差"]),
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


def contains_keyword(text: str, keyword: str) -> bool:
    """匹配品种关键词；英文词使用边界，避免把 ``soil`` 误判为 ``oil``。"""
    if keyword.isascii() and re.fullmatch(r"[a-z0-9]+(?: [a-z0-9]+)*", keyword):
        return re.search(rf"(?<![a-z0-9]){re.escape(keyword)}(?![a-z0-9])", text) is not None
    return keyword in text


def is_relevant(text: str):
    """商品相关性白名单过滤。命中任意品种关键词 -> True（入库），否则 False（丢弃）。"""
    if not text:
        return False
    t = text.lower()
    return any(contains_keyword(t, k) for _, kws in COMMODITY_RULES for k in kws)


def detect_topics(text: str):
    t = text.lower()
    return [name for name, kws in COMMODITY_RULES if any(contains_keyword(t, k) for k in kws)]


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


def enrich(text: str, title: str = ""):
    """纯文本 -> (topic, tags, summary, impact_score)。平台无关，所有源复用。
    用 title+text 合并判断主题（标题里的品种词不能被漏掉），summary 优先用标题。"""
    text = text or ""
    title = title or ""
    merged = (title + " " + text).strip()
    topics = detect_topics(merged)
    countries = detect_countries(merged)
    direction = "利好" if detect_impact(merged) > 0 else (
        "利空" if detect_impact(merged) < 0 else "中性")
    summary = (title or make_summary(text))[:200].strip()
    topic = "/".join(topics) if topics else "其他"
    tags = ",".join(topics + countries + [direction])
    return topic, tags, summary, detect_impact(merged)


def upsert_news(rows):
    """先按 is_relevant 过滤无关新闻，再写入 news_articles。source_url 唯一键，冲突更新正文。"""
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        return 1
    if not rows:
        print("imported_rows = 0 (无新数据)")
        return 0

    # 相关性过滤：标题+正文合并判断，命中商品白名单才入库
    kept, dropped = [], 0
    for r in rows:
        text = f"{r.get('title') or ''} {r.get('content') or ''}"
        if is_relevant(text):
            kept.append(r)
        else:
            dropped += 1
    print(f"relevance_filter: kept={len(kept)} dropped={dropped}")
    if not kept:
        print("imported_rows = 0 (全部被相关性过滤)")
        return 0
    rows = kept

    sql = """
        insert into public.news_articles (
            title, original_title, content, original_content,
            source_url, source_name, author, original_lang,
            pub_date
        ) values (
            %(title)s, %(original_title)s, %(content)s, %(original_content)s,
            %(source_url)s, %(source_name)s, %(author)s, %(original_lang)s,
            %(pub_date)s
        )
        on conflict (source_url) do update set
            content = excluded.content,
            original_content = excluded.original_content,
            author = excluded.author,
            updated_at = now()
    """
    with psycopg2.connect(database_url, connect_timeout=15) as conn:
        with conn.cursor() as cur:
            cur.executemany(sql, rows)
            for r in rows:
                text = r.get("content") or ""
                title = r.get("title") or ""
                topic, tags, summary, impact = enrich(text, title)
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
                "select count(*) from public.news_articles where source_name=%s",
                (rows[0]["source_name"],),
            )
            total = cur.fetchone()[0]
    print(f"imported_rows = {len(rows)}  source_total({rows[0]['source_name']}) = {total}")
    return 0
