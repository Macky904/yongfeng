-- ============================================================================
-- 外盘期货日线数据库 — 从 TradingView 免费行情补更新（近期日线）
-- 生成时间: 2026-08-11
-- 数据源: TradingView (wss://data.tradingview.com, 游客)
-- 策略: 对每个合约，仅 INSERT trade_date > 现有最大日期 的新行；
--       幂等（重跑先 DELETE > dmax 再 INSERT）；末尾窗口函数重算 MA。
-- 注意: 不含任何连接串。
-- ============================================================================

-- CBOE:VX1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOE:VX1!', 'continuous', 'CBOE', 'VX', 'CBOE波动率指数 VIX', '2026-08-04', 17.95, 18.3, 17.25, 17.4302, 87382, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOE:VX1!', 'continuous', 'CBOE', 'VX', 'CBOE波动率指数 VIX', '2026-08-05', 17.55, 17.8, 17.0, 17.0952, 77211, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOE:VX1!', 'continuous', 'CBOE', 'VX', 'CBOE波动率指数 VIX', '2026-08-06', 17.15, 17.36, 16.85, 16.9913, 61404, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOE:VX1!', 'continuous', 'CBOE', 'VX', 'CBOE波动率指数 VIX', '2026-08-09', 17.0, 17.15, 16.7, 16.9577, 48913, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOE:VX1!', 'continuous', 'CBOE', 'VX', 'CBOE波动率指数 VIX', '2026-08-10', 16.9, 17.01, 16.9, 16.91, 579, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:KE1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:KE1!', 'continuous', 'CBOT', 'KW', 'KS 小麦', '2026-08-05', 705.25, 724.75, 701.25, 713.5, 32334, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:KE1!', 'continuous', 'CBOT', 'KW', 'KS 小麦', '2026-08-06', 714.0, 719.75, 693.75, 699.75, 37231, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:KE1!', 'continuous', 'CBOT', 'KW', 'KS 小麦', '2026-08-07', 700.0, 719.0, 696.5, 714.0, 41944, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:KE1!', 'continuous', 'CBOT', 'KW', 'KS 小麦', '2026-08-10', 719.75, 735.0, 712.0, 713.5, 46799, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:KE1!', 'continuous', 'CBOT', 'KW', 'KS 小麦', '2026-08-11', 713.0, 717.75, 709.5, 715.5, 1971, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:MYM1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:MYM1!', 'continuous', 'CBOT', 'MYM', '微型道琼斯指数', '2026-08-04', 54352.0, 54885.0, 54343.0, 54494.0, 119346, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:MYM1!', 'continuous', 'CBOT', 'MYM', '微型道琼斯指数', '2026-08-05', 54540.0, 54678.0, 53954.0, 54013.0, 113096, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:MYM1!', 'continuous', 'CBOT', 'MYM', '微型道琼斯指数', '2026-08-06', 54007.0, 54203.0, 53882.0, 54152.0, 96626, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:MYM1!', 'continuous', 'CBOT', 'MYM', '微型道琼斯指数', '2026-08-09', 54112.0, 54171.0, 53950.0, 54063.0, 82443, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:MYM1!', 'continuous', 'CBOT', 'MYM', '微型道琼斯指数', '2026-08-10', 54069.0, 54069.0, 53997.0, 54059.0, 2851, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:YM1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:YM1!', 'continuous', 'CBOT', 'YM', '小型道琼斯指数', '2026-08-04', 54369.0, 54884.0, 54342.0, 54494.0, 74860, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:YM1!', 'continuous', 'CBOT', 'YM', '小型道琼斯指数', '2026-08-05', 54555.0, 54678.0, 53952.0, 54013.0, 67729, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:YM1!', 'continuous', 'CBOT', 'YM', '小型道琼斯指数', '2026-08-06', 54040.0, 54202.0, 53879.0, 54152.0, 53594, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:YM1!', 'continuous', 'CBOT', 'YM', '小型道琼斯指数', '2026-08-09', 54133.0, 54170.0, 53952.0, 54063.0, 48925, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:YM1!', 'continuous', 'CBOT', 'YM', '小型道琼斯指数', '2026-08-10', 54049.0, 54074.0, 53998.0, 54060.0, 1839, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZB1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZB1!', 'continuous', 'CBOT', 'ZB', '长期美债', '2026-08-04', 110.0, 110.40625, 109.78125, 109.96875, 382531, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZB1!', 'continuous', 'CBOT', 'ZB', '长期美债', '2026-08-05', 110.03125, 110.21875, 109.15625, 109.34375, 364311, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZB1!', 'continuous', 'CBOT', 'ZB', '长期美债', '2026-08-06', 109.15625, 110.0625, 109.0625, 109.375, 338771, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZB1!', 'continuous', 'CBOT', 'ZB', '长期美债', '2026-08-09', 109.34375, 109.65625, 108.75, 108.90625, 316462, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZB1!', 'continuous', 'CBOT', 'ZB', '长期美债', '2026-08-10', 108.78125, 108.8125, 108.59375, 108.625, 7491, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZC1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZC1!', 'continuous', 'CBOT', 'C', '美玉米', '2026-08-05', 441.75, 443.0, 435.5, 436.75, 90877, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZC1!', 'continuous', 'CBOT', 'C', '美玉米', '2026-08-06', 437.0, 440.25, 434.25, 439.0, 87927, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZC1!', 'continuous', 'CBOT', 'C', '美玉米', '2026-08-07', 439.0, 444.5, 438.5, 439.0, 126600, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZC1!', 'continuous', 'CBOT', 'C', '美玉米', '2026-08-10', 440.75, 442.25, 436.5, 438.25, 141010, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZC1!', 'continuous', 'CBOT', 'C', '美玉米', '2026-08-11', 438.5, 439.75, 437.75, 439.25, 4083, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZF1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZF1!', 'continuous', 'CBOT', 'ZF', '5年美债', '2026-08-04', 106.53125, 106.609375, 106.390625, 106.546875, 1077751, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZF1!', 'continuous', 'CBOT', 'ZF', '5年美债', '2026-08-05', 106.5234375, 106.5859375, 106.234375, 106.265625, 1004156, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZF1!', 'continuous', 'CBOT', 'ZF', '5年美债', '2026-08-06', 106.234375, 106.65625, 106.21875, 106.398438, 1475462, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZF1!', 'continuous', 'CBOT', 'ZF', '5年美债', '2026-08-09', 106.3984375, 106.4453125, 106.1796875, 106.21875, 945297, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZF1!', 'continuous', 'CBOT', 'ZF', '5年美债', '2026-08-10', 106.1875, 106.21875, 106.1640625, 106.171875, 24506, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZL1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZL1!', 'continuous', 'CBOT', 'ZL', '美豆油', '2026-08-05', 67.5, 67.91, 66.79, 67.17, 41664, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZL1!', 'continuous', 'CBOT', 'ZL', '美豆油', '2026-08-06', 67.2, 67.72, 66.75, 67.37, 48429, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZL1!', 'continuous', 'CBOT', 'ZL', '美豆油', '2026-08-07', 67.2, 68.07, 67.02, 67.88, 46895, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZL1!', 'continuous', 'CBOT', 'ZL', '美豆油', '2026-08-10', 67.98, 69.27, 67.92, 69.14, 57493, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZL1!', 'continuous', 'CBOT', 'ZL', '美豆油', '2026-08-11', 69.09, 69.24, 68.92, 69.05, 1795, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZM1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZM1!', 'continuous', 'CBOT', 'ZM', '美豆粕', '2026-08-05', 318.0, 318.2, 314.6, 315.6, 44823, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZM1!', 'continuous', 'CBOT', 'ZM', '美豆粕', '2026-08-06', 316.2, 318.1, 315.0, 316.6, 42378, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZM1!', 'continuous', 'CBOT', 'ZM', '美豆粕', '2026-08-07', 315.7, 318.0, 313.2, 313.4, 37981, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZM1!', 'continuous', 'CBOT', 'ZM', '美豆粕', '2026-08-10', 314.2, 316.0, 311.3, 311.6, 53948, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZM1!', 'continuous', 'CBOT', 'ZM', '美豆粕', '2026-08-11', 312.3, 312.6, 311.1, 311.4, 2842, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZN1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZN1!', 'continuous', 'CBOT', 'ZN', '10年美债', '2026-08-04', 108.90625, 109.03125, 108.703125, 108.890625, 1574024, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZN1!', 'continuous', 'CBOT', 'ZN', '10年美债', '2026-08-05', 108.890625, 108.984375, 108.4375, 108.5, 1405067, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZN1!', 'continuous', 'CBOT', 'ZN', '10年美债', '2026-08-06', 108.453125, 109.046875, 108.40625, 108.640625, 1885818, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZN1!', 'continuous', 'CBOT', 'ZN', '10年美债', '2026-08-09', 108.640625, 108.75, 108.296875, 108.375, 1212203, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZN1!', 'continuous', 'CBOT', 'ZN', '10年美债', '2026-08-10', 108.3125, 108.34375, 108.25, 108.265625, 36472, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZO1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZO1!', 'continuous', 'CBOT', 'O', '燕麦', '2026-08-05', 332.5, 338.75, 331.25, 333.75, 150, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZO1!', 'continuous', 'CBOT', 'O', '燕麦', '2026-08-06', 334.25, 336.0, 327.0, 328.0, 207, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZO1!', 'continuous', 'CBOT', 'O', '燕麦', '2026-08-07', 327.75, 333.75, 327.75, 331.0, 208, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZO1!', 'continuous', 'CBOT', 'O', '燕麦', '2026-08-10', 332.0, 345.75, 332.0, 344.0, 558, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZO1!', 'continuous', 'CBOT', 'O', '燕麦', '2026-08-11', 343.25, 344.0, 343.0, 343.75, 27, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZR1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZR1!', 'continuous', 'CBOT', 'ZR', '粗米', '2026-08-05', 13.885, 14.15, 13.87, 14.055, 476, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZR1!', 'continuous', 'CBOT', 'ZR', '粗米', '2026-08-06', 14.115, 14.37, 14.03, 14.185, 753, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZR1!', 'continuous', 'CBOT', 'ZR', '粗米', '2026-08-07', 14.185, 14.415, 14.125, 14.23, 813, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZR1!', 'continuous', 'CBOT', 'ZR', '粗米', '2026-08-10', 14.325, 14.335, 13.99, 14.025, 745, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZR1!', 'continuous', 'CBOT', 'ZR', '粗米', '2026-08-11', 14.025, 14.025, 13.915, 13.995, 44, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZS1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZS1!', 'continuous', 'CBOT', 'S', '美豆', '2026-08-05', 1177.0, 1181.0, 1167.25, 1174.75, 106807, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZS1!', 'continuous', 'CBOT', 'S', '美豆', '2026-08-06', 1175.25, 1179.0, 1170.5, 1177.75, 90762, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZS1!', 'continuous', 'CBOT', 'S', '美豆', '2026-08-07', 1177.75, 1185.0, 1175.5, 1176.25, 73091, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZS1!', 'continuous', 'CBOT', 'S', '美豆', '2026-08-10', 1177.0, 1185.0, 1175.0, 1179.5, 73643, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZS1!', 'continuous', 'CBOT', 'S', '美豆', '2026-08-11', 1181.0, 1182.75, 1178.25, 1179.75, 4250, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZSQ2026  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZSQ2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-05', 1149.25, 1152.25, 1146.25, 1151.5, 70, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-08-01'),
  ('CBOT:ZSQ2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-06', 1151.75, 1157.5, 1151.25, 1157.25, 135, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-08-01'),
  ('CBOT:ZSQ2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-07', 1165.5, 1165.5, 1156.5, 1156.5, 59, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-08-01'),
  ('CBOT:ZSQ2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-10', 1160.5, 1161.5, 1157.75, 1157.75, 28, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-08-01');
-- CBOT:ZSU2026  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZSU2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-05', 1158.75, 1161.75, 1148.75, 1156.5, 18818, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-09-01'),
  ('CBOT:ZSU2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-06', 1157.25, 1161.0, 1151.75, 1160.0, 15581, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-09-01'),
  ('CBOT:ZSU2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-07', 1160.0, 1167.5, 1157.75, 1159.0, 13273, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-09-01'),
  ('CBOT:ZSU2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-10', 1160.5, 1167.5, 1158.0, 1161.75, 12322, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-09-01'),
  ('CBOT:ZSU2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-11', 1163.0, 1165.0, 1161.0, 1162.5, 449, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-09-01');
-- CBOT:ZSX2026  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZSX2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-05', 1177.0, 1181.0, 1167.25, 1174.75, 106807, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-11-01'),
  ('CBOT:ZSX2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-06', 1175.25, 1179.0, 1170.5, 1177.75, 90762, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-11-01'),
  ('CBOT:ZSX2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-07', 1177.75, 1185.0, 1175.5, 1176.25, 73091, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-11-01'),
  ('CBOT:ZSX2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-10', 1177.0, 1185.0, 1175.0, 1179.5, 73643, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-11-01'),
  ('CBOT:ZSX2026', 'monthly', 'CBOT', 'S', '美豆', '2026-08-11', 1181.0, 1182.75, 1178.25, 1179.5, 4257, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '2026-11-01');
-- CBOT:ZT1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZT1!', 'continuous', 'CBOT', 'ZT', '2年美债', '2026-08-04', 102.984375, 103.02734375, 102.93359375, 103.023438, 672276, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZT1!', 'continuous', 'CBOT', 'ZT', '2年美债', '2026-08-05', 103.00390625, 103.0234375, 102.8828125, 102.902344, 677434, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZT1!', 'continuous', 'CBOT', 'ZT', '2年美债', '2026-08-06', 102.88671875, 103.078125, 102.8828125, 102.976563, 1047414, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZT1!', 'continuous', 'CBOT', 'ZT', '2年美债', '2026-08-09', 102.97265625, 102.984375, 102.90234375, 102.91796875, 619531, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZT1!', 'continuous', 'CBOT', 'ZT', '2年美债', '2026-08-10', 102.90234375, 102.91796875, 102.90234375, 102.90625, 19797, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CBOT:ZW1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CBOT:ZW1!', 'continuous', 'CBOT', 'W', '美麦', '2026-08-05', 638.0, 652.5, 633.25, 642.25, 55174, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZW1!', 'continuous', 'CBOT', 'W', '美麦', '2026-08-06', 643.75, 649.0, 626.75, 631.25, 68594, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZW1!', 'continuous', 'CBOT', 'W', '美麦', '2026-08-07', 631.0, 646.0, 628.5, 639.75, 77012, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZW1!', 'continuous', 'CBOT', 'W', '美麦', '2026-08-10', 643.5, 656.5, 639.25, 640.5, 86920, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CBOT:ZW1!', 'continuous', 'CBOT', 'W', '美麦', '2026-08-11', 639.5, 644.5, 637.75, 643.25, 1575, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- CME:NKD1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('CME:NKD1!', 'continuous', 'CME', 'NKD', '日经指数(USD)', '2026-08-04', 65535.0, 66845.0, 65535.0, 65770.0, 3894, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CME:NKD1!', 'continuous', 'CME', 'NKD', '日经指数(USD)', '2026-08-05', 65880.0, 66410.0, 64985.0, 65660.0, 3959, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CME:NKD1!', 'continuous', 'CME', 'NKD', '日经指数(USD)', '2026-08-06', 65570.0, 66760.0, 64740.0, 66345.0, 4879, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CME:NKD1!', 'continuous', 'CME', 'NKD', '日经指数(USD)', '2026-08-09', 66330.0, 67615.0, 66145.0, 66755.0, 3190, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('CME:NKD1!', 'continuous', 'CME', 'NKD', '日经指数(USD)', '2026-08-10', 66815.0, 67175.0, 66340.0, 67120.0, 337, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- COMEX:GC1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('COMEX:GC1!', 'continuous', 'COMEX', 'GC', '美黄金', '2026-08-04', 4133.8, 4328.2, 4121.6, 4305.2, 203921, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:GC1!', 'continuous', 'COMEX', 'GC', '美黄金', '2026-08-05', 4307.0, 4363.7, 4281.2, 4299.6, 161442, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:GC1!', 'continuous', 'COMEX', 'GC', '美黄金', '2026-08-06', 4298.3, 4432.3, 4288.0, 4399.7, 183289, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:GC1!', 'continuous', 'COMEX', 'GC', '美黄金', '2026-08-09', 4400.0, 4453.8, 4373.9, 4419.7, 115644, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:GC1!', 'continuous', 'COMEX', 'GC', '美黄金', '2026-08-10', 4446.9, 4495.0, 4443.2, 4474.8, 24546, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- COMEX:HG1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('COMEX:HG1!', 'continuous', 'COMEX', 'HG', '美铜', '2026-08-04', 6.6285, 6.765, 6.6115, 6.7275, 46942, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:HG1!', 'continuous', 'COMEX', 'HG', '美铜', '2026-08-05', 6.748, 6.8665, 6.6715, 6.709, 57048, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:HG1!', 'continuous', 'COMEX', 'HG', '美铜', '2026-08-06', 6.7205, 6.7655, 6.57, 6.591, 54732, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:HG1!', 'continuous', 'COMEX', 'HG', '美铜', '2026-08-09', 6.6, 6.6545, 6.583, 6.616, 46722, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:HG1!', 'continuous', 'COMEX', 'HG', '美铜', '2026-08-10', 6.633, 6.6705, 6.621, 6.6505, 3660, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- COMEX:SI1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('COMEX:SI1!', 'continuous', 'COMEX', 'SI', '美白银', '2026-08-04', 59.785, 63.02, 59.62, 62.288, 47986, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:SI1!', 'continuous', 'COMEX', 'SI', '美白银', '2026-08-05', 62.2, 63.32, 61.12, 61.606, 34600, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:SI1!', 'continuous', 'COMEX', 'SI', '美白银', '2026-08-06', 61.855, 65.48, 61.42, 63.499, 62587, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:SI1!', 'continuous', 'COMEX', 'SI', '美白银', '2026-08-09', 63.8, 66.25, 63.195, 65.272, 41671, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('COMEX:SI1!', 'continuous', 'COMEX', 'SI', '美白银', '2026-08-10', 65.945, 66.685, 65.595, 65.99, 7087, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:A501!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:A501!', 'continuous', 'HKEX', 'A50', '安硕A50', '2026-08-05', 16.93, 16.93, 16.93, 16.93, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:A501!', 'continuous', 'HKEX', 'A50', '安硕A50', '2026-08-06', 16.94, 16.94, 16.94, 16.94, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:A501!', 'continuous', 'HKEX', 'A50', '安硕A50', '2026-08-07', 17.05, 17.05, 17.05, 17.05, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:A501!', 'continuous', 'HKEX', 'A50', '安硕A50', '2026-08-10', 17.08, 17.08, 17.08, 17.08, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:ALB1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:ALB1!', 'continuous', 'HKEX', 'ALB', '阿里巴巴', '2026-08-05', 127.02, 129.01, 126.13, 128.45, 205, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ALB1!', 'continuous', 'HKEX', 'ALB', '阿里巴巴', '2026-08-06', 126.12, 126.12, 123.94, 124.11, 141, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ALB1!', 'continuous', 'HKEX', 'ALB', '阿里巴巴', '2026-08-07', 125.24, 125.24, 121.7, 124.07, 833, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ALB1!', 'continuous', 'HKEX', 'ALB', '阿里巴巴', '2026-08-10', 124.83, 127.56, 124.83, 127.28, 89, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ALB1!', 'continuous', 'HKEX', 'ALB', '阿里巴巴', '2026-08-11', 129.76, 130.33, 128.0, 128.0, 303, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:AMC1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:AMC1!', 'continuous', 'HKEX', 'AMC', '华夏沪深300', '2026-08-05', 56.06, 56.06, 56.06, 56.06, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:AMC1!', 'continuous', 'HKEX', 'AMC', '华夏沪深300', '2026-08-06', 56.07, 56.07, 56.07, 56.07, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:AMC1!', 'continuous', 'HKEX', 'AMC', '华夏沪深300', '2026-08-07', 56.66, 56.71, 56.63, 56.63, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:AMC1!', 'continuous', 'HKEX', 'AMC', '华夏沪深300', '2026-08-10', 56.67, 56.67, 56.67, 56.67, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:BOC1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:BOC1!', 'continuous', 'HKEX', 'BOC', '中银香港', '2026-08-05', 50.33, 50.6, 50.33, 50.6, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BOC1!', 'continuous', 'HKEX', 'BOC', '中银香港', '2026-08-06', 50.18, 50.27, 50.18, 50.27, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BOC1!', 'continuous', 'HKEX', 'BOC', '中银香港', '2026-08-07', 50.24, 50.24, 50.24, 50.24, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BOC1!', 'continuous', 'HKEX', 'BOC', '中银香港', '2026-08-10', 50.04, 50.72, 50.04, 50.64, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:BUD1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:BUD1!', 'continuous', 'HKEX', 'BUD', '百威亚太', '2026-08-05', 6.51, 6.51, 6.51, 6.51, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BUD1!', 'continuous', 'HKEX', 'BUD', '百威亚太', '2026-08-06', 6.49, 6.49, 6.49, 6.49, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BUD1!', 'continuous', 'HKEX', 'BUD', '百威亚太', '2026-08-07', 6.48, 6.48, 6.48, 6.48, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:BUD1!', 'continuous', 'HKEX', 'BUD', '百威亚太', '2026-08-10', 6.49, 6.49, 6.49, 6.49, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CCB1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CCB1!', 'continuous', 'HKEX', 'CCB', '建设银行', '2026-08-05', 8.85, 8.85, 8.85, 8.85, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCB1!', 'continuous', 'HKEX', 'CCB', '建设银行', '2026-08-06', 8.76, 8.89, 8.75, 8.89, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCB1!', 'continuous', 'HKEX', 'CCB', '建设银行', '2026-08-07', 8.82, 8.82, 8.78, 8.82, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCB1!', 'continuous', 'HKEX', 'CCB', '建设银行', '2026-08-10', 8.86, 8.9, 8.86, 8.9, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CCC1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CCC1!', 'continuous', 'HKEX', 'CCC', '中国交通建设', '2026-08-05', 3.92, 3.92, 3.92, 3.92, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCC1!', 'continuous', 'HKEX', 'CCC', '中国交通建设', '2026-08-06', 3.82, 3.82, 3.82, 3.82, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCC1!', 'continuous', 'HKEX', 'CCC', '中国交通建设', '2026-08-07', 3.76, 3.76, 3.76, 3.76, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CCC1!', 'continuous', 'HKEX', 'CCC', '中国交通建设', '2026-08-10', 3.76, 3.76, 3.76, 3.76, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CHT1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CHT1!', 'continuous', 'HKEX', 'CHT', '中国移动', '2026-08-05', 82.65, 82.65, 82.65, 82.65, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CHT1!', 'continuous', 'HKEX', 'CHT', '中国移动', '2026-08-06', 82.27, 82.4, 82.27, 82.34, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CHT1!', 'continuous', 'HKEX', 'CHT', '中国移动', '2026-08-07', 81.85, 81.95, 81.66, 81.66, 38, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CHT1!', 'continuous', 'HKEX', 'CHT', '中国移动', '2026-08-10', 81.58, 81.81, 81.58, 81.81, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CHT1!', 'continuous', 'HKEX', 'CHT', '中国移动', '2026-08-11', 81.9, 81.9, 81.9, 81.9, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CLI1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CLI1!', 'continuous', 'HKEX', 'CLI', '中国人寿保险', '2026-08-05', 28.35, 29.35, 28.28, 29.3, 31, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CLI1!', 'continuous', 'HKEX', 'CLI', '中国人寿保险', '2026-08-06', 28.91, 29.09, 28.65, 29.09, 158, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CLI1!', 'continuous', 'HKEX', 'CLI', '中国人寿保险', '2026-08-07', 28.55, 29.75, 28.55, 28.86, 57, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CLI1!', 'continuous', 'HKEX', 'CLI', '中国人寿保险', '2026-08-10', 28.51, 28.52, 28.02, 28.23, 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CLI1!', 'continuous', 'HKEX', 'CLI', '中国人寿保险', '2026-08-11', 28.17, 28.17, 27.6, 27.6, 25, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CMB1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CMB1!', 'continuous', 'HKEX', 'CMB', '招商银行', '2026-08-05', 49.22, 49.22, 48.86, 48.86, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CMB1!', 'continuous', 'HKEX', 'CMB', '招商银行', '2026-08-06', 48.8, 48.84, 48.35, 48.84, 32, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CMB1!', 'continuous', 'HKEX', 'CMB', '招商银行', '2026-08-07', 48.8, 48.8, 48.8, 48.8, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CMB1!', 'continuous', 'HKEX', 'CMB', '招商银行', '2026-08-10', 49.04, 49.04, 49.04, 49.04, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CNC1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CNC1!', 'continuous', 'HKEX', 'CNC', '中国海洋石油', '2026-08-05', 23.07, 23.07, 22.84, 22.95, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CNC1!', 'continuous', 'HKEX', 'CNC', '中国海洋石油', '2026-08-06', 22.74, 22.74, 22.62, 22.62, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CNC1!', 'continuous', 'HKEX', 'CNC', '中国海洋石油', '2026-08-07', 23.08, 23.24, 23.08, 23.18, 123, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CNC1!', 'continuous', 'HKEX', 'CNC', '中国海洋石油', '2026-08-10', 23.43, 23.65, 23.38, 23.38, 24, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CNC1!', 'continuous', 'HKEX', 'CNC', '中国海洋石油', '2026-08-11', 24.01, 24.31, 24.01, 24.03, 201, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CPC1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CPC1!', 'continuous', 'HKEX', 'CPC', '中国石油化工', '2026-08-05', 4.33, 4.33, 4.33, 4.33, 193, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CPC1!', 'continuous', 'HKEX', 'CPC', '中国石油化工', '2026-08-06', 4.27, 4.27, 4.27, 4.27, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CPC1!', 'continuous', 'HKEX', 'CPC', '中国石油化工', '2026-08-07', 4.32, 4.37, 4.32, 4.37, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CPC1!', 'continuous', 'HKEX', 'CPC', '中国石油化工', '2026-08-10', 4.32, 4.32, 4.32, 4.32, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CSA1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CSA1!', 'continuous', 'HKEX', 'CSA', '南方A50', '2026-08-05', 15.6, 15.73, 15.6, 15.66, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CSA1!', 'continuous', 'HKEX', 'CSA', '南方A50', '2026-08-06', 15.66, 15.66, 15.66, 15.66, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CSA1!', 'continuous', 'HKEX', 'CSA', '南方A50', '2026-08-07', 15.76, 15.77, 15.76, 15.77, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CSA1!', 'continuous', 'HKEX', 'CSA', '南方A50', '2026-08-10', 15.79, 15.79, 15.79, 15.79, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CTC1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CTC1!', 'continuous', 'HKEX', 'CTC', '中国电信', '2026-08-05', 4.47, 4.53, 4.47, 4.53, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CTC1!', 'continuous', 'HKEX', 'CTC', '中国电信', '2026-08-06', 4.47, 4.47, 4.47, 4.47, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CTC1!', 'continuous', 'HKEX', 'CTC', '中国电信', '2026-08-07', 4.46, 4.46, 4.46, 4.46, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CTC1!', 'continuous', 'HKEX', 'CTC', '中国电信', '2026-08-10', 4.5, 4.53, 4.46, 4.46, 82, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CTC1!', 'continuous', 'HKEX', 'CTC', '中国电信', '2026-08-11', 4.49, 4.49, 4.49, 4.49, 18, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:CUS1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:CUS1!', 'continuous', 'HKEX', 'CUS', '美元兑人民币', '2026-08-05', 6.7429, 6.7479, 6.7413, 6.7446, 5259, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CUS1!', 'continuous', 'HKEX', 'CUS', '美元兑人民币', '2026-08-06', 6.745, 6.747, 6.7418, 6.7436, 7977, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CUS1!', 'continuous', 'HKEX', 'CUS', '美元兑人民币', '2026-08-07', 6.7436, 6.7447, 6.7365, 6.7417, 6113, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:CUS1!', 'continuous', 'HKEX', 'CUS', '美元兑人民币', '2026-08-10', 6.7418, 6.745, 6.7415, 6.7425, 2802, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:GWM1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:GWM1!', 'continuous', 'HKEX', 'GWM', '长城汽车', '2026-08-05', 9.01, 9.01, 9.01, 9.01, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:GWM1!', 'continuous', 'HKEX', 'GWM', '长城汽车', '2026-08-06', 8.82, 8.82, 8.82, 8.82, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:GWM1!', 'continuous', 'HKEX', 'GWM', '长城汽车', '2026-08-07', 8.63, 8.65, 8.63, 8.65, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:GWM1!', 'continuous', 'HKEX', 'GWM', '长城汽车', '2026-08-10', 8.93, 8.93, 8.93, 8.93, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HEX1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HEX1!', 'continuous', 'HKEX', 'HEX', '香港交易所', '2026-08-05', 412.0, 414.66, 410.3, 413.68, 54, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HEX1!', 'continuous', 'HKEX', 'HEX', '香港交易所', '2026-08-06', 410.62, 410.62, 407.0, 410.31, 26, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HEX1!', 'continuous', 'HKEX', 'HEX', '香港交易所', '2026-08-07', 411.25, 411.88, 409.0, 411.67, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HEX1!', 'continuous', 'HKEX', 'HEX', '香港交易所', '2026-08-10', 417.0, 417.0, 415.2, 416.15, 17, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HEX1!', 'continuous', 'HKEX', 'HEX', '香港交易所', '2026-08-11', 411.9, 411.9, 411.46, 411.8, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HHI1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HHI1!', 'continuous', 'HKEX', 'HHI', 'H股指数', '2026-08-05', 8605.0, 8623.0, 8483.0, 8521.0, 87792, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HHI1!', 'continuous', 'HKEX', 'HHI', 'H股指数', '2026-08-06', 8529.0, 8548.0, 8447.0, 8539.0, 76788, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HHI1!', 'continuous', 'HKEX', 'HHI', 'H股指数', '2026-08-07', 8541.0, 8642.0, 8540.0, 8633.0, 74361, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HHI1!', 'continuous', 'HKEX', 'HHI', 'H股指数', '2026-08-10', 8632.0, 8688.0, 8579.0, 8583.0, 36955, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HKB1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HKB1!', 'continuous', 'HKEX', 'HKB', '汇丰控股', '2026-08-05', 164.08, 164.8, 161.75, 162.03, 172, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HKB1!', 'continuous', 'HKEX', 'HKB', '汇丰控股', '2026-08-06', 160.0, 160.0, 156.67, 159.53, 104, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HKB1!', 'continuous', 'HKEX', 'HKB', '汇丰控股', '2026-08-07', 159.5, 160.52, 159.5, 160.52, 24, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HKB1!', 'continuous', 'HKEX', 'HKB', '汇丰控股', '2026-08-10', 161.84, 162.18, 161.26, 161.99, 62, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HKB1!', 'continuous', 'HKEX', 'HKB', '汇丰控股', '2026-08-11', 161.99, 161.99, 161.65, 161.65, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HSI1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HSI1!', 'continuous', 'HKEX', 'HSI', '恒生指数', '2026-08-05', 25904.0, 25911.0, 25398.0, 25548.0, 91706, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HSI1!', 'continuous', 'HKEX', 'HSI', '恒生指数', '2026-08-06', 25554.0, 25681.0, 25402.0, 25663.0, 73555, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HSI1!', 'continuous', 'HKEX', 'HSI', '恒生指数', '2026-08-07', 25671.0, 25966.0, 25661.0, 25949.0, 72592, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HSI1!', 'continuous', 'HKEX', 'HSI', '恒生指数', '2026-08-10', 25943.0, 26056.0, 25791.0, 25811.0, 39569, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:HTI1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:HTI1!', 'continuous', 'HKEX', 'HTI', '恒生科技指數', '2026-08-05', 4930.0, 4941.0, 4815.0, 4832.0, 114923, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HTI1!', 'continuous', 'HKEX', 'HTI', '恒生科技指數', '2026-08-06', 4834.0, 4863.0, 4784.0, 4858.0, 103942, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HTI1!', 'continuous', 'HKEX', 'HTI', '恒生科技指數', '2026-08-07', 4857.0, 4932.0, 4857.0, 4928.0, 92787, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:HTI1!', 'continuous', 'HKEX', 'HTI', '恒生科技指數', '2026-08-10', 4921.0, 4951.0, 4875.0, 4881.0, 39326, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:ICB1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:ICB1!', 'continuous', 'HKEX', 'ICB', '工商银行', '2026-08-05', 7.23, 7.23, 7.23, 7.23, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ICB1!', 'continuous', 'HKEX', 'ICB', '工商银行', '2026-08-06', 7.21, 7.21, 7.21, 7.21, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ICB1!', 'continuous', 'HKEX', 'ICB', '工商银行', '2026-08-07', 7.15, 7.15, 7.15, 7.15, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:ICB1!', 'continuous', 'HKEX', 'ICB', '工商银行', '2026-08-10', 7.25, 7.25, 7.25, 7.25, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:JDC1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:JDC1!', 'continuous', 'HKEX', 'JDC', '京东集团', '2026-08-05', 128.36, 130.08, 128.36, 130.08, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:JDC1!', 'continuous', 'HKEX', 'JDC', '京东集团', '2026-08-06', 127.84, 127.84, 127.29, 127.29, 27, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:JDC1!', 'continuous', 'HKEX', 'JDC', '京东集团', '2026-08-07', 128.1, 128.11, 127.55, 127.77, 23, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:JDC1!', 'continuous', 'HKEX', 'JDC', '京东集团', '2026-08-10', 129.9, 130.74, 129.9, 130.74, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:JDC1!', 'continuous', 'HKEX', 'JDC', '京东集团', '2026-08-11', 129.44, 129.44, 127.29, 127.29, 22, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MCA1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MCA1!', 'continuous', 'HKEX', 'MCA', 'MSCI 中国 A50 互联互通（美元）指数 期货', '2026-08-05', 2774.0, 2790.4, 2752.4, 2779.4, 9727, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCA1!', 'continuous', 'HKEX', 'MCA', 'MSCI 中国 A50 互联互通（美元）指数 期货', '2026-08-06', 2779.4, 2809.4, 2761.2, 2797.4, 8392, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCA1!', 'continuous', 'HKEX', 'MCA', 'MSCI 中国 A50 互联互通（美元）指数 期货', '2026-08-07', 2799.2, 2814.2, 2775.8, 2801.0, 7001, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCA1!', 'continuous', 'HKEX', 'MCA', 'MSCI 中国 A50 互联互通（美元）指数 期货', '2026-08-10', 2799.6, 2805.2, 2774.0, 2794.0, 5027, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MCH1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MCH1!', 'continuous', 'HKEX', 'MCH', '小型H股指数', '2026-08-05', 8607.0, 8622.0, 8484.0, 8521.0, 5903, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCH1!', 'continuous', 'HKEX', 'MCH', '小型H股指数', '2026-08-06', 8518.0, 8555.0, 8448.0, 8539.0, 5391, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCH1!', 'continuous', 'HKEX', 'MCH', '小型H股指数', '2026-08-07', 8539.0, 8642.0, 8539.0, 8641.0, 5943, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCH1!', 'continuous', 'HKEX', 'MCH', '小型H股指数', '2026-08-10', 8623.0, 8689.0, 8580.0, 8585.0, 3345, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MCS1!  新增 4 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MCS1!', 'continuous', 'HKEX', 'MCS', '小型美元兑人民币', '2026-08-04', 6.7447, 6.7447, 6.7447, 6.7447, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCS1!', 'continuous', 'HKEX', 'MCS', '小型美元兑人民币', '2026-08-05', 6.7449, 6.7449, 6.7449, 6.7449, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCS1!', 'continuous', 'HKEX', 'MCS', '小型美元兑人民币', '2026-08-06', 6.7435, 6.7435, 6.7435, 6.7435, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MCS1!', 'continuous', 'HKEX', 'MCS', '小型美元兑人民币', '2026-08-07', 6.7439, 6.7439, 6.7405, 6.7414, 124, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MET1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MET1!', 'continuous', 'HKEX', 'MET', '美团点评', '2026-08-05', 92.62, 93.55, 91.76, 93.12, 51, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MET1!', 'continuous', 'HKEX', 'MET', '美团点评', '2026-08-06', 93.75, 93.75, 92.1, 92.1, 25, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MET1!', 'continuous', 'HKEX', 'MET', '美团点评', '2026-08-07', 92.4, 93.2, 91.35, 92.37, 67, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MET1!', 'continuous', 'HKEX', 'MET', '美团点评', '2026-08-10', 92.5, 93.96, 92.5, 93.96, 44, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MET1!', 'continuous', 'HKEX', 'MET', '美团点评', '2026-08-11', 95.7, 96.0, 94.2, 94.2, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MHI1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MHI1!', 'continuous', 'HKEX', 'MHI', '小型恒生指数', '2026-08-05', 25900.0, 25905.0, 25399.0, 25548.0, 72526, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MHI1!', 'continuous', 'HKEX', 'MHI', '小型恒生指数', '2026-08-06', 25549.0, 25681.0, 25403.0, 25667.0, 69276, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MHI1!', 'continuous', 'HKEX', 'MHI', '小型恒生指数', '2026-08-07', 25668.0, 25966.0, 25668.0, 25948.0, 70426, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MHI1!', 'continuous', 'HKEX', 'MHI', '小型恒生指数', '2026-08-10', 25941.0, 26056.0, 25790.0, 25812.0, 44910, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MIU1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MIU1!', 'continuous', 'HKEX', 'MIU', '小米集团', '2026-08-05', 28.45, 28.45, 27.6, 27.7, 39, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MIU1!', 'continuous', 'HKEX', 'MIU', '小米集团', '2026-08-06', 27.78, 27.93, 26.76, 26.83, 121, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MIU1!', 'continuous', 'HKEX', 'MIU', '小米集团', '2026-08-07', 26.7, 27.17, 26.26, 27.07, 46, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MIU1!', 'continuous', 'HKEX', 'MIU', '小米集团', '2026-08-10', 27.12, 27.84, 27.0, 27.72, 52, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MIU1!', 'continuous', 'HKEX', 'MIU', '小米集团', '2026-08-11', 27.33, 27.33, 27.1, 27.1, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:MTW1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:MTW1!', 'continuous', 'HKEX', 'MTW', 'MSCI台湾指数', '2026-08-05', 2016.4, 2020.8, 1982.0, 1994.4, 1821, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MTW1!', 'continuous', 'HKEX', 'MTW', 'MSCI台湾指数', '2026-08-06', 1992.6, 2020.0, 1977.0, 2000.0, 2169, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MTW1!', 'continuous', 'HKEX', 'MTW', 'MSCI台湾指数', '2026-08-07', 2004.3, 2039.4, 2004.1, 2023.3, 1050, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:MTW1!', 'continuous', 'HKEX', 'MTW', 'MSCI台湾指数', '2026-08-10', 2023.2, 2033.5, 2007.7, 2026.0, 896, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:NTE1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:NTE1!', 'continuous', 'HKEX', 'NTE', '网易', '2026-08-05', 206.56, 206.56, 202.6, 202.6, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:NTE1!', 'continuous', 'HKEX', 'NTE', '网易', '2026-08-06', 201.0, 202.5, 200.0, 202.49, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:NTE1!', 'continuous', 'HKEX', 'NTE', '网易', '2026-08-07', 205.99, 206.67, 204.93, 205.14, 64, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:NTE1!', 'continuous', 'HKEX', 'NTE', '网易', '2026-08-10', 206.4, 206.4, 205.91, 205.91, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:NTE1!', 'continuous', 'HKEX', 'NTE', '网易', '2026-08-11', 208.5, 208.5, 208.5, 208.5, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:PAI1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:PAI1!', 'continuous', 'HKEX', 'PAI', '中国平安', '2026-08-05', 57.48, 58.06, 57.48, 58.06, 27, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PAI1!', 'continuous', 'HKEX', 'PAI', '中国平安', '2026-08-06', 57.38, 57.38, 57.0, 57.34, 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PAI1!', 'continuous', 'HKEX', 'PAI', '中国平安', '2026-08-07', 57.0, 57.11, 57.0, 57.1, 13, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PAI1!', 'continuous', 'HKEX', 'PAI', '中国平安', '2026-08-10', 57.27, 57.39, 56.78, 56.86, 25, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PAI1!', 'continuous', 'HKEX', 'PAI', '中国平安', '2026-08-11', 56.3, 56.3, 56.26, 56.3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:PEC1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:PEC1!', 'continuous', 'HKEX', 'PEC', '中国石油天然气', '2026-08-05', 9.47, 9.47, 9.47, 9.47, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PEC1!', 'continuous', 'HKEX', 'PEC', '中国石油天然气', '2026-08-06', 9.41, 9.41, 9.41, 9.41, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PEC1!', 'continuous', 'HKEX', 'PEC', '中国石油天然气', '2026-08-07', 9.53, 9.54, 9.53, 9.54, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PEC1!', 'continuous', 'HKEX', 'PEC', '中国石油天然气', '2026-08-10', 9.52, 9.57, 9.52, 9.57, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PEC1!', 'continuous', 'HKEX', 'PEC', '中国石油天然气', '2026-08-11', 9.76, 9.8, 9.69, 9.69, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:PIC1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:PIC1!', 'continuous', 'HKEX', 'PIC', '中国人民财产保险', '2026-08-05', 15.98, 15.98, 15.98, 15.98, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PIC1!', 'continuous', 'HKEX', 'PIC', '中国人民财产保险', '2026-08-06', 16.26, 16.26, 16.26, 16.26, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PIC1!', 'continuous', 'HKEX', 'PIC', '中国人民财产保险', '2026-08-07', 15.95, 15.95, 15.95, 15.95, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:PIC1!', 'continuous', 'HKEX', 'PIC', '中国人民财产保险', '2026-08-10', 15.83, 15.83, 15.83, 15.83, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:TCH1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:TCH1!', 'continuous', 'HKEX', 'TCH', '腾讯控股', '2026-08-05', 492.58, 498.44, 483.75, 492.8, 344, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TCH1!', 'continuous', 'HKEX', 'TCH', '腾讯控股', '2026-08-06', 485.0, 488.4, 480.0, 481.0, 321, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TCH1!', 'continuous', 'HKEX', 'TCH', '腾讯控股', '2026-08-07', 481.0, 483.59, 476.87, 479.5, 221, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TCH1!', 'continuous', 'HKEX', 'TCH', '腾讯控股', '2026-08-10', 482.05, 484.1, 477.5, 483.44, 284, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TCH1!', 'continuous', 'HKEX', 'TCH', '腾讯控股', '2026-08-11', 480.8, 480.8, 471.75, 471.75, 133, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- HKEX:TWR1!  新增 5 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('HKEX:TWR1!', 'continuous', 'HKEX', 'TWR', '中国铁塔', '2026-08-05', 9.95, 9.95, 9.95, 9.95, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TWR1!', 'continuous', 'HKEX', 'TWR', '中国铁塔', '2026-08-06', 9.82, 9.82, 9.82, 9.82, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TWR1!', 'continuous', 'HKEX', 'TWR', '中国铁塔', '2026-08-07', 9.75, 9.75, 9.75, 9.75, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TWR1!', 'continuous', 'HKEX', 'TWR', '中国铁塔', '2026-08-10', 9.77, 9.77, 9.77, 9.77, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('HKEX:TWR1!', 'continuous', 'HKEX', 'TWR', '中国铁塔', '2026-08-11', 9.63, 9.63, 9.63, 9.63, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:BZ1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:BZ1!', 'continuous', 'NYMEX', 'BZ', '布伦特原油最后结算', '2026-08-04', 78.93, 80.93, 78.13, 79.45, 43282, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:BZ1!', 'continuous', 'NYMEX', 'BZ', '布伦特原油最后结算', '2026-08-05', 79.43, 83.77, 78.98, 82.49, 40651, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:BZ1!', 'continuous', 'NYMEX', 'BZ', '布伦特原油最后结算', '2026-08-06', 83.33, 84.39, 81.5, 83.55, 37626, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:BZ1!', 'continuous', 'NYMEX', 'BZ', '布伦特原油最后结算', '2026-08-09', 83.56, 87.92, 83.34, 87.72, 28808, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:BZ1!', 'continuous', 'NYMEX', 'BZ', '布伦特原油最后结算', '2026-08-10', 87.97, 88.06, 87.53, 87.88, 1171, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:MCL1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:MCL1!', 'continuous', 'NYMEX', 'MCL', '微型美原油', '2026-08-04', 75.15, 76.7, 74.22, 75.22, 169388, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:MCL1!', 'continuous', 'NYMEX', 'MCL', '微型美原油', '2026-08-05', 74.94, 78.53, 74.58, 77.29, 145665, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:MCL1!', 'continuous', 'NYMEX', 'MCL', '微型美原油', '2026-08-06', 78.2, 78.77, 76.51, 78.18, 130979, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:MCL1!', 'continuous', 'NYMEX', 'MCL', '微型美原油', '2026-08-09', 78.34, 82.39, 77.78, 82.13, 143912, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:MCL1!', 'continuous', 'NYMEX', 'MCL', '微型美原油', '2026-08-10', 82.3, 82.56, 81.97, 82.26, 14738, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:PA1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:PA1!', 'continuous', 'NYMEX', 'PA', '美钯金', '2026-08-04', 1341.0, 1397.0, 1334.5, 1370.1, 7102, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PA1!', 'continuous', 'NYMEX', 'PA', '美钯金', '2026-08-05', 1375.5, 1400.5, 1366.5, 1377.4, 4821, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PA1!', 'continuous', 'NYMEX', 'PA', '美钯金', '2026-08-06', 1380.0, 1412.0, 1365.5, 1378.3, 5732, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PA1!', 'continuous', 'NYMEX', 'PA', '美钯金', '2026-08-09', 1386.0, 1391.5, 1356.5, 1381.4, 4772, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PA1!', 'continuous', 'NYMEX', 'PA', '美钯金', '2026-08-10', 1389.5, 1407.5, 1385.5, 1392.5, 730, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:PL1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:PL1!', 'continuous', 'NYMEX', 'PL', '美铂金', '2026-08-04', 1742.8, 1798.3, 1726.6, 1746.9, 21876, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PL1!', 'continuous', 'NYMEX', 'PL', '美铂金', '2026-08-05', 1752.2, 1797.9, 1728.0, 1737.9, 16419, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PL1!', 'continuous', 'NYMEX', 'PL', '美铂金', '2026-08-06', 1742.7, 1796.2, 1730.0, 1759.6, 15401, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PL1!', 'continuous', 'NYMEX', 'PL', '美铂金', '2026-08-09', 1755.1, 1778.0, 1730.6, 1753.6, 12940, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:PL1!', 'continuous', 'NYMEX', 'PL', '美铂金', '2026-08-10', 1767.9, 1788.6, 1762.7, 1768.1, 2655, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- NYMEX:RB1!  新增 5 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('NYMEX:RB1!', 'continuous', 'NYMEX', 'RB', '无铅汽油', '2026-08-04', 2.8422, 2.888, 2.7975, 2.8388, 54205, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:RB1!', 'continuous', 'NYMEX', 'RB', '无铅汽油', '2026-08-05', 2.8338, 2.9615, 2.8086, 2.9385, 46867, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:RB1!', 'continuous', 'NYMEX', 'RB', '无铅汽油', '2026-08-06', 2.958, 3.0111, 2.9251, 2.9853, 55500, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:RB1!', 'continuous', 'NYMEX', 'RB', '无铅汽油', '2026-08-09', 2.982, 3.148, 2.98, 3.1354, 41532, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('NYMEX:RB1!', 'continuous', 'NYMEX', 'RB', '无铅汽油', '2026-08-10', 3.1359, 3.1423, 3.1209, 3.1339, 692, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:CN1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:CN1!', 'continuous', 'SGX', 'CN', '富时中国指数A50', '2026-08-05', 14891.0, 14968.0, 14744.0, 14934.0, 282654, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:CN1!', 'continuous', 'SGX', 'CN', '富时中国指数A50', '2026-08-06', 14930.0, 15094.0, 14903.0, 15045.0, 283671, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:CN1!', 'continuous', 'SGX', 'CN', '富时中国指数A50', '2026-08-07', 15043.0, 15109.0, 14928.0, 15045.0, 255319, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:CN1!', 'continuous', 'SGX', 'CN', '富时中国指数A50', '2026-08-10', 15040.0, 15058.0, 14921.0, 15034.0, 137012, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:FCH1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:FCH1!', 'continuous', 'SGX', 'FCH', '富時中國H50指數', '2026-08-05', 16530.0, 16530.0, 16305.0, 16372.5, 951, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:FCH1!', 'continuous', 'SGX', 'FCH', '富時中國H50指數', '2026-08-06', 16390.0, 16400.0, 16212.5, 16400.0, 881, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:FCH1!', 'continuous', 'SGX', 'FCH', '富時中國H50指數', '2026-08-07', 16387.5, 16560.0, 16360.0, 16537.5, 683, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:FCH1!', 'continuous', 'SGX', 'FCH', '富時中國H50指數', '2026-08-10', 16510.0, 16640.0, 16410.0, 16410.0, 461, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:MUC1!  新增 4 行 (trade_date > 2026-08-03)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:MUC1!', 'continuous', 'SGX', 'MUC', '小型美元兑人民币', '2026-08-04', 6.7416, 6.7444, 6.7416, 6.7444, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:MUC1!', 'continuous', 'SGX', 'MUC', '小型美元兑人民币', '2026-08-05', 6.7426, 6.7451, 6.7424, 6.7451, 14, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:MUC1!', 'continuous', 'SGX', 'MUC', '小型美元兑人民币', '2026-08-06', 6.7429, 6.7441, 6.7423, 6.7426, 19, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:MUC1!', 'continuous', 'SGX', 'MUC', '小型美元兑人民币', '2026-08-07', 6.7408, 6.744, 6.7408, 6.7408, 82, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:NK1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:NK1!', 'continuous', 'SGX', 'NK', '日经225指数', '2026-08-05', 66220.0, 66805.0, 64980.0, 65535.0, 17644, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:NK1!', 'continuous', 'SGX', 'NK', '日经225指数', '2026-08-06', 65635.0, 66350.0, 64695.0, 65710.0, 15021, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:NK1!', 'continuous', 'SGX', 'NK', '日经225指数', '2026-08-07', 65750.0, 67165.0, 65685.0, 67085.0, 16168, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:NK1!', 'continuous', 'SGX', 'NK', '日经225指数', '2026-08-10', 67090.0, 67590.0, 66315.0, 67065.0, 5832, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:TF1!  新增 1 行 (trade_date > 2026-07-30)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:TF1!', 'continuous', 'SGX', 'TF', 'TSR20橡胶', '2026-08-10', 219.5, 220.5, 219.0, 219.9, 119, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- SGX:UC1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('SGX:UC1!', 'continuous', 'SGX', 'UC', '美元兑人民币', '2026-08-05', 6.7437, 6.7478, 6.7412, 6.7451, 34843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:UC1!', 'continuous', 'SGX', 'UC', '美元兑人民币', '2026-08-06', 6.7452, 6.7474, 6.7418, 6.7426, 14858, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:UC1!', 'continuous', 'SGX', 'UC', '美元兑人民币', '2026-08-07', 6.7432, 6.7448, 6.7366, 6.741, 47366, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('SGX:UC1!', 'continuous', 'SGX', 'UC', '美元兑人民币', '2026-08-10', 6.7416, 6.7452, 6.7413, 6.7431, 8609, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
-- ZCE:TA1!  新增 4 行 (trade_date > 2026-08-04)
INSERT INTO public.futures_kline_daily
  (contract_code, contract_type, exchange, exchange_code, variety, trade_date,
   open_price, high_price, low_price, close_price, volume, created_at, updated_at, contract_month_date)
VALUES
  ('ZCE:TA1!', 'continuous', 'ZCE', 'TA', '精对苯二甲酸 PTA', '2026-08-05', 5844.0, 5850.0, 5726.0, 5772.0, 36, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('ZCE:TA1!', 'continuous', 'ZCE', 'TA', '精对苯二甲酸 PTA', '2026-08-06', 5872.0, 5932.0, 5872.0, 5874.0, 1069, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('ZCE:TA1!', 'continuous', 'ZCE', 'TA', '精对苯二甲酸 PTA', '2026-08-07', 5910.0, 5912.0, 5812.0, 5870.0, 16, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
  ('ZCE:TA1!', 'continuous', 'ZCE', 'TA', '精对苯二甲酸 PTA', '2026-08-10', 5870.0, 5870.0, 5796.0, 5802.0, 51, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

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
