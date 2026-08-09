-- ============================================================================
-- hedging_announcements 套保品种标准化
-- 日期：2026-08-09
-- 目标：把 commodity 对齐 public.symbol.name 标准品种名
--
-- 设计原则：
--   1. 只保留【一个字段】，不做两级分类
--   2. 组合品种仍用「、」拼接，但内部每个名称先标准化
--   3. 保持公告原有的品种出现顺序（不排序，以保留主次信息）
--   4. 新增 commodity_standardized 字段，【原 commodity 完全不动】
--
-- 影响：15578 行中 13014 行有值 → 全部写入新字段，其中 875 行内容发生变化
--       2564 行 commodity 为 NULL → 新字段同样保持 NULL（见文件末尾说明）
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. 新增标准化字段
-- ---------------------------------------------------------------------------
ALTER TABLE public.hedging_announcements
    ADD COLUMN IF NOT EXISTS commodity_standardized TEXT;

COMMENT ON COLUMN public.hedging_announcements.commodity_standardized IS
    '标准化套保品种，对齐 public.symbol.name；多品种用、拼接；外汇类统一为「外汇」';


-- ---------------------------------------------------------------------------
-- 2. 先整体复制一份（未命中别名规则的值保持原样）
-- ---------------------------------------------------------------------------
UPDATE public.hedging_announcements
SET commodity_standardized = commodity
WHERE commodity IS NOT NULL AND commodity <> '';


-- ---------------------------------------------------------------------------
-- 3. 别名标准化（对齐 symbol.name）
--    PVC  → 聚氯乙烯 (DCE V)
--    橡胶 → 天然橡胶 (SHFE RU)
--    塑料 → 聚乙烯   (DCE L)
--
--    用「、」包边界做整词替换，避免误伤「天然橡胶」「丁二烯橡胶」等已标准的名称
-- ---------------------------------------------------------------------------
UPDATE public.hedging_announcements
SET commodity_standardized = trim(BOTH '、' FROM
        replace(
        replace(
        replace('、' || commodity_standardized || '、',
                '、PVC、',  '、聚氯乙烯、'),
                '、橡胶、',  '、天然橡胶、'),
                '、塑料、',  '、聚乙烯、')
    )
WHERE commodity_standardized IS NOT NULL
  AND (   commodity_standardized ~ '(^|、)PVC(、|$)'
       OR commodity_standardized ~ '(^|、)橡胶(、|$)'
       OR commodity_standardized ~ '(^|、)塑料(、|$)' );


-- ---------------------------------------------------------------------------
-- 4. 验证
-- ---------------------------------------------------------------------------
-- 4.1 行数应为 13014，且原字段有值的行新字段不得为空
-- SELECT count(*) FILTER (WHERE commodity_standardized IS NOT NULL AND commodity_standardized<>'') AS filled,
--        count(*) FILTER (WHERE commodity IS NOT NULL AND commodity<>''
--                           AND (commodity_standardized IS NULL OR commodity_standardized='')) AS missing
-- FROM public.hedging_announcements;

-- 4.2 新字段不应再出现 PVC / 塑料 / 独立词「橡胶」（均应为 0）
-- SELECT count(*) FILTER (WHERE commodity_standardized LIKE '%PVC%')            AS pvc,
--        count(*) FILTER (WHERE commodity_standardized LIKE '%塑料%')           AS plastic,
--        count(*) FILTER (WHERE commodity_standardized ~ '(^|、)橡胶(、|$)')    AS rubber
-- FROM public.hedging_announcements;

-- 4.3 查看发生变化的行（应为 875 行）
-- SELECT commodity, commodity_standardized, count(*)
-- FROM public.hedging_announcements
-- WHERE commodity <> commodity_standardized
-- GROUP BY 1,2 ORDER BY 3 DESC;

-- 4.4 拆开后校验原子词是否都能对齐 symbol.name
-- SELECT t.tok, count(*) AS rows_cnt,
--        (t.tok IN (SELECT name FROM public.symbol WHERE exchange_code NOT LIKE '%期权%')) AS in_symbol
-- FROM public.hedging_announcements h,
--      LATERAL unnest(string_to_array(h.commodity_standardized, '、')) AS t(tok)
-- WHERE h.commodity_standardized IS NOT NULL AND h.commodity_standardized <> ''
-- GROUP BY 1 ORDER BY 2 DESC;


-- ============================================================================
-- 已知未处理事项（需人工决策后再补）
-- ============================================================================
-- [1] 2564 行 commodity 为 NULL，本次保持 NULL 未做推断填充。
--     原因：这些公告标题里【没有品种信息】——实测「外汇/汇率/结售汇」命中 0 次，
--     「铜/铝/锌/镍/锡/黄金」等品种词也全部为 0，标题清一色是
--     「关于开展商品期货套期保值业务的公告」这类泛化表述。
--     可粗略推断的只有 707 行（标题含「商品期货/原材料」→ 大宗商品）。
--     若要真正补全，需下载 pdf_url 解析正文，成本较高。
--
-- [2] 组合品种未做排序归并。
--     全表仅 1 组因顺序不同被拆开（「聚氯乙烯、纯碱」26 行 /「纯碱、聚氯乙烯」12 行），
--     排序后去重值 75 → 74，收益极小，且会丢失公告里的品种主次顺序，故不做。
--
-- [3] 「大豆」未映射。symbol.name 中只有「黄大豆1号」「黄大豆2号」，
--     无法判断公告指向哪个，按约定不强行二选一，保留原值（119 行）。
--
-- [4] 「大宗商品」（161 行）为泛指，公告未写明具体品种，保留原值。
--
-- [5] 「外汇」（8028 行）按约定统一，不细分美元/欧元/日元等币种。


-- ============================================================================
-- 回滚
-- ============================================================================
-- ALTER TABLE public.hedging_announcements DROP COLUMN IF EXISTS commodity_standardized;
-- 注：原 commodity 字段全程未修改，无需回滚。
