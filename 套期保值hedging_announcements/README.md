# 套期保值公告数据库

本项目用于采集 A 股上市公司在巨潮资讯网披露的“套期保值”相关公告，并整理成可导入 PostgreSQL 的数据库结构。

## 目录

```text
套期保值hedging_announcements/
  src/
    01_crawl_cninfo_hedging.py
    02_enrich_and_build_database.py
  data/
    raw_cninfo_announcements.sqlite
    hedging_announcements.sqlite
  exports/
    hedging_announcements_2010_to_2026.csv
    hedging_announcements_2010_to_2026.sql
  requirements.txt
```

## 两个任务

### 1. 爬取套期保值公告

```powershell
python src\01_crawl_cninfo_hedging.py
```

输出：

```text
data/raw_cninfo_announcements.sqlite
raw/cninfo_hedging_raw.jsonl
```

采集字段包括公告 ID、公告日期、股票代码、公司名称、公告标题、PDF 直链等。

### 2. 补省份、行业、品种并生成最终数据库

```powershell
python src\02_enrich_and_build_database.py
```

输出：

```text
data/hedging_announcements.sqlite
exports/hedging_announcements_2010_to_2026.csv
exports/hedging_announcements_2010_to_2026.sql
```

最终表只保留数据库字段，不包含早期 Excel 方案中的 `crawl_keyword`、`parse_status`、`source`。

## 最终表结构

表名：

```sql
hedging_announcements
```

字段：

```text
id
announcement_id
announcement_date
stock_code
company_name
industry
province
announcement_title
pdf_url
commodity
created_at
updated_at
```

约束：

- `id`：主键，按公告日期升序从 1 开始编号。
- `announcement_id`：巨潮公告 ID，数字类型，唯一。
- `stock_code`：股票代码，保留 6 位文本格式，避免丢失前导 0。
- `province`：只能是中国省级行政单位，无法判断时为空。
- `created_at`：数据库记录创建时间，写入时由 PostgreSQL 自动记录。
- `updated_at`：数据库记录修改时间，写入时自动记录，后续更新该行时由触发器自动刷新。

## 当前数据

当前已生成数据范围：

```text
2010-01-04 至 2026-08-01
共 15,560 条公告
```

PostgreSQL 导入文件：

```text
exports/hedging_announcements_2010_to_2026.sql
```
