-- ============================================================
-- 期货新闻资讯 数据库设计 (MySQL 8.0+)
-- 用途：把每天抓到的期货新闻/资讯存进数据库，方便按
--       品种、时间、情绪 来查询和统计。
-- 说明：表名、字段都带中文注释，方便理解。
-- ============================================================

-- 1) 期货品种/合约表：列出有哪些期货可以关注
-- ------------------------------------------------------------
DROP TABLE IF EXISTS futures_instrument;
CREATE TABLE futures_instrument (
    instrument_code   VARCHAR(20)  NOT NULL COMMENT '品种代码，如 AU(沪金) CU(沪铜) RB(螺纹)',
    instrument_name   VARCHAR(50)  NOT NULL COMMENT '品种名称',
    exchange          VARCHAR(20)  COMMENT '交易所：SHFE 上期所 / DCE 大商所 / CZCE 郑商所 / CFFEX 中金所',
    category          VARCHAR(20)  COMMENT '类别：金属/能源/农产品/化工/金融',
    PRIMARY KEY (instrument_code)
) COMMENT='期货品种字典表';

-- 2) 新闻资讯主表：一条新闻存一行
-- ------------------------------------------------------------
DROP TABLE IF EXISTS futures_news;
CREATE TABLE futures_news (
    news_id        BIGINT        NOT NULL AUTO_INCREMENT COMMENT '新闻编号(主键)',
    title          VARCHAR(200)  NOT NULL COMMENT '新闻标题',
    content        TEXT          COMMENT '新闻正文',
    source         VARCHAR(50)   COMMENT '来源，如 金十数据/同花顺/新浪财经',
    author         VARCHAR(50)   COMMENT '作者',
    url            VARCHAR(500)  COMMENT '原文链接',
    publish_time   DATETIME      NOT NULL COMMENT '发布时间',
    created_at     DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '入库时间',
    PRIMARY KEY (news_id),
    KEY idx_publish (publish_time),
    KEY idx_source  (source)
) COMMENT='期货新闻资讯主表';

-- 3) 新闻-品种关联表：一条新闻可能同时影响多个品种(多对多)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS news_instrument_rel;
CREATE TABLE news_instrument_rel (
    news_id         BIGINT       NOT NULL COMMENT '新闻编号',
    instrument_code VARCHAR(20)  NOT NULL COMMENT '品种代码',
    PRIMARY KEY (news_id, instrument_code),
    KEY idx_instr   (instrument_code),
    CONSTRAINT fk_rel_news     FOREIGN KEY (news_id)         REFERENCES futures_news(news_id),
    CONSTRAINT fk_rel_instr    FOREIGN KEY (instrument_code) REFERENCES futures_instrument(instrument_code)
) COMMENT='新闻与品种的关联表';

-- 4) 新闻情绪/标签表：给每条新闻打情绪分和关键词(可后续用AI自动打标)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS news_sentiment;
CREATE TABLE news_sentiment (
    news_id        BIGINT       NOT NULL COMMENT '新闻编号',
    sentiment      TINYINT      COMMENT '情绪：1 利好 / 0 中性 / -1 利空',
    impact_score   DECIMAL(4,1) COMMENT '影响强度 0.0~10.0',
    keywords       VARCHAR(200) COMMENT '关键词，逗号分隔',
    PRIMARY KEY (news_id),
    CONSTRAINT fk_sent_news FOREIGN KEY (news_id) REFERENCES futures_news(news_id)
) COMMENT='新闻情绪与标签表';

-- ============================================================
-- 常用查询示例
-- ============================================================

-- 例1：查“螺纹 RB”最近 7 天的相关新闻（按时间倒序）
SELECT n.news_id, n.title, n.source, n.publish_time, s.sentiment
FROM futures_news n
JOIN news_instrument_rel r ON n.news_id = r.news_id
LEFT JOIN news_sentiment s ON n.news_id = s.news_id
WHERE r.instrument_code = 'RB'
  AND n.publish_time >= NOW() - INTERVAL 7 DAY
ORDER BY n.publish_time DESC;

-- 例2：统计今天每个品种的新增新闻条数
SELECT r.instrument_code, i.instrument_name, COUNT(*) AS news_count
FROM futures_news n
JOIN news_instrument_rel r ON n.news_id = r.news_id
JOIN futures_instrument i ON r.instrument_code = i.instrument_code
WHERE DATE(n.publish_time) = CURDATE()
GROUP BY r.instrument_code, i.instrument_name
ORDER BY news_count DESC;

-- 例3：找出“利好”且影响强度最高的 10 条新闻
SELECT n.title, i.instrument_name, s.impact_score, s.keywords
FROM futures_news n
JOIN news_instrument_rel r ON n.news_id = r.news_id
JOIN futures_instrument i ON r.instrument_code = i.instrument_code
JOIN news_sentiment s ON n.news_id = s.news_id
WHERE s.sentiment = 1
ORDER BY s.impact_score DESC
LIMIT 10;

-- 例4：按小时统计一天内的新闻发布密度（看消息集中在几点）
SELECT HOUR(publish_time) AS hr, COUNT(*) AS cnt
FROM futures_news
WHERE DATE(publish_time) = CURDATE()
GROUP BY HOUR(publish_time)
ORDER BY hr;

-- 例5：模糊搜索标题里含“增产/减产/库存”的新闻
SELECT news_id, title, publish_time
FROM futures_news
WHERE title LIKE '%增产%' OR title LIKE '%减产%' OR title LIKE '%库存%'
ORDER BY publish_time DESC;
