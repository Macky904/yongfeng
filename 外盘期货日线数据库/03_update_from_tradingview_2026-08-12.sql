-- ============================================================================
-- 外盘期货日线数据库 — 从 TradingView 免费行情补更新（近期日线）
-- 生成时间: 2026-08-11
-- 数据源: TradingView (wss://data.tradingview.com, 游客)
-- 策略: 对每个合约，仅 INSERT trade_date > 现有最大日期 的新行；
--       幂等（重跑先 DELETE > dmax 再 INSERT）；末尾窗口函数重算 MA。
-- 注意: 不含任何连接串。
-- ============================================================================

-- CBOT:ZC1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZC1!', 'continuous', 'CBOT', 'C', '美玉米', '2026-08-12', 436.75, 442.5, 436.0, 440.5, 12721, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZF1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZF1!', 'continuous', 'CBOT', 'ZF', '5年美债', '2026-08-11', 106.2890625, 106.5625, 106.2734375, 106.4375, 523450, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZL1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZL1!', 'continuous', 'CBOT', 'ZL', '美豆油', '2026-08-12', 68.22, 68.64, 67.95, 68.12, 8134, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZM1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZM1!', 'continuous', 'CBOT', 'ZM', '美豆粕', '2026-08-12', 311.8, 313.8, 310.9, 313.0, 8235, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZN1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZN1!', 'continuous', 'CBOT', 'ZN', '10年美债', '2026-08-11', 108.453125, 108.875, 108.421875, 108.671875, 701433, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZO1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZO1!', 'continuous', 'CBOT', 'O', '燕麦', '2026-08-12', 342.75, 345.0, 342.0, 344.0, 29, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZR1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZR1!', 'continuous', 'CBOT', 'ZR', '粗米', '2026-08-12', 13.915, 13.915, 13.915, 13.915, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZS1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZS1!', 'continuous', 'CBOT', 'S', '美豆', '2026-08-12', 1168.5, 1177.5, 1167.5, 1173.75, 24385, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZSQ2026  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZSQ2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-11', 1152.25, 1152.25, 1145.5, 1147.5, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-08-01'),
  ('CBOT:ZSQ2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-12', 1155.0, 1155.0, 1155.0, 1155.0, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-08-01');
-- CBOT:ZSU2026  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZSU2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-12', 1150.25, 1160.0, 1150.25, 1156.25, 2312, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-09-01');
-- CBOT:ZSX2026  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZSX2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-12', 1168.5, 1177.5, 1167.5, 1173.75, 24390, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-11-01');
-- CBOT:ZT1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZT1!', 'continuous', 'CBOT', 'ZT', '2年美债', '2026-08-11', 102.953125, 103.06640625, 102.9453125, 103.015625, 422432, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZW1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZW1!', 'continuous', 'CBOT', 'W', '美麦', '2026-08-12', 632.0, 653.5, 631.5, 647.0, 32708, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CME:NKD1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CME:NKD1!', 'continuous', 'CME', 'NKD', '日经指数(USD)', '2026-08-11', 67150.0, 68430.0, 66865.0, 68345.0, 1679, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- COMEX:GC1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('COMEX:GC1!', 'continuous', 'COMEX', 'GC', '美黄金', '2026-08-11', 4430.0, 4492.9, 4421.4, 4484.8, 72713, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- COMEX:HG1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('COMEX:HG1!', 'continuous', 'COMEX', 'HG', '美铜', '2026-08-11', 6.632, 6.706, 6.622, 6.702, 12031, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- COMEX:SI1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('COMEX:SI1!', 'continuous', 'COMEX', 'SI', '美白银', '2026-08-11', 64.875, 66.98, 64.81, 66.705, 20340, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:A501!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:A501!', 'continuous', 'HKEX', 'A50', '安硕A50', '2026-08-11', 16.96, 16.96, 16.96, 16.96, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:A501!', 'continuous', 'HKEX', 'A50', '安硕A50', '2026-08-12', 17.01, 17.01, 17.01, 17.01, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:ALB1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:ALB1!', 'continuous', 'HKEX', 'ALB', '阿里巴巴', '2026-08-12', 125.0, 125.0, 121.75, 122.59, 269, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:AMC1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:AMC1!', 'continuous', 'HKEX', 'AMC', '华夏沪深300', '2026-08-11', 56.17, 56.17, 56.17, 56.17, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:AMC1!', 'continuous', 'HKEX', 'AMC', '华夏沪深300', '2026-08-12', 56.42, 56.42, 56.42, 56.42, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:BOC1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:BOC1!', 'continuous', 'HKEX', 'BOC', '中银香港', '2026-08-11', 50.43, 50.43, 50.43, 50.43, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BOC1!', 'continuous', 'HKEX', 'BOC', '中银香港', '2026-08-12', 49.91, 49.91, 49.87, 49.87, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:BUD1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:BUD1!', 'continuous', 'HKEX', 'BUD', '百威亚太', '2026-08-11', 6.43, 6.43, 6.43, 6.43, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BUD1!', 'continuous', 'HKEX', 'BUD', '百威亚太', '2026-08-12', 6.37, 6.37, 6.37, 6.37, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CCB1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CCB1!', 'continuous', 'HKEX', 'CCB', '建设银行', '2026-08-11', 8.86, 8.86, 8.86, 8.86, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCB1!', 'continuous', 'HKEX', 'CCB', '建设银行', '2026-08-12', 8.76, 8.78, 8.76, 8.76, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CCC1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CCC1!', 'continuous', 'HKEX', 'CCC', '中国交通建设', '2026-08-11', 3.75, 3.75, 3.75, 3.75, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCC1!', 'continuous', 'HKEX', 'CCC', '中国交通建设', '2026-08-12', 3.72, 3.72, 3.72, 3.72, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CHT1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CHT1!', 'continuous', 'HKEX', 'CHT', '中国移动', '2026-08-12', 81.83, 81.83, 81.47, 81.47, 168, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CLI1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CLI1!', 'continuous', 'HKEX', 'CLI', '中国人寿保险', '2026-08-12', 27.12, 27.32, 27.0, 27.1, 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CMB1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CMB1!', 'continuous', 'HKEX', 'CMB', '招商银行', '2026-08-11', 48.4, 48.4, 48.4, 48.4, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CMB1!', 'continuous', 'HKEX', 'CMB', '招商银行', '2026-08-12', 48.0, 48.02, 48.0, 48.02, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CNC1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CNC1!', 'continuous', 'HKEX', 'CNC', '中国海洋石油', '2026-08-12', 23.85, 23.94, 23.85, 23.94, 14, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CPC1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CPC1!', 'continuous', 'HKEX', 'CPC', '中国石油化工', '2026-08-11', 4.33, 4.33, 4.33, 4.33, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CPC1!', 'continuous', 'HKEX', 'CPC', '中国石油化工', '2026-08-12', 4.24, 4.24, 4.24, 4.24, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CSA1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CSA1!', 'continuous', 'HKEX', 'CSA', '南方A50', '2026-08-11', 15.66, 15.66, 15.66, 15.66, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CSA1!', 'continuous', 'HKEX', 'CSA', '南方A50', '2026-08-12', 15.72, 15.72, 15.72, 15.72, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CTC1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CTC1!', 'continuous', 'HKEX', 'CTC', '中国电信', '2026-08-12', 4.58, 4.62, 4.58, 4.61, 286, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CUS1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CUS1!', 'continuous', 'HKEX', 'CUS', '美元兑人民币', '2026-08-11', 6.7431, 6.7465, 6.7411, 6.7425, 49832, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CUS1!', 'continuous', 'HKEX', 'CUS', '美元兑人民币', '2026-08-12', 6.7422, 6.7447, 6.73, 6.7416, 460, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:GWM1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:GWM1!', 'continuous', 'HKEX', 'GWM', '长城汽车', '2026-08-11', 8.79, 8.79, 8.79, 8.79, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:GWM1!', 'continuous', 'HKEX', 'GWM', '长城汽车', '2026-08-12', 8.65, 8.65, 8.64, 8.64, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HEX1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HEX1!', 'continuous', 'HKEX', 'HEX', '香港交易所', '2026-08-12', 404.5, 407.1, 404.5, 406.2, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HHI1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HHI1!', 'continuous', 'HKEX', 'HHI', 'H股指数', '2026-08-11', 8531.0, 8552.0, 8411.0, 8450.0, 72987, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HHI1!', 'continuous', 'HKEX', 'HHI', 'H股指数', '2026-08-12', 8453.0, 8472.0, 8438.0, 8457.0, 4165, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HKB1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HKB1!', 'continuous', 'HKEX', 'HKB', '汇丰控股', '2026-08-12', 160.5, 161.25, 160.3, 160.68, 35, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HSI1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HSI1!', 'continuous', 'HKEX', 'HSI', '恒生指数', '2026-08-11', 25629.0, 25700.0, 25308.0, 25408.0, 67466, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HSI1!', 'continuous', 'HKEX', 'HSI', '恒生指数', '2026-08-12', 25404.0, 25487.0, 25400.0, 25450.0, 2965, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HTI1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HTI1!', 'continuous', 'HKEX', 'HTI', '恒生科技指數', '2026-08-11', 4829.0, 4845.0, 4757.0, 4780.0, 87150, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HTI1!', 'continuous', 'HKEX', 'HTI', '恒生科技指數', '2026-08-12', 4788.0, 4799.0, 4773.0, 4792.0, 2093, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:ICB1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:ICB1!', 'continuous', 'HKEX', 'ICB', '工商银行', '2026-08-11', 7.22, 7.22, 7.22, 7.22, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ICB1!', 'continuous', 'HKEX', 'ICB', '工商银行', '2026-08-12', 7.17, 7.17, 7.17, 7.17, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:JDC1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:JDC1!', 'continuous', 'HKEX', 'JDC', '京东集团', '2026-08-12', 123.59, 123.8, 122.51, 123.01, 36, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MCA1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MCA1!', 'continuous', 'HKEX', 'MCA', 'MSCI 中国 A50 互联互通（美元）指数 期货', '2026-08-11', 2765.2, 2785.2, 2756.6, 2777.4, 8549, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCA1!', 'continuous', 'HKEX', 'MCA', 'MSCI 中国 A50 互联互通（美元）指数 期货', '2026-08-12', 2778.4, 2785.2, 2776.8, 2783.0, 150, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MCH1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MCH1!', 'continuous', 'HKEX', 'MCH', '小型H股指数', '2026-08-11', 8534.0, 8551.0, 8412.0, 8447.0, 4550, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCH1!', 'continuous', 'HKEX', 'MCH', '小型H股指数', '2026-08-12', 8450.0, 8470.0, 8438.0, 8459.0, 265, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MCS1!  新增 2 行 (trade_date > 2026-08-07)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MCS1!', 'continuous', 'HKEX', 'MCS', '小型美元兑人民币', '2026-08-10', 6.7438, 6.7438, 6.7438, 6.7438, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCS1!', 'continuous', 'HKEX', 'MCS', '小型美元兑人民币', '2026-08-11', 6.7425, 6.7425, 6.7425, 6.7425, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MET1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MET1!', 'continuous', 'HKEX', 'MET', '美团点评', '2026-08-12', 91.7, 91.98, 90.0, 91.6, 55, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MHI1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MHI1!', 'continuous', 'HKEX', 'MHI', '小型恒生指数', '2026-08-11', 25625.0, 25700.0, 25308.0, 25412.0, 53917, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MHI1!', 'continuous', 'HKEX', 'MHI', '小型恒生指数', '2026-08-12', 25400.0, 25488.0, 25400.0, 25460.0, 3258, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MIU1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MIU1!', 'continuous', 'HKEX', 'MIU', '小米集团', '2026-08-12', 26.5, 26.55, 26.2, 26.32, 32, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MTW1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MTW1!', 'continuous', 'HKEX', 'MTW', 'MSCI台湾指数', '2026-08-11', 2020.2, 2055.3, 2020.2, 2055.3, 1177, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MTW1!', 'continuous', 'HKEX', 'MTW', 'MSCI台湾指数', '2026-08-12', 2057.4, 2079.7, 2057.4, 2075.5, 80, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:NTE1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:NTE1!', 'continuous', 'HKEX', 'NTE', '网易', '2026-08-12', 203.0, 203.0, 192.49, 192.49, 74, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:PAI1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:PAI1!', 'continuous', 'HKEX', 'PAI', '中国平安', '2026-08-12', 55.38, 55.48, 55.29, 55.42, 11, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:PEC1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:PEC1!', 'continuous', 'HKEX', 'PEC', '中国石油天然气', '2026-08-12', 9.64, 9.64, 9.48, 9.48, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:PIC1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:PIC1!', 'continuous', 'HKEX', 'PIC', '中国人民财产保险', '2026-08-11', 15.61, 15.61, 15.61, 15.61, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PIC1!', 'continuous', 'HKEX', 'PIC', '中国人民财产保险', '2026-08-12', 15.52, 15.52, 15.52, 15.52, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:TCH1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:TCH1!', 'continuous', 'HKEX', 'TCH', '腾讯控股', '2026-08-12', 465.0, 465.0, 457.18, 460.25, 394, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:TWR1!  新增 1 行 (trade_date > 2026-08-11)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:TWR1!', 'continuous', 'HKEX', 'TWR', '中国铁塔', '2026-08-12', 9.55, 9.55, 9.34, 9.34, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:BZ1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:BZ1!', 'continuous', 'NYMEX', 'BZ', '布伦特原油最后结算', '2026-08-11', 89.27, 90.07, 88.12, 89.11, 14350, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:MCL1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:MCL1!', 'continuous', 'NYMEX', 'MCL', '微型美原油', '2026-08-11', 83.5, 84.35, 82.45, 83.58, 68220, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:PA1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:PA1!', 'continuous', 'NYMEX', 'PA', '美钯金', '2026-08-11', 1372.5, 1409.0, 1365.0, 1402.0, 1907, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:PL1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:PL1!', 'continuous', 'NYMEX', 'PL', '美铂金', '2026-08-11', 1747.2, 1809.3, 1747.2, 1797.8, 9293, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:RB1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:RB1!', 'continuous', 'NYMEX', 'RB', '无铅汽油', '2026-08-11', 3.139, 3.1778, 3.1147, 3.1287, 5656, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:CN1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:CN1!', 'continuous', 'SGX', 'CN', '富时中国指数A50', '2026-08-11', 14938.0, 15030.0, 14889.0, 14984.0, 179101, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:CN1!', 'continuous', 'SGX', 'CN', '富时中国指数A50', '2026-08-12', 14987.0, 15038.0, 14987.0, 15032.0, 11508, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:FCH1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:FCH1!', 'continuous', 'SGX', 'FCH', '富時中國H50指數', '2026-08-11', 16332.5, 16347.5, 16047.5, 16115.0, 1900, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:FCH1!', 'continuous', 'SGX', 'FCH', '富時中國H50指數', '2026-08-12', 16122.5, 16122.5, 16105.0, 16120.0, 47, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:MUC1!  新增 2 行 (trade_date > 2026-08-07)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:MUC1!', 'continuous', 'SGX', 'MUC', '小型美元兑人民币', '2026-08-10', 6.7444, 6.7444, 6.7444, 6.7444, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:MUC1!', 'continuous', 'SGX', 'MUC', '小型美元兑人民币', '2026-08-11', 6.7423, 6.7423, 6.7423, 6.7423, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:NK1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:NK1!', 'continuous', 'SGX', 'NK', '日经225指数', '2026-08-11', 66920.0, 67720.0, 66780.0, 67670.0, 10724, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:NK1!', 'continuous', 'SGX', 'NK', '日经225指数', '2026-08-12', 67730.0, 68380.0, 67655.0, 68320.0, 2011, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:TF1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:TF1!', 'continuous', 'SGX', 'TF', 'TSR20橡胶', '2026-08-11', 220.4, 222.7, 220.0, 222.1, 523, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:TF1!', 'continuous', 'SGX', 'TF', 'TSR20橡胶', '2026-08-12', 221.7, 221.7, 221.6, 221.7, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:UC1!  新增 2 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:UC1!', 'continuous', 'SGX', 'UC', '美元兑人民币', '2026-08-11', 6.7443, 6.7466, 6.7409, 6.7426, 49464, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:UC1!', 'continuous', 'SGX', 'UC', '美元兑人民币', '2026-08-12', 6.7423, 6.7448, 6.7409, 6.741, 2500, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- ZCE:TA1!  新增 1 行 (trade_date > 2026-08-10)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('ZCE:TA1!', 'continuous', 'ZCE', 'TA', '精对苯二甲酸 PTA', '2026-08-11', 5668.0, 5830.0, 5668.0, 5750.0, 23, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- 重算 MA5/10/20/30（仅近窗，按合约分区，按交易日排序）
WITH ma AS (
  SELECT id,
         AVG(close_price) OVER w5  AS ma5,
         AVG(close_price) OVER w10 AS ma10,
         AVG(close_price) OVER w20 AS ma20,
         AVG(close_price) OVER w30 AS ma30
  FROM public.futures_kline_daily
  WHERE trade_date >= '2026-06-20'
  WINDOW w5  AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 4  PRECEDING AND CURRENT ROW),
         w10 AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 9  PRECEDING AND CURRENT ROW),
         w20 AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW),
         w30 AS (PARTITION BY contract_code ORDER BY trade_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
)
UPDATE public.futures_kline_daily t
SET ma5=ma.ma5, ma10=ma.ma10, ma20=ma.ma20, ma30=ma.ma30
FROM ma WHERE t.id = ma.id;
