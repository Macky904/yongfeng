import csv
import re
import sqlite3
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Set, Tuple

import requests


BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"
EXPORT_DIR = BASE_DIR / "exports"
RAW_DB_PATH = DATA_DIR / "raw_cninfo_announcements.sqlite"
FINAL_DB_PATH = DATA_DIR / "hedging_announcements.sqlite"
CSV_PATH = EXPORT_DIR / "hedging_announcements_2010_to_2026.csv"
SQL_PATH = EXPORT_DIR / "hedging_announcements_2010_to_2026.sql"

START_DATE = "2010-01-01"
END_DATE = "2026-12-31"

VALID_PROVINCES = [
    "北京", "天津", "上海", "重庆", "河北", "山西", "辽宁", "吉林", "黑龙江", "江苏",
    "浙江", "安徽", "福建", "江西", "山东", "河南", "湖北", "湖南", "广东", "海南",
    "四川", "贵州", "云南", "陕西", "甘肃", "青海", "台湾", "内蒙古", "广西", "西藏",
    "宁夏", "新疆", "香港", "澳门",
]

CITY_TO_PROVINCE = {
    "石家庄": "河北", "唐山": "河北", "保定": "河北", "太原": "山西", "沈阳": "辽宁",
    "大连": "辽宁", "长春": "吉林", "哈尔滨": "黑龙江", "南京": "江苏", "苏州": "江苏",
    "无锡": "江苏", "常州": "江苏", "南通": "江苏", "杭州": "浙江", "宁波": "浙江",
    "温州": "浙江", "嘉兴": "浙江", "绍兴": "浙江", "合肥": "安徽", "芜湖": "安徽",
    "福州": "福建", "厦门": "福建", "泉州": "福建", "南昌": "江西", "济南": "山东",
    "青岛": "山东", "烟台": "山东", "潍坊": "山东", "郑州": "河南", "洛阳": "河南",
    "武汉": "湖北", "宜昌": "湖北", "长沙": "湖南", "株洲": "湖南", "广州": "广东",
    "深圳": "广东", "珠海": "广东", "佛山": "广东", "东莞": "广东", "中山": "广东",
    "惠州": "广东", "海口": "海南", "成都": "四川", "绵阳": "四川", "贵阳": "贵州",
    "昆明": "云南", "西安": "陕西", "兰州": "甘肃", "西宁": "青海", "呼和浩特": "内蒙古",
    "包头": "内蒙古", "南宁": "广西", "柳州": "广西", "拉萨": "西藏", "银川": "宁夏",
    "乌鲁木齐": "新疆",
}

COMMODITY_ALIASES: Dict[str, List[str]] = {
    "外汇": ["外汇", "汇率", "远期结售汇", "远期外汇", "外汇远期", "美元", "欧元", "日元", "港币"],
    "铜": ["铜", "铜材", "阴极铜", "电解铜", "沪铜", "铜精矿"],
    "铝": ["铝", "氧化铝", "电解铝", "铝锭", "铝材", "沪铝"],
    "锌": ["锌", "锌锭", "锌精矿", "沪锌"],
    "铅": ["铅", "铅锭", "沪铅"],
    "镍": ["镍", "镍铁", "硫酸镍", "沪镍"],
    "锡": ["锡", "锡锭", "沪锡"],
    "黄金": ["黄金", "金锭", "沪金"],
    "白银": ["白银", "银锭", "沪银"],
    "原油": ["原油"],
    "燃料油": ["燃料油", "低硫燃料油"],
    "PTA": ["PTA", "精对苯二甲酸"],
    "乙二醇": ["乙二醇", "MEG"],
    "甲醇": ["甲醇"],
    "聚乙烯": ["聚乙烯", "LLDPE", "PE"],
    "聚丙烯": ["聚丙烯", "PP"],
    "PVC": ["PVC", "聚氯乙烯"],
    "纯碱": ["纯碱"],
    "玻璃": ["玻璃"],
    "尿素": ["尿素"],
    "橡胶": ["橡胶", "天然橡胶"],
    "纸浆": ["纸浆"],
    "螺纹钢": ["螺纹钢", "螺纹"],
    "热轧卷板": ["热轧卷板", "热卷"],
    "铁矿石": ["铁矿石", "铁矿"],
    "焦煤": ["焦煤"],
    "焦炭": ["焦炭"],
    "动力煤": ["动力煤"],
    "碳酸锂": ["碳酸锂"],
    "工业硅": ["工业硅"],
    "棉花": ["棉花", "皮棉"],
    "白糖": ["白糖", "食糖"],
    "豆粕": ["豆粕"],
    "豆油": ["豆油"],
    "大豆": ["大豆", "黄大豆", "豆一", "豆二"],
    "玉米": ["玉米"],
    "菜粕": ["菜粕"],
    "菜籽油": ["菜籽油", "菜油"],
    "棕榈油": ["棕榈油", "棕油"],
    "鸡蛋": ["鸡蛋"],
    "生猪": ["生猪"],
    "苹果": ["苹果"],
    "红枣": ["红枣"],
    "花生": ["花生"],
}

COMPANY_RULES: List[Tuple[List[str], str]] = [
    (["海大集团", "正虹科技", "禾丰", "唐人神", "新希望"], "豆粕、玉米"),
    (["神农集团", "牧原", "温氏", "罗牛山"], "生猪、豆粕、玉米"),
    (["湘佳股份", "益生股份", "民和股份", "圣农发展"], "鸡蛋、豆粕、玉米"),
    (["冠农股份"], "白糖、棉花"),
    (["三友化工"], "纯碱、PVC"),
    (["中泰化学", "氯碱化工", "新疆天业"], "PVC、纯碱"),
    (["宁德时代", "天奈科技", "鹏辉能源", "亿纬锂能"], "碳酸锂、镍、铜、铝"),
    (["亨通光电", "中天科技", "精达股份", "金杯电工"], "铜、铝"),
    (["安徽建工"], "螺纹钢、热轧卷板"),
    (["中曼石油", "中国石油", "中国石化"], "原油、燃料油"),
    (["元创股份", "赛轮轮胎", "玲珑轮胎"], "橡胶"),
    (["江西铜业", "云南铜业", "铜陵有色"], "铜"),
    (["锡业股份"], "锡"),
    (["山东黄金", "中金黄金", "赤峰黄金", "紫金矿业"], "黄金、白银"),
]

INDUSTRY_RULES: Dict[str, str] = {
    "饲料": "豆粕、玉米",
    "养殖业": "生猪、豆粕、玉米",
    "农产品加工": "大豆、豆粕、豆油、玉米",
    "食品加工": "白糖、豆油、棕榈油",
    "工业金属": "铜、铝、锌、铅、镍、锡",
    "贵金属": "黄金、白银",
    "电池": "碳酸锂、镍、铜、铝",
    "光伏设备": "工业硅、铜、铝",
    "电网设备": "铜、铝",
    "电机Ⅱ": "铜、铝",
    "通信设备": "铜、铝",
    "汽车零部件": "铝、铜、橡胶、塑料",
    "塑料": "聚乙烯、聚丙烯、PVC",
    "橡胶": "橡胶",
    "化学纤维": "PTA、乙二醇",
    "纺织制造": "棉花、PTA、乙二醇",
    "包装印刷": "纸浆、聚乙烯、聚丙烯",
    "化学原料": "纯碱、PVC、甲醇",
    "化学制品": "甲醇、纯碱、尿素",
    "农化制品": "尿素、甲醇",
    "炼化及贸易": "原油、燃料油、PTA",
    "油服工程": "原油",
    "普钢": "铁矿石、焦煤、焦炭、螺纹钢、热轧卷板",
    "基础建设": "螺纹钢、热轧卷板",
    "装修建材": "玻璃、PVC、铝",
    "电力": "动力煤",
    "贸易Ⅱ": "大宗商品",
    "物流": "大宗商品",
}

EASTMONEY_URL = "https://push2.eastmoney.com/api/qt/clist/get"
EASTMONEY_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126.0 Safari/537.36",
    "Referer": "https://quote.eastmoney.com/center/gridlist.html",
}

FINAL_COLUMNS = [
    "id", "announcement_id", "announcement_date", "stock_code", "company_name",
    "industry", "province", "announcement_title", "pdf_url", "commodity",
    "created_at", "updated_at",
]


def normalize_text(*parts: str) -> str:
    return re.sub(r"\s+", "", "".join(part or "" for part in parts))


def detect_province(text: str) -> str:
    for province in VALID_PROVINCES:
        if province in text:
            return province
    for city, province in CITY_TO_PROVINCE.items():
        if city in text:
            return province
    return ""


def detect_commodities(text: str) -> str:
    found: Set[str] = set()
    upper_text = text.upper()
    for commodity, aliases in COMMODITY_ALIASES.items():
        for alias in aliases:
            if re.search(r"[A-Za-z]", alias):
                pattern = rf"(?<![A-Z]){re.escape(alias.upper())}(?![A-Z])"
                if re.search(pattern, upper_text):
                    found.add(commodity)
                    break
            elif alias in text:
                found.add(commodity)
                break
    return "、".join(name for name in COMMODITY_ALIASES if name in found)


def infer_commodity(company_name: str, industry: str, title: str) -> str:
    text = normalize_text(company_name, title)
    direct = detect_commodities(text)
    if direct:
        return direct
    for keys, commodity in COMPANY_RULES:
        if any(key in text for key in keys):
            return commodity
    if "钢材" in (title or ""):
        return "螺纹钢、热轧卷板"
    if industry in INDUSTRY_RULES:
        return INDUSTRY_RULES[industry]
    for key, commodity in INDUSTRY_RULES.items():
        if key in (industry or ""):
            return commodity
    return ""


def fetch_region_industry() -> Dict[str, Dict[str, str]]:
    session = requests.Session()
    result: Dict[str, Dict[str, str]] = {}
    page = 1
    total = None
    while True:
        params = {
            "pn": str(page),
            "pz": "100",
            "po": "1",
            "np": "1",
            "ut": "bd1d9ddb04089700cf9c27f6f7426281",
            "fltt": "2",
            "invt": "2",
            "fid": "f3",
            "fs": "m:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23,m:0+t:81+s:2048",
            "fields": "f12,f14,f100,f102",
        }
        response = None
        last_error = None
        for attempt in range(1, 6):
            try:
                response = session.get(EASTMONEY_URL, params=params, headers=EASTMONEY_HEADERS, timeout=30)
                response.raise_for_status()
                break
            except Exception as exc:
                last_error = exc
                time.sleep(min(2 ** attempt, 20))
        if response is None:
            raise RuntimeError(f"Eastmoney page {page} failed: {last_error}")
        data = response.json().get("data") or {}
        total = total or int(data.get("total") or 0)
        rows = data.get("diff") or []
        if not rows:
            break
        for row in rows:
            code = row.get("f12")
            if not code:
                continue
            result[code] = {
                "industry": row.get("f100") or "",
                "province": (row.get("f102") or "").replace("板块", "").strip(),
            }
        if len(result) >= total:
            break
        page += 1
        time.sleep(0.15)
    return result


def load_cached_region_industry() -> Dict[str, Dict[str, str]]:
    if not FINAL_DB_PATH.exists():
        return {}
    conn = sqlite3.connect(FINAL_DB_PATH)
    rows = conn.execute(
        """
        select stock_code, max(industry), max(province)
        from hedging_announcements
        where stock_code is not null
        group by stock_code
        """
    ).fetchall()
    conn.close()
    return {
        stock_code: {"industry": industry or "", "province": province or ""}
        for stock_code, industry, province in rows
    }


def create_final_db(rows: List[Dict]) -> None:
    if FINAL_DB_PATH.exists():
        FINAL_DB_PATH.unlink()
    conn = sqlite3.connect(FINAL_DB_PATH)
    conn.execute(
        """
        create table hedging_announcements (
            id integer primary key,
            announcement_id integer not null unique,
            announcement_date text not null,
            stock_code text check (stock_code is null or stock_code glob '[0-9][0-9][0-9][0-9][0-9][0-9]'),
            company_name text,
            industry text,
            province text check (
                province is null or province in (
                    '北京','天津','上海','重庆','河北','山西','辽宁','吉林','黑龙江','江苏',
                    '浙江','安徽','福建','江西','山东','河南','湖北','湖南','广东','海南',
                    '四川','贵州','云南','陕西','甘肃','青海','台湾','内蒙古','广西','西藏',
                    '宁夏','新疆','香港','澳门'
                )
            ),
            announcement_title text not null,
            pdf_url text not null,
            commodity text,
            created_at text not null default (datetime('now')),
            updated_at text not null default (datetime('now'))
        )
        """
    )
    conn.execute(
        """
        create trigger set_hedging_announcements_updated_at
        after update on hedging_announcements
        for each row
        when new.updated_at = old.updated_at
        begin
            update hedging_announcements
            set updated_at = datetime('now')
            where id = old.id;
        end
        """
    )
    conn.executemany(
        """
        insert into hedging_announcements (
            id, announcement_id, announcement_date, stock_code, company_name,
            industry, province, announcement_title, pdf_url, commodity
        ) values (
            :id, :announcement_id, :announcement_date, :stock_code, :company_name,
            :industry, :province, :announcement_title, :pdf_url, :commodity
        )
        """,
        rows,
    )
    conn.commit()
    conn.close()


def sql_literal(value):
    if value is None or value == "":
        return "NULL"
    return "'" + str(value).replace("'", "''") + "'"


def write_csv(rows: List[Dict]) -> None:
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    with CSV_PATH.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=FINAL_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)


def write_postgres_sql(rows: List[Dict]) -> None:
    provinces = ", ".join(sql_literal(value) for value in sorted(VALID_PROVINCES))
    header = f"""BEGIN;

DROP TABLE IF EXISTS public.hedging_announcements;

CREATE TABLE public.hedging_announcements (
    id INTEGER PRIMARY KEY,
    announcement_id BIGINT NOT NULL UNIQUE,
    announcement_date DATE NOT NULL,
    stock_code CHAR(6) CHECK (stock_code IS NULL OR stock_code ~ '^[0-9]{{6}}$'),
    company_name TEXT,
    industry TEXT,
    province TEXT CHECK (province IS NULL OR province IN ({provinces})),
    announcement_title TEXT NOT NULL,
    pdf_url TEXT NOT NULL,
    commodity TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.set_hedging_announcements_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_hedging_announcements_updated_at
BEFORE UPDATE ON public.hedging_announcements
FOR EACH ROW
EXECUTE FUNCTION public.set_hedging_announcements_updated_at();

"""
    chunks = []
    for start in range(0, len(rows), 400):
        values = []
        for row in rows[start:start + 400]:
            values.append(
                "("
                + ", ".join(
                    [
                        str(row["id"]),
                        str(row["announcement_id"]),
                        sql_literal(row["announcement_date"]),
                        sql_literal(row["stock_code"]),
                        sql_literal(row["company_name"]),
                        sql_literal(row["industry"]),
                        sql_literal(row["province"]),
                        sql_literal(row["announcement_title"]),
                        sql_literal(row["pdf_url"]),
                        sql_literal(row["commodity"]),
                    ]
                )
                + ")"
            )
        chunks.append(
            "INSERT INTO public.hedging_announcements "
            "(id, announcement_id, announcement_date, stock_code, company_name, industry, province, announcement_title, pdf_url, commodity)\n"
            "VALUES\n"
            + ",\n".join(values)
            + ";\n\n"
        )
    footer = f"""CREATE INDEX idx_hedging_announcements_date ON public.hedging_announcements (announcement_date);
CREATE INDEX idx_hedging_announcements_stock_code ON public.hedging_announcements (stock_code);
CREATE INDEX idx_hedging_announcements_industry ON public.hedging_announcements (industry);
CREATE INDEX idx_hedging_announcements_province ON public.hedging_announcements (province);

COMMIT;

-- SELECT count(*) FROM public.hedging_announcements;
-- 本文件包含 {len(rows)} 条公告。
"""
    SQL_PATH.write_text(header + "".join(chunks) + footer, encoding="utf-8")


def load_raw_rows() -> List[sqlite3.Row]:
    conn = sqlite3.connect(RAW_DB_PATH)
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        """
        select *
        from raw_announcements
        where announcement_date >= ?
          and announcement_date <= ?
        order by announcement_date asc, announcement_time_ms asc, announcement_id asc
        """,
        (START_DATE, END_DATE),
    ).fetchall()
    conn.close()
    return rows


def build() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    try:
        market_info = fetch_region_industry()
    except Exception as exc:
        market_info = load_cached_region_industry()
        if not market_info:
            raise
        print(f"used_cached_region_industry=true reason={exc}")
    raw_rows = load_raw_rows()
    final_rows: List[Dict] = []

    build_timestamp = datetime.now().astimezone().isoformat(timespec="seconds")

    for idx, row in enumerate(raw_rows, start=1):
        stock_code = row["stock_code"] or None
        info = market_info.get(stock_code or "", {})
        industry = info.get("industry") or None
        if industry == "-":
            industry = None
        province = info.get("province") or detect_province(normalize_text(row["company_name"], row["announcement_title"])) or None
        if province not in VALID_PROVINCES:
            province = None
        commodity = infer_commodity(row["company_name"], industry or "", row["announcement_title"]) or None
        final_rows.append(
            {
                "id": idx,
                "announcement_id": int(row["announcement_id"]),
                "announcement_date": row["announcement_date"],
                "stock_code": stock_code,
                "company_name": row["company_name"] or None,
                "industry": industry,
                "province": province,
                "announcement_title": row["announcement_title"],
                "pdf_url": row["pdf_url"],
                "commodity": commodity,
                "created_at": build_timestamp,
                "updated_at": build_timestamp,
            }
        )

    create_final_db(final_rows)
    write_csv(final_rows)
    write_postgres_sql(final_rows)
    print(f"rows={len(final_rows)}")
    print(f"database={FINAL_DB_PATH}")
    print(f"csv={CSV_PATH}")
    print(f"postgres_sql={SQL_PATH}")


if __name__ == "__main__":
    build()
