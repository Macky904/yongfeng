-- ============================================================================
-- 外盘期货日线数据库 — 新增 symbol_id 外键，关联 symbol 主数据表
-- 生成时间: 2026-08-12
-- 目的: 把 futures_kline_daily 的「品种(variety)」与「代号(exchange_code=合约根代码)」
--       通过单一代理外键 symbol_id 关联到 symbol 表，消除冗余文本字段的歧义。
-- 关联键:
--   futures_kline_daily.exchange_code (= 合约根代码) = symbol.symbol_code
--   futures_kline_daily.exchange      (= 交易所名)    = symbol.exchange_code
-- 注意: 本文件不含任何数据库连接串。
-- ============================================================================

-- 1) 新增外键列（nullable，便于未来未知合约可先插入再补关联）
ALTER TABLE public.futures_kline_daily ADD COLUMN IF NOT EXISTS symbol_id integer;

-- 2) 回填：按 (symbol_code, exchange_code) 两键匹配 symbol.id
--    （验证: 10863/10863 行可命中，无一对多歧义）
UPDATE public.futures_kline_daily f
SET symbol_id = s.id
FROM public.symbol s
WHERE s.symbol_code = f.exchange_code
  AND s.exchange_code = f.exchange;

-- 3) 加外键约束（引用 symbol 主键 id）
ALTER TABLE public.futures_kline_daily
ADD CONSTRAINT fk_futures_kline_daily_symbol
FOREIGN KEY (symbol_id) REFERENCES public.symbol(id);

-- 4) 建索引（FK 子表列，提升按品种 JOIN 的性能）
CREATE INDEX IF NOT EXISTS idx_futures_kline_daily_symbol_id
ON public.futures_kline_daily(symbol_id);
