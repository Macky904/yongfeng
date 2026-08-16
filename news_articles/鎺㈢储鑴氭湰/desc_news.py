"""查看 public.news_articles 表结构 / 索引 / 触发器 / 行数。

用法：
  $env:DATABASE_URL='postgresql://...'
  python 探索脚本/desc_news.py
"""
import os
import sys

try:
    import psycopg2
except ImportError:
    print("请安装: pip install psycopg2-binary")
    sys.exit(1)

DSN = os.environ.get("DATABASE_URL") or os.environ.get("SUPABASE_DB_URL")
if not DSN:
    print("请设置环境变量 DATABASE_URL")
    sys.exit(1)

conn = psycopg2.connect(DSN)
cur = conn.cursor()
cur.execute("""
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema='public' AND table_name='news_articles'
ORDER BY ordinal_position;
""")
cols = cur.fetchall()
print("=== COLUMNS ===")
for c in cols:
    print(f"{c[0]} | {c[1]} | nullable={c[2]} | default={c[3]}")
cur.execute("SELECT indexname, indexdef FROM pg_indexes WHERE tablename='news_articles';")
print("\n=== INDEXES ===")
for i in cur.fetchall():
    print(i[0], "::", i[1])
cur.execute(
    "SELECT tgname, pg_get_triggerdef(oid) FROM pg_trigger "
    "WHERE tgrelid='public.news_articles'::regclass AND NOT tgisinternal;"
)
print("\n=== TRIGGERS ===")
for t in cur.fetchall():
    print(t[0], "::", t[1])
cur.execute("SELECT count(*) FROM public.news_articles;")
print("\n=== ROW COUNT ===", cur.fetchone()[0])
cur.close()
conn.close()
