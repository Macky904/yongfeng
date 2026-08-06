-- 来源：D:\期货手续费汇总表.xlsx（子表“期货手续费”）
-- 含义：symbol 表新增 exchange_fee 列（交易所基准手续费，文本），按 交易所+代码 回填内盘品种
-- 执行：psql "$DATABASE_URL" -f 01_add_exchange_fee.sql

ALTER TABLE public.symbol ADD COLUMN IF NOT EXISTS exchange_fee TEXT;
COMMENT ON COLUMN public.symbol.exchange_fee IS '交易所基准手续费(开仓/隔夜平仓)，文本类型；来源：期货手续费汇总表';

UPDATE public.symbol SET exchange_fee = '20 元/手' WHERE exchange_code = 'SHFE' AND symbol_code = 'AU';
UPDATE public.symbol SET exchange_fee = '成交金额万分之 0.5（0.05‰）' WHERE exchange_code = 'SHFE' AND symbol_code = 'AG';
UPDATE public.symbol SET exchange_fee = '成交金额万分之 0.5（0.05‰）' WHERE exchange_code = 'SHFE' AND symbol_code = 'CU';
UPDATE public.symbol SET exchange_fee = '3 元/手' WHERE exchange_code = 'SHFE' AND symbol_code = 'AL';
UPDATE public.symbol SET exchange_fee = '3 元/手' WHERE exchange_code = 'SHFE' AND symbol_code = 'ZN';
UPDATE public.symbol SET exchange_fee = '20 元/手' WHERE exchange_code = 'INE' AND symbol_code = 'SC';
UPDATE public.symbol SET exchange_fee = '成交金额万分之 0.1（0.1‱）' WHERE exchange_code = 'INE' AND symbol_code = 'BC';
UPDATE public.symbol SET exchange_fee = '成交金额万分之 1（1‱）；非 1/5/9 合约万分之 0.1' WHERE exchange_code = 'DCE' AND symbol_code = 'I';
