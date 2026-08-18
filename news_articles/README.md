# news_articles — 新闻 / 社交媒体监控

采集新闻 RSS / NewsAPI / GDELT / Twitter(X) 等来源，存入 Supabase PostgreSQL 的
`public.news_articles` 表，供舆情 / 事件监控使用。

## 表结构

DDL 见 [`01_create_news_articles.sql`](./01_create_news_articles.sql)（PostgreSQL）。
核心列：`title` / `content` / `ai_summary` / `source_url`(唯一) / `source_name` /
`author` / `topic` / `tags` / `impact_score` / `platform` / `raw_json`(jsonb) /
`pub_date` / `created_at` / `updated_at`(触发器维护)。

`platform` 取值预留：`twitter` / `news` / `rss` / `reddit` / `telegram` / `gdelt`。

## 推特抓取（逆向方案，免官方 API key）

脚本：[`src/01_crawl_twitter.py`](./src/01_crawl_twitter.py)

基于 [twscrape](https://github.com/vladkens/twscrape)——逆向 Twitter 移动端接口，
通过账号池模拟登录抓取，无需付费 API。

### 准备

```powershell
cd news_articles
python -m venv .venv && .venv\Scripts\Activate.ps1
pip install -r requirements.txt

# 1) 填账号：把 accounts.example.txt 复制为 accounts.txt 并填入 ≥1 个 Twitter 账号
# 2) 设置数据库连接串（与仓库其他子项目一致）
$env:DATABASE_URL="postgresql://postgres.xxxxx:密码@xxxxx.pooler.supabase.com:5432/postgres?sslmode=require"
```

### 监测账号配置

打开 [`src/01_crawl_twitter.py`](./src/01_crawl_twitter.py)，修改顶部监测名单：

```python
# 每天监测核心农业/大宗商品账号
CORE_MONITOR_USERS = ["kannbwx", "Tyne_Ag"]
# USDA、EIA、CFTC、NOAA CPC、干旱监测和 FAO 等官方账号按天轮换
ROTATING_MONITOR_USERS = ["USDA_NASS", "USDAFAS", "EIAgov", "CFTCgov", "NWSCPC", "DroughtMonitor", "FAO"]
```

脚本默认**增量监测**：每次只抓比库里该账号最新推文更晚的内容；
配合 `source_url`(推文永久链接) 唯一键，已入库的不会重复写入。

默认每天抓取两个核心账号和一个轮换官方账号（约 90 条请求上限），以适配免费
Twitter 登录身份的额度。可通过环境变量 `TWITTER_ROTATING_USERS_PER_RUN` 将轮换数调为 `0` 至 `7`。
没有稳定 RSS 的 USDA 作物进度、WASDE、NOAA/CPC 图表与美国干旱监测页面，保留为权威人工核验来源；
它们对应的官方 Twitter 更新会进入本监测名单。

**历史补抓**：首次运行（库里该账号尚无数据）会从 `START_DATE`(默认 `2026-01-01`) 起补抓，
`BACKFILL_LIMIT`(默认 150，适配免费账号常见额度) 控制单次上限。之后运行自动转增量（带 1 天重叠缓冲，防漏推文）。
若要改回溯起点，改脚本顶部 `START_DATE` 即可。

### 运行

```powershell
# 监测 MONITOR_USERS（默认 kannbwx），增量抓取
python src/01_crawl_twitter.py
# 监测模式，单次最多抓 100 条
python src/01_crawl_twitter.py 100
# 临时切到关键词搜索（不影响监测账号列表）
python src/01_crawl_twitter.py "原油 OR crude" 50

# 只回补 USDA/EIA/CFTC/NOAA/FAO 等官方账号自 2026-07-01 起的商品相关推文
python src/01_crawl_twitter.py --official-backfill
```

`--official-backfill` 可安全重复执行：每个账号以数据库内最新推文时间为水位线，
发生 X 限流时再次运行会续抓而不会重复入库。

写入时以 `source_url`(推文永久链接) 做唯一键，`on conflict` 时只更新正文，
不会重复入库。`impact_score` / `ai_summary` 留空，由后续 AI 分析步骤回填。

> 风险提示：抓取 Twitter 可能违反其服务条款，请仅用于个人研究，自负风险。
