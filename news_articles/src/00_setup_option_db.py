"""
在 Supabase(PostgreSQL) 上建期权日线表 option_daily。
- 字段尽量贴合 akshare 输出（option_commodity_hist_sina 返回 date/open/high/low/close/volume），
  并补充可识别期权合约的字段（品种/合约代码/期权类型/标的合约/行权价）。
- 额外加入用户要求的三个系统字段：id(int4 自增主键)、created_at、updated_at（自动维护）。
幂等：重复运行不会报错。
"""
import os
import psycopg2

DATABASE_URL = os.environ["DATABASE_URL"]

SQL = """
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS public.option_daily;
CREATE TABLE public.option_daily (
    id            INT4        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    variety       VARCHAR(50) NOT NULL,                       -- 品种，如 豆粕期权
    symbol        VARCHAR(30) NOT NULL,                       -- 期权合约代码，如 m2609C2500
    option_type   CHAR(1),                                    -- C=看涨 / P=看跌
    underlying    VARCHAR(20),                                -- 标的期货合约，如 m2609
    strike        NUMERIC(12,2),                              -- 行权价
    trade_date    DATE        NOT NULL,                       -- akshare 输出的 date
    open          NUMERIC(16,4),
    high          NUMERIC(16,4),
    low           NUMERIC(16,4),
    close         NUMERIC(16,4),
    volume        BIGINT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT option_daily_uniq UNIQUE (symbol, trade_date)
);

CREATE INDEX IF NOT EXISTS idx_option_daily_variety   ON public.option_daily (variety);
CREATE INDEX IF NOT EXISTS idx_option_daily_tradedate ON public.option_daily (trade_date);

DROP TRIGGER IF EXISTS update_option_daily_modtime ON public.option_daily;
CREATE TRIGGER update_option_daily_modtime
    BEFORE UPDATE ON public.option_daily
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
"""

if __name__ == "__main__":
    with psycopg2.connect(DATABASE_URL) as conn:
        with conn.cursor() as cur:
            cur.execute(SQL)
        conn.commit()
    print("OK: table public.option_daily ready")
