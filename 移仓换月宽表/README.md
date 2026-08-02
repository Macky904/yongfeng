# 移仓换月宽表

本项目用于从 PostgreSQL/Supabase 拉取“移仓换月宽表”，并导出为本地 CSV 文件，便于备份、检查和后续提交归档。

## 目录

```text
移仓换月宽表/
  src/
    01_export_postgres_table.py
    02_add_auto_columns.py
  exports/
  requirements.txt
```

## 使用方法

### 1. 补充数据库自动字段

在 PowerShell 中执行：

```powershell
cd D:\yongfeng2\移仓换月宽表
$env:DATABASE_URL='postgresql://postgres.xxxxx:你的密码@xxxxx.pooler.supabase.com:5432/postgres?sslmode=require'
$env:PG_TABLE='public.你的表名'
python src\02_add_auto_columns.py
```

该脚本会给 PostgreSQL 表补充：

```text
id：自动增长主键
created_at：写入时自动记录创建时间
updated_at：写入时自动记录，更新时自动刷新
```

### 2. 导出本地 CSV

在 PowerShell 中执行：

```powershell
cd D:\yongfeng2\移仓换月宽表
$env:DATABASE_URL='postgresql://postgres.xxxxx:你的密码@xxxxx.pooler.supabase.com:5432/postgres?sslmode=require'
$env:PG_TABLE='public.你的表名'
python src\01_export_postgres_table.py
```

如果不设置 `$env:PG_TABLE`，脚本默认读取：

```text
public.移仓换月宽表
```

导出结果：

```text
exports/移仓换月宽表.csv
```

## 说明

- `DATABASE_URL`：PostgreSQL/Supabase 连接地址。
- `PG_TABLE`：要导出的表名，支持 `schema.table` 格式。
- 脚本会自动读取字段名并保留原始列顺序。
