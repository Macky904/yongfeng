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

## 3. 手续费字段（exchange_fee）

`symbol` 表用 **`exchange_fee`（TEXT）** 一个字段存放交易所交易手续费，
口径为**交易所/清算机构公布的一手（每边）交易手续费**，不含期货公司佣金、
税费、交割费、申报费等另行费用。

SQL 脚本按序号演进，执行顺序即文件名顺序：

| 文件 | 作用 | 状态 |
| --- | --- | --- |
| `01_add_exchange_fee.sql` | 新增 `exchange_fee` 列，回填内盘 8 个品种 | 有效 |
| `02_add_futures_trading_fee.sql` | 曾新增 `futures_trading_fee`/`futures_fee_source` 两列（全网搜集、未经核验） | **已作废，勿执行** |
| `03_drop_futures_trading_fee.sql` | 删除上述两列 | 有效 |
| `04_update_exchange_fee_verified.sql` | 用人工核验表回填 206 个品种的 `exchange_fee` | 有效（当前） |

数据覆盖情况（截至 `04` 执行后）：

```text
总计         318 行
期货品种     208 个 —— exchange_fee 全部已填
期权品种     110 个 —— 按约定不填手续费，保持 NULL
```

`04` 的数据源为经交易所官网 PDF/XLSX 逐项复核的
`data/期货交易手续费明细_手续费字段精简版.xlsx`，该文件随仓库存档，
内含每个品种的核验状态、核对说明与官方来源链接。

其中两个品种保留了比核验表更完整的原有表述，`04` 不覆盖：

```text
SC (INE 原油)    一般交易20元/手，套保10元/手
I  (DCE 铁矿石)  成交金额万分之 1（1‱）；非 1/5/9 合约万分之 0.1
```

> 注：部分 NYMEX/COMEX 品种的费率官方标注 **2026-08-17** 起生效，已按当前
> 公布值写入，届时如有调整需重新核对。

## 说明

- `DATABASE_URL`：PostgreSQL/Supabase 连接地址。
- `PG_TABLE`：要处理的表名，支持 `schema.table` 格式。
- 默认表名是 `public.symbol`。
