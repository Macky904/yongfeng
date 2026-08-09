-- ============================================================================
-- hedging_announcements 套保品种标准化 —— 最终落地（覆盖原字段）
-- 日期：2026-08-09
--
-- 背景：
--   01_add_commodity_standardized.sql 采用「新增 commodity_standardized 临时列」
--   的稳妥方案，供人工核对。核对通过后，业务确认【不保留额外字段】，
--   要求把标准化结果直接写回原 commodity，并删除该临时列。
--
-- 本文件即最终形态：表中只有 commodity 一个品种字段，内容已标准化。
--
-- 影响：13014 行有值中 875 行内容被覆盖（11 种取值）
--       2564 行 NULL 保持不变
--       去重取值数 75 种（映射前后同为 75，无取值合并）
-- ============================================================================


-- ############################################################################
-- 路径 A：已执行过 01（库中存在 commodity_standardized 列）—— 本次实际执行的就是这条
-- ############################################################################

-- --- A0. 执行前安全检查：必须返回 0 -----------------------------------------
-- 若 >0，说明存在「原 commodity 有值但标准化列为空」的行，
-- 直接覆盖会把这些行清空，必须先修复再执行。
SELECT count(*) AS must_be_zero
FROM public.hedging_announcements
WHERE (commodity IS NOT NULL AND commodity <> '')
  AND (commodity_standardized IS NULL OR commodity_standardized = '');

-- --- A1. 覆盖写回 -----------------------------------------------------------
UPDATE public.hedging_announcements
SET commodity = commodity_standardized
WHERE commodity_standardized IS NOT NULL
  AND commodity_standardized <> ''
  AND commodity IS DISTINCT FROM commodity_standardized;
-- 实际影响：875 行

-- --- A2. 覆盖后校验：必须返回 0（不通过则 ROLLBACK，不要往下执行 DROP）--------
SELECT count(*) AS must_be_zero
FROM public.hedging_announcements
WHERE commodity_standardized IS NOT NULL
  AND commodity_standardized <> ''
  AND commodity IS DISTINCT FROM commodity_standardized;

-- --- A3. 删除临时列 ---------------------------------------------------------
ALTER TABLE public.hedging_announcements
    DROP COLUMN IF EXISTS commodity_standardized;


-- ############################################################################
-- 路径 B：全新环境一步到位（库中没有 commodity_standardized 列，跳过 01 直接用这段）
-- ############################################################################
-- 逻辑与 01 完全等价，只是直接改 commodity。
-- 用「、」包裹前后再整词替换，避免误伤子串
--（例如「天然橡胶」不能被「橡胶→天然橡胶」二次替换成「天然天然橡胶」）。
--
-- UPDATE public.hedging_announcements
-- SET commodity = trim(BOTH '、' FROM
--       replace(
--         replace(
--           replace('、' || commodity || '、', '、PVC、',  '、聚氯乙烯、'),
--                                              '、橡胶、',  '、天然橡胶、'),
--                                              '、塑料、',  '、聚乙烯、')
--     )
-- WHERE commodity IS NOT NULL AND commodity <> '';


-- ============================================================================
-- 标准化规则速查（与 01 一致）
-- ============================================================================
--   别名映射（整词，仅这 3 条实际生效）：
--     PVC  -> 聚氯乙烯   （DCE V）
--     橡胶 -> 天然橡胶   （SHFE RU）
--     塑料 -> 聚乙烯     （DCE L）
--
--   白名单（保持原样，不映射到 symbol.name）：
--     外汇      8028 行  —— 不细分美元/欧元/日元，避免字段碎片化
--     大宗商品   161 行  —— 公告本身即为泛指
--     大豆      119 行  —— symbol.name 只有「黄大豆1号/黄大豆2号」，不强行二选一
--
--   组合品种：内部逐词标准化后仍用「、」拼接，保持公告原有出现顺序（不排序）
-- ============================================================================


-- ============================================================================
-- 执行结果验证（本次实际值已标注）
-- ============================================================================

-- 1) 字段确认：应只剩 commodity，无 commodity_standardized
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'hedging_announcements'
  AND column_name LIKE 'commodity%';
-- 实际：commodity | text

-- 2) 行数与取值数
SELECT count(*)                                                        AS total,        -- 15578
       count(*) FILTER (WHERE commodity IS NOT NULL AND commodity<>'') AS filled,       -- 13014
       count(DISTINCT commodity)                                       AS distinct_val  -- 75
FROM public.hedging_announcements;

-- 3) 别名残留校验：前三项必须为 0
SELECT count(*) FILTER (WHERE commodity LIKE '%PVC%')                  AS has_pvc,      -- 0
       count(*) FILTER (WHERE commodity LIKE '%塑料%')                  AS has_plastic,  -- 0
       count(*) FILTER (WHERE commodity ~ '(^|、)橡胶(、|$)')            AS bare_rubber,  -- 0
       count(*) FILTER (WHERE commodity LIKE '%天然橡胶%')               AS nat_rubber,   -- 306
       count(*) FILTER (WHERE commodity LIKE '%聚氯乙烯%')               AS pvc_std       -- 569
FROM public.hedging_announcements;

-- 4) 原子词对齐 symbol.name：未对齐的应只剩 3 个白名单词
SELECT t.tok,
       count(*) AS rows_cnt,
       (t.tok IN (SELECT name FROM public.symbol
                  WHERE exchange_code NOT LIKE '%期权%')) AS aligned
FROM public.hedging_announcements h,
     LATERAL unnest(string_to_array(h.commodity, '、')) AS t(tok)
WHERE h.commodity IS NOT NULL AND h.commodity <> ''
GROUP BY 1
ORDER BY 3, 2 DESC;
-- 实际：42 种原子词，39 种对齐；未对齐 3 种 = 外汇 / 大宗商品 / 大豆


-- ============================================================================
-- 回滚
-- ============================================================================
-- 本次为【原地覆盖】，原始值不在库内，只能从备份文件恢复：
--   backup_commodity_before_merge_2026-08-09.csv
--   （15578 行全量，含 id / announcement_id / stock_code / company_name /
--     announcement_date / commodity_原值 / commodity_standardized，仅存本地未入库）
--
-- 恢复示例：
--   CREATE TEMP TABLE t(id bigint, commodity_old text);
--   \copy t FROM 'backup_commodity_before_merge_2026-08-09.csv' CSV HEADER;
--   UPDATE public.hedging_announcements h
--   SET commodity = t.commodity_old FROM t WHERE h.id = t.id;


-- ============================================================================
-- 未处理事项（沿用 01 的结论，本次未变更）
-- ============================================================================
-- 1) 2564 行 commodity 为 NULL —— 保持不变。
--    实测：这些行的 announcement_title 中「外汇/汇率/结售汇」命中 0 次，
--    铜/铝/锌/镍/黄金等品种词同样全为 0，绝大多数是
--    「关于开展商品期货套期保值业务的公告」这类泛化标题。
--    仅 707 行含「商品/原材料」，可粗推为「大宗商品」（待业务决定是否填充）。
--    表中无正文字段（仅 pdf_url），要精确补全须下载并解析 PDF。
--
-- 2) 组合品种排序归并 —— 不做。
--    全表仅 1 组因顺序不同被拆开（聚氯乙烯、纯碱 26 行 / 纯碱、聚氯乙烯 12 行），
--    排序归并后去重值 75 -> 74，收益极小，且会丢失公告中的品种主次顺序。
--
-- 3) 增量更新脚本 04_incremental_update_postgres.py 的品种识别逻辑尚未同步这套
--    别名映射，新入库公告仍可能写入 PVC/橡胶/塑料。建议后续在识别环节加同一套
--    映射表，否则需定期重跑本文件的路径 B。
-- ============================================================================
