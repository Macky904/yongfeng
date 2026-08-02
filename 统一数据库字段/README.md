# 统一数据库字段

本项目用于统一 PostgreSQL/Supabase `public` schema 下所有业务表的自动字段。

## 功能

```text
created_time -> created_at
create_time  -> created_at
updated_time -> updated_at
update_time  -> updated_at
缺少 created_at 的表自动补 created_at
缺少 updated_at 的表自动补 updated_at
为每张表添加 updated_at 自动刷新触发器
```

## 使用方法

在 PowerShell 中执行：

```powershell
cd D:\yongfeng2\统一数据库字段
$env:DATABASE_URL='postgresql://postgres.xxxxx:你的密码@xxxxx.pooler.supabase.com:5432/postgres?sslmode=require'
python src\01_standardize_timestamp_columns.py
```

## 统一后的字段名

```text
created_at
updated_at
```

其中 `updated_at` 会在行记录更新时自动刷新为当前时间。
