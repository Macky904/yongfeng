-- 回补 hedging_announcements.commodity：标题无品种时回退读取 PDF 正文补抽
-- 生成时间：2026-08-11T19:18:28
-- 本批处理 30 条，补抽 27 条（其中读正文补出 27 条），仍空 3 条
-- 原则：只更新 commodity 为空的行，不覆盖已有值；正文也无明确品种的保持空，不硬猜。
begin;

update public.hedging_announcements set commodity='外汇' where announcement_id=1225468363;
update public.hedging_announcements set commodity='锡、白银' where announcement_id=1225459629;
update public.hedging_announcements set commodity='锡、白银' where announcement_id=1225459628;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225429848;
update public.hedging_announcements set commodity='镍' where announcement_id=1225429847;
update public.hedging_announcements set commodity='镍' where announcement_id=1225429846;
update public.hedging_announcements set commodity='黄金、白银' where announcement_id=1225424587;
update public.hedging_announcements set commodity='黄金、白银' where announcement_id=1225424586;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225422446;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225422445;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225406050;
update public.hedging_announcements set commodity='外汇、黄金' where announcement_id=1225370640;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225362849;
update public.hedging_announcements set commodity='外汇、铜、铝、热轧卷板' where announcement_id=1225362836;
update public.hedging_announcements set commodity='外汇、铝' where announcement_id=1225357761;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225323746;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225323745;
update public.hedging_announcements set commodity='外汇、原油' where announcement_id=1225316517;
update public.hedging_announcements set commodity='原油' where announcement_id=1225316516;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225307107;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225307103;
update public.hedging_announcements set commodity='铜' where announcement_id=1225301042;
update public.hedging_announcements set commodity='铜' where announcement_id=1225301041;
update public.hedging_announcements set commodity='外汇、纸浆、动力煤' where announcement_id=1225266916;
update public.hedging_announcements set commodity='豆油、大豆、玉米、菜籽油、棕榈油' where announcement_id=1225265761;
update public.hedging_announcements set commodity='豆油、大豆、玉米、菜籽油、棕榈油' where announcement_id=1225265750;
update public.hedging_announcements set commodity='外汇' where announcement_id=1225262837;

commit;