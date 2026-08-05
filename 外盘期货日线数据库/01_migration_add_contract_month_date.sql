-- ============================================================================
-- 外盘期货日线数据库迁移：新增 contract_month_date 列
-- 目的：把月度合约代码中的字母月份（F=1月..Z=12月）解码成 DATE 字段，
--       便于按时间处理（老师的反馈意见）。
-- 范围：仅 D:\外盘数据\外盘期货日线数据库.sql → public.futures_kline_daily
-- 注意：
--   1. 本脚本是【抽样案例】配套的迁移方案，**未在数据库执行**。
--   2. 月度合约格式：[ExchangeCode][MonthLetter][4-digit-Year]，例 ZSH2026。
--      最后 4 位是年份，倒数第 5 位是月份字母。
--   3. 连续合约（以 ! 结尾，如 CBOT:ZC1!）没有固定月份，新列保持 NULL。
--   4. 执行前请备份，跑抽样案例核对后再上线。
-- ============================================================================

BEGIN;

-- 1) 新增 1 列（按老师"加一列、日期格式"的最小方案）
ALTER TABLE public.futures_kline_daily
    ADD COLUMN IF NOT EXISTS contract_month_date DATE;

COMMENT ON COLUMN public.futures_kline_daily.contract_month_date IS
    '月度合约的"该月第一天"，由 contract_code 倒数第5位字母月份+末4位年份解码而来；连续合约为 NULL';

-- 2) 回填月度合约
--    RIGHT(contract_code, 4)         → 年份字符串（如 '2026'）
--    LEFT(RIGHT(contract_code, 5),1) → 月份字母（如 'H' = 3月）
UPDATE public.futures_kline_daily
SET contract_month_date = MAKE_DATE(
        RIGHT(contract_code, 4)::SMALLINT,
        CASE LEFT(RIGHT(contract_code, 5), 1)
            WHEN 'F' THEN 1  WHEN 'G' THEN 2  WHEN 'H' THEN 3  WHEN 'J' THEN 4
            WHEN 'K' THEN 5  WHEN 'M' THEN 6  WHEN 'N' THEN 7  WHEN 'Q' THEN 8
            WHEN 'U' THEN 9  WHEN 'V' THEN 10 WHEN 'X' THEN 11 WHEN 'Z' THEN 12
        END,
        1  -- 月度合约月份的第一天
    )
WHERE contract_type = 'monthly'
  AND contract_month_date IS NULL;  -- 幂等：允许重复跑

-- 3) 连续合约保持 NULL（contract_code 以 ! 结尾），不动

-- 4) 抽样校验（执行完后人工 SELECT 几行确认）
--    SELECT contract_code, contract_month_date
--    FROM public.futures_kline_daily
--    WHERE contract_type = 'monthly'
--    ORDER BY contract_code, trade_date
--    LIMIT 20;

COMMIT;