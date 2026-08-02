# symbol 表

本项目用于从 PostgreSQL/Supabase 拉取 `symbol` 表，导出为本地 CSV，并补充数据库自动字段。

## 目录

```text
symbol表/
  src/
    01_export_postgres_table.py
    02_add_auto_columns.py
  exports/
  requirements.txt
```

## 1. 补充数据库自动字段

在 PowerShell 中执行：

```powershell
cd D:\yongfeng2\symbol表
$env:DATABASE_URL='postgresql://postgres.xxxxx:你的密码@xxxxx.pooler.supabase.com:5432/postgres?sslmode=require'
$env:PG_TABLE='public.symbol'
python src\02_add_auto_columns.py
```

该脚本会给 PostgreSQL 表补充：

```text
id：自动增长主键
created_at：写入时自动记录创建时间
updated_at：写入时自动记录，更新时自动刷新
```

## 2. 导出本地 CSV

在 PowerShell 中执行：

```powershell
cd D:\yongfeng2\symbol表
$env:DATABASE_URL='postgresql://postgres.xxxxx:你的密码@xxxxx.pooler.supabase.com:5432/postgres?sslmode=require'
$env:PG_TABLE='public.symbol'
python src\01_export_postgres_table.py
```

导出结果：

```text
exports/symbol.csv
```

## 说明

- `DATABASE_URL`：PostgreSQL/Supabase 连接地址。
- `PG_TABLE`：要处理的表名，支持 `schema.table` 格式。
- 默认表名是 `public.symbol`。
