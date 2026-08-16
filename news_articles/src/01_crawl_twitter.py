"""
01_crawl_twitter.py — 抓取 Twitter/X 推文并写入 public.news_articles (platform='twitter')

抓取方式：twscrape（逆向 Twitter 移动端接口，免官方 API key；靠账号池模拟登录抓取）
适用场景：对应 news_articles 表注释里的"暂不含付费 Twitter API"——本脚本用免费逆向方案补上推特来源。

监测目标：目前只监测指定账号（见下方 MONITOR_USERS，默认 kannbwx=Karen Braun）。
           首次运行（库为空）会从 START_DATE(2026-01-01) 起补历史推文；
           之后每次运行改为增量抓取（只抓比库里最新推文更晚的），配合 source_url 唯一键不重复入库。

使用前注意：
  1) 第一次运行前，需先往 twscrape 账号池里加登录身份（二选一，脚本自动优先用 cookie）：
       方式B(cookie，推荐/最稳): 见 cookies.example.txt，把浏览器 X 的 auth_token+ct0 填进 cookies.txt
       方式A(账号密码):         见 accounts.example.txt，把账号填进 accounts.txt
     注：X 的 auth_token/ct0 是 HttpOnly cookie，JS 读不到，须从 DevTools→Application→Cookies 手动复制。
  2) 抓取 Twitter 可能违反其服务条款，请仅用于个人研究，风险自负。
  3) 需要环境变量 DATABASE_URL（与仓库其他脚本一致，连接 Supabase/PostgreSQL）。

运行：
  $env:DATABASE_URL="postgresql://..."      # PowerShell
  python src/01_crawl_twitter.py                       # 监测 MONITOR_USERS（默认 kannbwx），增量
  python src/01_crawl_twitter.py 100                   # 监测模式，单次最多 100 条
  python src/01_crawl_twitter.py "原油 OR crude" 50    # 临时切到关键词搜索模式（不影响监测账号）
"""
import asyncio
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import psycopg2
from twscrape import API, gather

BASE_DIR = Path(__file__).resolve().parents[1]
ACCOUNTS_FILE = BASE_DIR / "accounts.txt"   # 方式A 账号密码登录: 每行 用户名:密码:注册邮箱:邮箱密码
COOKIES_FILE = BASE_DIR / "cookies.txt"     # 方式B cookie 导入: 每行 账号名:auth_token=...; ct0=...

# 抓取入库后自动做结构化提取（topic/tags/ai_summary/impact_score），依赖同目录 02_enrich_twitter.py
try:
    import importlib.util as _ilu
    _spec = _ilu.spec_from_file_location(
        "enrich_mod", str(BASE_DIR / "src" / "02_enrich_twitter.py"))
    _emod = _ilu.module_from_spec(_spec)
    _spec.loader.exec_module(_emod)
    _enrich = _emod.enrich
    _HAS_EXTRACT = True
except Exception:
    _HAS_EXTRACT = False

# ---- 监测目标：目前只监测这些账号（按需求先只放 kannbwx = Karen Braun，农业/大宗商品分析师）----
# 想加账号直接在列表里加，如 ["kannbwx", "zerohedge"]
MONITOR_USERS = ["kannbwx"]

# ---- 历史补抓：库为空时，从这天起补抓（本需求：2026 年以来）----
START_DATE = "2026-01-01"
BACKFILL_LIMIT = 1000                         # 首次补历史单次抓取上限（可按需调大）

# ---- 关键词搜索模式（仅在命令行传入查询词时启用）----
DEFAULT_QUERY = "futures OR 期货"
DEFAULT_LIMIT = 50                            # 增量模式单次抓取条数上限


def load_accounts():
    """方式A：从 accounts.txt 读取账号列表，返回 (user, pw, mail, mail_pw) 元组列表。"""
    if not ACCOUNTS_FILE.exists():
        return []
    rows = []
    for line in ACCOUNTS_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(":")
        if len(parts) >= 4:
            rows.append(tuple(parts[:4]))
    return rows


def load_cookies():
    """方式B：从 cookies.txt 读取 cookie 账号，返回 (username, cookie_str) 列表。
    每行格式:  账号名:auth_token=...; ct0=...
    cookie 串必须同时含 auth_token 与 ct0（否则 twscrape 会报错）。
    """
    if not COOKIES_FILE.exists():
        return []
    rows = []
    for line in COOKIES_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            continue
        user, cookie = line.split(":", 1)
        rows.append((user.strip(), cookie.strip()))
    return rows


async def setup_accounts(api: API):
    """账号池为空时灌入账号。优先级：方式B(cookie 导入) > 方式A(账号密码登录)。"""
    existing = len(await api.pool.accounts_info())
    if existing > 0:
        print(f"accounts_in_pool = {existing} (skip add)")
        return

    # 方式B：cookie 导入（免登录、立即生效，最稳）
    ck = load_cookies()
    if ck:
        for user, cookie_str in ck:
            try:
                await api.pool.add_account_cookies(user, cookie_str)
            except Exception as exc:
                print(f"cookie_import_failed user={user} reason={exc}")
                continue
        print(f"cookies_imported = {len(ck)}")
        return

    # 方式A：账号密码登录
    accs = load_accounts()
    if not accs:
        print("accounts_in_pool = 0; provide cookies.txt or accounts.txt")
        print("方式B: 在 cookies.txt 填 '账号名:auth_token=...; ct0=...'")
        print("方式A: 在 accounts.txt 填 '用户名:密码:邮箱:邮箱密码'")
        return
    for user, pw, mail, mail_pw in accs:
        await api.pool.add_account(user, pw, mail, mail_pw)
    await api.pool.login_all()
    print(f"accounts_added = {len(accs)}")


def get_last_pub_date(username: str):
    """查库里该账号已存的最新发布时间，用于增量抓取（只抓更晚的）。无则返回 None。"""
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        return None
    try:
        with psycopg2.connect(database_url) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    select max(pub_date) from public.news_articles
                    where platform='twitter'
                      and raw_json->'author'->>'username' = %(u)s
                    """,
                    {"u": username},
                )
                return cur.fetchone()[0]
    except Exception as exc:
        print(f"get_last_pub_date_failed user={username} reason={exc}")
        return None


def tweet_url(t) -> str:
    """拼出推文永久链接，用作 source_url 唯一键。"""
    username = t.user.username if t.user else "i"
    return f"https://x.com/{username}/status/{t.id}"


def tweet_to_row(t) -> dict:
    """把一条 Tweet 映射成 news_articles 的一行。"""
    text = (t.rawContent or "").strip()
    created = t.date  # twscrape 0.20: 发布时间字段名为 date（旧版叫 createdAt）
    if created is not None and created.tzinfo is None:
        created = created.replace(tzinfo=timezone.utc)  # 个别情况下返回 naive，按 UTC 处理
    username = t.user.username if t.user else ""
    display = t.user.displayname if t.user else ""
    title = text[:200]  # title 必填，超长截断
    raw = {
        "id": str(t.id),
        "created_at": created.isoformat() if created else None,
        "text": text,
        "author": {"username": username, "displayname": display},
        "like_count": getattr(t, "likeCount", None),
        "retweet_count": getattr(t, "retweetCount", None),
        "reply_count": getattr(t, "replyCount", None),
        "lang": getattr(t, "lang", None),
    }
    return {
        "title": title,
        "original_title": title,
        "content": text,
        "original_content": text,
        "source_url": tweet_url(t),
        "source_name": "twitter",
        "author": display or username,
        "original_lang": (getattr(t, "lang", None) or "en")[:10],
        "platform": "twitter",
        "raw_json": json.dumps(raw, ensure_ascii=False, default=str),
        "pub_date": created.astimezone(timezone.utc) if created else None,
    }


async def scrape_accounts(api: API, users, limit: int):
    """账号监测模式：库空→从 START_DATE 补历史；库有数据→只抓比最新更晚的（带 1 天缓冲防漏）。"""
    rows = []
    for user in users:
        last = get_last_pub_date(user)
        if last is None:
            since_str = START_DATE
            lim = BACKFILL_LIMIT
            mode = "backfill"
        else:
            # 向前多取 1 天，与已入库重叠部分由 source_url 唯一键去重，确保不漏推文
            since_str = (last - timedelta(days=1)).strftime("%Y-%m-%d")
            lim = limit
            mode = "incremental"
        q = f"from:{user} since:{since_str}"
        try:
            batch = await gather(api.search(q, limit=lim))
        except Exception as exc:
            print(f"scrape_failed user={user} reason={exc}")
            continue
        print(f"user={user} mode={mode} since={since_str} limit={lim} fetched={len(batch)}")
        rows.extend(batch)
    return dedupe(rows)


async def scrape_search(api: API, query: str, limit: int):
    """关键词搜索模式（命令行传入查询词时启用）。"""
    try:
        batch = await gather(api.search(query, limit=limit))
    except Exception as exc:
        print(f"search_failed query={query} reason={exc}")
        return []
    print(f"search query={query} fetched={len(batch)}")
    return dedupe(batch)


def dedupe(tweets):
    """同一次运行内按 source_url 去重。"""
    seen, rows = set(), []
    for t in tweets:
        key = tweet_url(t)
        if key in seen:
            continue
        seen.add(key)
        rows.append(tweet_to_row(t))
    print(f"scraped_tweets = {len(tweets)} unique = {len(rows)}")
    return rows


def upsert_postgres(rows):
    """写入 news_articles，source_url 唯一冲突时更新正文，不重复插入。"""
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        print("请先设置 $env:DATABASE_URL")
        return 1
    if not rows:
        print("imported_rows = 0 (无新推文)")
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
            # 结构化提取：填充 topic/tags/ai_summary/impact_score，并消除 title 冗余
            if _HAS_EXTRACT:
                for r in rows:
                    text = r.get("content") or ""
                    topic, tags, summary, impact = _enrich(text)
                    cur.execute(
                        """update public.news_articles set
                               title=%s, original_title=%s, ai_summary=%s,
                               topic=%s, tags=%s, impact_score=%s
                           where source_url=%s""",
                        ((summary or text)[:200], text[:200], summary,
                         topic, tags, impact, r["source_url"]),
                    )
            cur.execute(
                "select count(*) from public.news_articles where platform='twitter'"
            )
            total = cur.fetchone()[0]
    print(f"imported_rows = {len(rows)}")
    print(f"twitter_rows_total = {total}")
    return 0


async def main_async():
    # 代理：优先 TWS_PROXY，其次系统 HTTPS_PROXY/HTTP_PROXY（沙箱网络需走代理才能到 Twitter）
    proxy = (
        os.getenv("TWS_PROXY")
        or os.getenv("HTTPS_PROXY")
        or os.getenv("HTTP_PROXY")
        or None
    )
    api = API(proxy=proxy)
    await setup_accounts(api)  # 两种模式都需要已登录的账号池

    # 账号池仍为空 → 没法抓，直接退出（常见的坑：忘了填 accounts.txt / cookies.txt）
    if len(await api.pool.accounts_info()) == 0:
        print("no_active_accounts = true; 请先在 cookies.txt 或 accounts.txt 提供登录身份后重试")
        return 1

    # 命令行传入查询词（非纯数字）→ 关键词搜索模式；否则 → 账号监测模式
    if len(sys.argv) > 1 and not sys.argv[1].isdigit():
        query = sys.argv[1]
        limit = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else DEFAULT_LIMIT
        print(f"mode=search query={query} limit={limit}")
        rows = await scrape_search(api, query, limit)
    else:
        limit = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else DEFAULT_LIMIT
        print(f"mode=monitor users={MONITOR_USERS} limit={limit}")
        rows = await scrape_accounts(api, MONITOR_USERS, limit)
    return upsert_postgres(rows)


def main():
    return asyncio.run(main_async())


if __name__ == "__main__":
    raise SystemExit(main())
