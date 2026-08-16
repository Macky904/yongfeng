"""
00_setup_db.py — 按用户提供的 DDL 在 Supabase/PostgreSQL 建好 news_articles 表。

幂等：函数/表/索引/触发器都存在则跳过，缺失则补建。
严格遵循用户给的表格式（不含 platform / raw_json 两列）。
"""
import os
import psycopg2

# 用户建表语句引用了 update_updated_at_column()，但没给定义；这里补上，否则触发器建失败
DDL_FUNCTION = """
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
"""

DDL_TABLE = """
CREATE TABLE IF NOT EXISTS public.news_articles (
  news_no serial not null,
  id uuid not null default gen_random_uuid (),
  title character varying(500) not null,
  original_title character varying(500) null,
  content text null,
  original_content text null,
  ai_summary text null,
  source_url character varying(1000) not null,
  source_name character varying(100) null,
  author character varying(100) null,
  original_lang character varying(10) null default 'zh'::character varying,
  topic character varying(100) null,
  impact_score double precision null default 0,
  status integer null default 0,
  is_urgent boolean null default false,
  admin_notes text null,
  pub_date timestamp with time zone null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  tags character varying(255) null,
  constraint news_articles_pkey primary key (id),
  constraint news_articles_source_url_key unique (source_url)
) TABLESPACE pg_default;
"""

INDEXES = [
    "CREATE INDEX IF NOT EXISTS idx_news_no ON public.news_articles USING btree (news_no)",
    "CREATE INDEX IF NOT EXISTS idx_news_status_pubdate ON public.news_articles USING btree (status, pub_date desc)",
    "CREATE INDEX IF NOT EXISTS idx_news_topic ON public.news_articles USING btree (topic)",
]

TRIGGER = """
DROP TRIGGER IF EXISTS update_news_articles_modtime ON public.news_articles;
CREATE TRIGGER update_news_articles_modtime BEFORE UPDATE ON news_articles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column ();
"""


def main() -> int:
    url = os.environ.get("DATABASE_URL")
    if not url:
        print("missing_DATABASE_URL = true")
        return 1
    with psycopg2.connect(url) as conn:
        cur = conn.cursor()
        cur.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto;")  # gen_random_uuid 依赖
        cur.execute(DDL_FUNCTION)
        cur.execute(DDL_TABLE)
        for ix in INDEXES:
            cur.execute(ix)
        cur.execute(TRIGGER)
        conn.commit()

        # 校验结果
        cur.execute(
            """
            select column_name from information_schema.columns
            where table_schema='public' and table_name='news_articles'
            order by ordinal_position
            """
        )
        cols = [r[0] for r in cur.fetchall()]
        cur.execute("select count(*) from public.news_articles")
        cnt = cur.fetchone()[0]
    print("columns =", cols)
    print("row_count =", cnt)
    print("setup_done = true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
