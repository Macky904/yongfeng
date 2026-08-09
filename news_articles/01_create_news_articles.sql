-- ============================================================
-- 新闻 / 社交媒体监控表  public.news_articles
-- 用途：采集新闻 RSS / NewsAPI / GDELT（暂不含付费 Twitter API）等来源，
--       存储原始内容 + AI 摘要 + 影响分，用于舆情/事件监控。
-- 库：Supabase PostgreSQL (postgres)
-- 说明：完全沿用原始建表语句，未额外增设字段。
--   仅补建触发器依赖函数 update_updated_at_column()（原 SQL 漏了会报错）。
-- ============================================================

-- 0) 触发器依赖函数（必须先建，否则触发器创建失败）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1) 建表
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
