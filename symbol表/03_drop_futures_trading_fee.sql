-- =============================================================================
-- 03_drop_futures_trading_fee.sql
-- 用途：删除 public.symbol 表中两列待核验字段
-- 执行时间：2026-08-07
-- =============================================================================
--
-- 背景说明：
--   02_add_futures_trading_fee.sql 曾为 symbol 表新增两列：
--     - futures_trading_fee  期货交易手续费（208 个品种有值）
--     - futures_fee_source   费率数据来源官方链接（208 个品种有值）
--   经核查，该批费率数据仍处于待核验状态、暂不采用，故整列删除。
--   => 02_add_futures_trading_fee.sql 自本次起作废，请勿再执行。
--
-- 数据备份：
--   删除前已将 208 行完整导出为 CSV（symbol_code / name / exchange_code /
--   exchange_fee / futures_trading_fee / futures_fee_source），
--   文件名 backup_futures_trading_fee_2026-08-07.csv，保存在本地工作区，
--   未纳入本仓库。日后若费率核验通过，可据此重新建列回填。
--
-- 影响范围：
--   - 表总行数不变（318 行）
--   - exchange_fee 列（交易所手续费，8 个品种有值）保持不变，不受影响
-- =============================================================================

BEGIN;

ALTER TABLE public.symbol DROP COLUMN IF EXISTS futures_trading_fee;
ALTER TABLE public.symbol DROP COLUMN IF EXISTS futures_fee_source;

COMMIT;

-- -----------------------------------------------------------------------------
-- 验证：执行后应只剩 exchange_fee 一个 fee 相关字段
-- -----------------------------------------------------------------------------
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND table_name = 'symbol'
--   AND column_name LIKE '%fee%'
-- ORDER BY ordinal_position;
--
-- 预期结果：仅返回 exchange_fee | text
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- 回滚方式（若日后需要恢复这两列）：
--   1) 重新建列
--        ALTER TABLE public.symbol ADD COLUMN IF NOT EXISTS futures_trading_fee TEXT;
--        ALTER TABLE public.symbol ADD COLUMN IF NOT EXISTS futures_fee_source  TEXT;
--   2) 依据备份 CSV 或重新核验后的数据回填
--   注意：请勿直接重跑 02_add_futures_trading_fee.sql，其中费率尚未核验。
-- -----------------------------------------------------------------------------
