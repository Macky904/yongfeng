-- ============================================================
-- 04_update_exchange_fee_verified.sql
-- 生成时间：2026-08-09
-- 作用：把人工核验通过的《期货交易手续费明细_手续费字段精简版》
--       中的「期货交易手续费」列，写入 public.symbol.exchange_fee
--
-- 背景：
--   02_add_futures_trading_fee.sql（全网搜集，未核验）已作废并于 03 中删列。
--   本次数据经交易所官网 PDF/XLSX 逐项复核，统一回填到既有的 exchange_fee 列，
--   不再新增字段。
--
-- 规则：
--   1. 期货品种共 208 个，其中 206 个按核验表写入；
--   2. SC(INE 原油)、I(DCE 铁矿石) 保留原有更完整的表述，本脚本不覆盖：
--        SC = '一般交易20元/手，套保10元/手'
--        I  = '成交金额万分之 1（1‱）；非 1/5/9 合约万分之 0.1'
--   3. 期权品种（110 个）不填手续费，保持 NULL；
--   4. NYMEX/COMEX 部分品种费率官方标注 2026-08-17 生效，按用户要求照常写入。
--
-- 口径：交易所/清算机构公布的一手（每边）交易手续费，
--       不含期货公司佣金、税费、交割费、申报费等。
-- ============================================================

BEGIN;

-- ---------- BMD ----------
UPDATE public.symbol SET exchange_fee = 'RM2.00/contract' WHERE symbol_code = 'CPO' AND exchange_code = 'BMD';  -- 来源: bursamalaysia.com
-- ---------- CBOE ----------
UPDATE public.symbol SET exchange_fee = 'US$1.51/contract/side（Customer）' WHERE symbol_code = 'VX' AND exchange_code = 'CBOE';  -- 来源: cdn.cboe.com
-- ---------- CBOT ----------
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'C' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'KW' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.35 per side' WHERE symbol_code = 'MYM' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'O' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'S' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'W' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.38 per side' WHERE symbol_code = 'YM' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.06 per side' WHERE symbol_code = 'YW' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.87 per side' WHERE symbol_code = 'ZB' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.65 per side' WHERE symbol_code = 'ZF' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'ZL' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'ZM' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.80 per side' WHERE symbol_code = 'ZN' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'ZR' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.65 per side' WHERE symbol_code = 'ZT' AND exchange_code = 'CBOT';  -- 来源: cmegroup.com
-- ---------- CFFEX ----------
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.23（开平仓）；平今仓成交金额万分之2.3' WHERE symbol_code = 'IC' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.23（开平仓）；平今仓成交金额万分之2.3' WHERE symbol_code = 'IF' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.23（开平仓）；平今仓成交金额万分之2.3' WHERE symbol_code = 'IH' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.23（开平仓）；平今仓成交金额万分之2.3' WHERE symbol_code = 'IM' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手；平今仓免收' WHERE symbol_code = 'T' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手；平今仓免收' WHERE symbol_code = 'TF' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手；平今仓免收' WHERE symbol_code = 'TL' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手；平今仓免收' WHERE symbol_code = 'TS' AND exchange_code = 'CFFEX';  -- 来源: cffex.com.cn
-- ---------- CME ----------
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'AD' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'BP' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'CD' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'EC' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.38 per side' WHERE symbol_code = 'ES' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.10 per side' WHERE symbol_code = 'FC' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'JY' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.10 per side' WHERE symbol_code = 'LC' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.10 per side' WHERE symbol_code = 'LN' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.35 per side' WHERE symbol_code = 'M2K' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.35 per side' WHERE symbol_code = 'MES' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.35 per side' WHERE symbol_code = 'MNQ' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'NE' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$2.15 per side' WHERE symbol_code = 'NKD' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.38 per side' WHERE symbol_code = 'NQ' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.38 per side' WHERE symbol_code = 'RTY' AND exchange_code = 'CME';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'SF' AND exchange_code = 'CME';  -- 来源: cmegroup.com
-- ---------- COMEX ----------
UPDATE public.symbol SET exchange_fee = '$1.65 per side' WHERE symbol_code = 'GC' AND exchange_code = 'COMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.65 per side' WHERE symbol_code = 'HG' AND exchange_code = 'COMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.70 per side' WHERE symbol_code = 'MGC' AND exchange_code = 'COMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.50 per side' WHERE symbol_code = 'QI' AND exchange_code = 'COMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.50 per side' WHERE symbol_code = 'QO' AND exchange_code = 'COMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.65 per side' WHERE symbol_code = 'SI' AND exchange_code = 'COMEX';  -- 来源: cmegroup.com
-- ---------- DCE ----------
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'A' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手' WHERE symbol_code = 'B' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'BB' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手；套期保值1.5元/手' WHERE symbol_code = 'BZ' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1.2元/手' WHERE symbol_code = 'C' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1.5元/手' WHERE symbol_code = 'CS' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手；套期保值0.5元/手' WHERE symbol_code = 'EB' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'EG' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'FB' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1（日内交易万分之1.4）' WHERE symbol_code = 'J' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1.5' WHERE symbol_code = 'JD' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'JM' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手' WHERE symbol_code = 'L' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'LG' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1（日内交易万分之2）' WHERE symbol_code = 'LH' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手（月均价参考合约；套保0.5元/手）' WHERE symbol_code = 'L_F' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1.5元/手' WHERE symbol_code = 'M' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '2.5元/手' WHERE symbol_code = 'P' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '6元/手' WHERE symbol_code = 'PG' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手' WHERE symbol_code = 'PP' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手（月均价参考合约；套保0.5元/手）' WHERE symbol_code = 'PP_F' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手' WHERE symbol_code = 'RR' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手' WHERE symbol_code = 'V' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '1元/手（月均价参考合约；套保0.5元/手）' WHERE symbol_code = 'V_F' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
UPDATE public.symbol SET exchange_fee = '2.5元/手' WHERE symbol_code = 'Y' AND exchange_code = 'DCE';  -- 来源: dce.com.cn
-- ---------- EUREX ----------
UPDATE public.symbol SET exchange_fee = 'EUR 0.70/contract（M/P账户；A账户EUR 1.50）' WHERE symbol_code = 'DAX' AND exchange_code = 'EUREX';  -- 来源: eurex.com
UPDATE public.symbol SET exchange_fee = 'EUR 0.18/contract（M/P账户；A账户EUR 0.24）' WHERE symbol_code = 'DXM' AND exchange_code = 'EUREX';  -- 来源: eurex.com
UPDATE public.symbol SET exchange_fee = 'EUR 0.32/contract（M/P账户；A账户EUR 0.40）' WHERE symbol_code = 'ESX' AND exchange_code = 'EUREX';  -- 来源: eurex.com
UPDATE public.symbol SET exchange_fee = 'EUR 0.20/contract（M/P账户；A账户EUR 0.27）' WHERE symbol_code = 'GBS' AND exchange_code = 'EUREX';  -- 来源: eurex.com
-- ---------- GFEX ----------
UPDATE public.symbol SET exchange_fee = '成交金额万分之1.6；日内平今仓成交金额万分之3.2' WHERE symbol_code = 'LC' AND exchange_code = 'GFEX';  -- 来源: gfex.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1；免收日内平今仓；套期保值万分之0.5' WHERE symbol_code = 'PD' AND exchange_code = 'GFEX';  -- 来源: gfex.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1；日内平今仓成交金额万分之2.5' WHERE symbol_code = 'PS' AND exchange_code = 'GFEX';  -- 来源: gfex.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1；免收日内平今仓；套期保值万分之0.5' WHERE symbol_code = 'PT' AND exchange_code = 'GFEX';  -- 来源: gfex.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1；免收日内平今仓' WHERE symbol_code = 'SI' AND exchange_code = 'GFEX';  -- 来源: gfex.com.cn
-- ---------- HKEX ----------
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'A50' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'ALB' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'AMC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'BOC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'BUD' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CCB' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CCC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CHT' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CLI' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CMB' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CNC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CPC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CSA' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'CTC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'RMB8.00/Lot' WHERE symbol_code = 'CUS' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'GWM' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'HEX' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'HK$3.50/Lot' WHERE symbol_code = 'HHI' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'HKB' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'HK$10.00/Lot' WHERE symbol_code = 'HSI' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'HK$5.00/Lot' WHERE symbol_code = 'HTI' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'ICB' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'JDC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'US$1.00/Lot' WHERE symbol_code = 'MCA' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'HK$2.00/Lot' WHERE symbol_code = 'MCH' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'RMB1.60/Lot' WHERE symbol_code = 'MCS' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'MET' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'HK$3.50/Lot' WHERE symbol_code = 'MHI' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'MIU' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'US$1.00/Lot' WHERE symbol_code = 'MTW' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'NTE' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'PAI' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'PEC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'PIC' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'TCH' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
UPDATE public.symbol SET exchange_fee = 'Tier1 HK$3.00 / Tier2 HK$1.00 / Tier3 HK$0.50/Lot（按合约名义价值分层）' WHERE symbol_code = 'TWR' AND exchange_code = 'HKEX';  -- 来源: hkex.com.hk
-- ---------- ICEU ----------
UPDATE public.symbol SET exchange_fee = 'US$0.28/side/lot' WHERE symbol_code = 'B' AND exchange_code = 'ICEU';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'US$0.28/side/lot' WHERE symbol_code = 'G' AND exchange_code = 'ICEU';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'GBP 0.23/side/lot' WHERE symbol_code = 'RC' AND exchange_code = 'ICEU';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'US$0.28/side/lot' WHERE symbol_code = 'T' AND exchange_code = 'ICEU';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'GBP 0.23/side/lot' WHERE symbol_code = 'W' AND exchange_code = 'ICEU';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'GBP 0.17/side/lot' WHERE symbol_code = 'Z' AND exchange_code = 'ICEU';  -- 来源: ice.com
-- ---------- ICUS ----------
UPDATE public.symbol SET exchange_fee = 'US$2.10/side（screen trades）' WHERE symbol_code = 'CC' AND exchange_code = 'ICUS';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'US$2.10/side（screen trades）' WHERE symbol_code = 'CT' AND exchange_code = 'ICUS';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'US$1.35/side（screen trades）' WHERE symbol_code = 'DX' AND exchange_code = 'ICUS';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'US$2.10/side（screen trades）' WHERE symbol_code = 'KC' AND exchange_code = 'ICUS';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'US$2.10/side（screen trades）' WHERE symbol_code = 'OJ' AND exchange_code = 'ICUS';  -- 来源: ice.com
UPDATE public.symbol SET exchange_fee = 'US$2.10/side（screen trades）' WHERE symbol_code = 'SB' AND exchange_code = 'ICUS';  -- 来源: ice.com
-- ---------- INE ----------
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.1（0.01‰）' WHERE symbol_code = 'BC' AND exchange_code = 'INE';  -- 来源: ine.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之6（0.6‰）' WHERE symbol_code = 'EC' AND exchange_code = 'INE';  -- 来源: ine.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.1（0.01‰）' WHERE symbol_code = 'LU' AND exchange_code = 'INE';  -- 来源: ine.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.2（0.02‰）' WHERE symbol_code = 'NR' AND exchange_code = 'INE';  -- 来源: ine.cn
-- ---------- LME ----------
UPDATE public.symbol SET exchange_fee = 'US$0.88/lot/side' WHERE symbol_code = 'AH' AND exchange_code = 'LME';  -- 来源: lme.com
UPDATE public.symbol SET exchange_fee = 'US$0.88/lot/side' WHERE symbol_code = 'CA' AND exchange_code = 'LME';  -- 来源: lme.com
UPDATE public.symbol SET exchange_fee = 'US$0.88/lot/side' WHERE symbol_code = 'NI' AND exchange_code = 'LME';  -- 来源: lme.com
UPDATE public.symbol SET exchange_fee = 'US$0.88/lot/side' WHERE symbol_code = 'PB' AND exchange_code = 'LME';  -- 来源: lme.com
UPDATE public.symbol SET exchange_fee = 'US$0.88/lot/side' WHERE symbol_code = 'SN' AND exchange_code = 'LME';  -- 来源: lme.com
UPDATE public.symbol SET exchange_fee = 'US$0.88/lot/side' WHERE symbol_code = 'ZS' AND exchange_code = 'LME';  -- 来源: lme.com
-- ---------- NYMEX ----------
UPDATE public.symbol SET exchange_fee = '$0.77 per side' WHERE symbol_code = 'BZ' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.50 per side' WHERE symbol_code = 'CL' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.50 per side' WHERE symbol_code = 'HO' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.50 per side' WHERE symbol_code = 'MCL' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.60 per side' WHERE symbol_code = 'NG' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.65 per side' WHERE symbol_code = 'PA' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.65 per side' WHERE symbol_code = 'PL' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$0.50 per side' WHERE symbol_code = 'QG' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.20 per side' WHERE symbol_code = 'QM' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
UPDATE public.symbol SET exchange_fee = '$1.50 per side' WHERE symbol_code = 'RB' AND exchange_code = 'NYMEX';  -- 来源: cmegroup.com
-- ---------- OSE ----------
UPDATE public.symbol SET exchange_fee = 'JPY 59/contract' WHERE symbol_code = 'JRU' AND exchange_code = 'OSE';  -- 来源: jpx.co.jp
-- ---------- SGX ----------
UPDATE public.symbol SET exchange_fee = 'US$1.10/lot' WHERE symbol_code = 'CN' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
UPDATE public.symbol SET exchange_fee = 'US$0.60/lot' WHERE symbol_code = 'FCH' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
UPDATE public.symbol SET exchange_fee = 'US$2.20/lot' WHERE symbol_code = 'FE' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
UPDATE public.symbol SET exchange_fee = 'US$0.30/lot' WHERE symbol_code = 'MUC' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
UPDATE public.symbol SET exchange_fee = 'US$0.60/lot' WHERE symbol_code = 'NK' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
UPDATE public.symbol SET exchange_fee = 'SGD 2.05/lot' WHERE symbol_code = 'SG' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
UPDATE public.symbol SET exchange_fee = 'US$1.20/lot' WHERE symbol_code = 'TF' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
UPDATE public.symbol SET exchange_fee = 'US$1.00/lot' WHERE symbol_code = 'UC' AND exchange_code = 'SGX';  -- 来源: api2.sgx.com
-- ---------- SHFE ----------
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5（0.05‰）' WHERE symbol_code = 'AD' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5（0.05‰）' WHERE symbol_code = 'AG' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'AL' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1（0.1‰）' WHERE symbol_code = 'AO' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '20元/手' WHERE symbol_code = 'AU' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.2（0.02‰）' WHERE symbol_code = 'BR' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5（0.05‰）' WHERE symbol_code = 'BU' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5（0.05‰）' WHERE symbol_code = 'CU' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5（0.05‰）' WHERE symbol_code = 'FU' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1（0.1‰）' WHERE symbol_code = 'HC' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'NI' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5（0.05‰）' WHERE symbol_code = 'OP' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.4（0.04‰）' WHERE symbol_code = 'PB' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1（0.1‰）' WHERE symbol_code = 'RB' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'RU' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'SN' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5（0.05‰）' WHERE symbol_code = 'SP' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'SS' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.4（0.04‰）' WHERE symbol_code = 'WR' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'ZN' AND exchange_code = 'SHFE';  -- 来源: shfe.com.cn
-- ---------- ZCE ----------
UPDATE public.symbol SET exchange_fee = '5元/手；日内平今仓10元/手（2026年6月8日起由20元/手调整为10元/手）' WHERE symbol_code = 'AP' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '4.3元/手' WHERE symbol_code = 'CF' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'CJ' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '4元/手' WHERE symbol_code = 'CY' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'FG' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'JR' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'LR' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'MA' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'OI' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'PF' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手；日内平今仓2元/手' WHERE symbol_code = 'PK' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手；免收日内平今仓' WHERE symbol_code = 'PL' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '30元/手' WHERE symbol_code = 'PM' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之0.5' WHERE symbol_code = 'PR' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'PX' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2.5元/手' WHERE symbol_code = 'RI' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '1.5元/手；免收日内平今仓' WHERE symbol_code = 'RM' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'RS' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'SA' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'SF' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'SH' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'SM' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '2元/手' WHERE symbol_code = 'SR' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '3元/手' WHERE symbol_code = 'TA' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '成交金额万分之1' WHERE symbol_code = 'UR' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '30元/手' WHERE symbol_code = 'WH' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn
UPDATE public.symbol SET exchange_fee = '150元/手' WHERE symbol_code = 'ZC' AND exchange_code = 'ZCE';  -- 来源: czce.com.cn

COMMIT;

-- ---------- 验证 ----------
-- SELECT count(*) FROM public.symbol WHERE exchange_fee IS NOT NULL AND exchange_fee <> '';
--   预期：208（206 本次写入 + SC/I 2 个保留旧值）
-- SELECT exchange_code, count(*) FROM public.symbol
--   WHERE exchange_fee IS NOT NULL AND exchange_fee <> '' GROUP BY 1 ORDER BY 1;