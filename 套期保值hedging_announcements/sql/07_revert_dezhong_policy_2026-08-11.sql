-- 回退 1225468363（德众汽车管理制度）：正文仅泛列品种要素，无具体套保品种，保持空
-- 依据：主公告1225468356/可行性报告1225468361已明确为碳酸锂，管理制度为框架文件不单列品种
begin;
update public.hedging_announcements set commodity=NULL where announcement_id=1225468363;
commit;
