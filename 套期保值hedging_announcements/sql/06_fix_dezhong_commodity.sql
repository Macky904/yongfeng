-- 修复 德众汽车(2026-08-11)套期保值品种：公告正文明确为碳酸锂，原抽取只扫标题导致 commodity 为空
-- 来源：巨潮 PDF 正文（1225468356 主公告 / 1225468361 可行性报告）
-- 注：1225468363 为管理制度，无具体品种，保持 NULL

UPDATE hedging_announcements SET commodity = '碳酸锂' WHERE announcement_id = 1225468356;
UPDATE hedging_announcements SET commodity = '碳酸锂' WHERE announcement_id = 1225468361;
