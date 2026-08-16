"""
建表脚本：在 Supabase/PostgreSQL 中创建 public.news_articles

用法（PowerShell）：
  $env:DATABASE_URL='postgresql://postgres.xxxxx:密码@xxxxx.pooler.supabase.com:5432/postgres?sslmode=require'
  python build_news_articles.py

连接串请放在环境变量 DATABASE_URL，不要硬编码进仓库。
"""
import os
import sys

try:
    import psycopg2
except ImportError:
    print("请先安装: pip install psycopg2-binary")
    sys.exit(1)

DSN = os.environ.get("DATABASE_URL") or os.environ.get("SUPABASE_DB_URL")
if not DSN:
    print("错误: 请设置环境变量 DATABASE_URL（或 SUPABASE_DB_URL）")
    print("示例: $env:DATABASE_URL='postgresql://postgres.xxx:密码@xxx.pooler.supabase.com:5432/postgres?sslmode=require'")
    sys.exit(1)

sql = r"""
-- 0) 触发器依赖函数（必须先建，否则触发器创建失败）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1) 建表（完全沿用 01_create_news_articles.sql 原始 DDL，未额外加字段）
CREATE TABLE IF NOT EXISTS public.news_articles (
  news_no            serial                      NOT NULL,
  id                 uuid                        NOT NULL DEFAULT gen_random_uuid(),
  title              character varying(500)      NOT NULL,
  original_title     character varying(500)      NULL,
  content            text                        NULL,
  original_content   text                        NULL,
  ai_summary         text                        NULL,
  source_url         character varying(1000)     NOT NULL,
  source_name        character varying(100)      NULL,
  author             character varying(100)      NULL,
  original_lang      character varying(10)       NULL DEFAULT 'zh'::character varying,
  topic              character varying(100)      NULL,
  impact_score       double precision            NULL DEFAULT 0,
  status             integer                     NULL DEFAULT 0,
  is_urgent          boolean                     NULL DEFAULT false,
  admin_notes        text                        NULL,
  pub_date           timestamp with time zone    NULL,
  created_at         timestamp with time zone    NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         timestamp with time zone    NULL DEFAULT CURRENT_TIMESTAMP,
  tags               character varying(255)      NULL,
  CONSTRAINT news_articles_pkey PRIMARY KEY (id),
  CONSTRAINT news_articles_source_url_key UNIQUE (source_url)
) TABLESPACE pg_default;

-- 2) 索引
CREATE INDEX IF NOT EXISTS idx_news_no            ON public.news_articles USING btree (news_no) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_news_status_pubdate ON public.news_articles USING btree (status, pub_date DESC) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_news_topic         ON public.news_articles USING btree (topic) TABLESPACE pg_default;

-- 3) 更新时间触发器
DROP TRIGGER IF EXISTS update_news_articles_modtime ON public.news_articles;
CREATE TRIGGER update_news_articles_modtime
  BEFORE UPDATE ON news_articles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
"""

conn = psycopg2.connect(DSN)
conn.autocommit = True
cur = conn.cursor()
cur.execute(sql)
print("news_articles table built OK")

cur.execute(
    "SELECT column_name, data_type FROM information_schema.columns "
    "WHERE table_schema='public' AND table_name='news_articles' ORDER BY ordinal_position;"
)
print("\n=== columns ===")
for c in cur.fetchall():
    print(c)
cur.execute("SELECT count(*) FROM public.news_articles;")
print("\nrow count:", cur.fetchone()[0])
cur.close()
conn.close()
