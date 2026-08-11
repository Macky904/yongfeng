-- ============================================================
-- 国内交易所期权交易费 -> symbol.exchange_fee
-- 来源：D:/期货手续费核对/期货期权手续费总表_单表_期权核验版.xlsx（期权核验版）
-- 范围：CFFEX/DCE/GFEX/INE/SHFE/ZCE 期权；仅更新期权行，不新建列
-- 存值：交易所基准手续费整段（交易x；行权y），与期货 exchange_fee 同风格
-- 更新行数：69 ；跳过(未上市/不适用)：4 ；无对应symbol行：3
-- ============================================================

-- DCE 期权 A 黄大豆1号期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'A' AND exchange_code = 'DCE 期权';

-- DCE 期权 A_MS 黄大豆1号系列期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'A_MS' AND exchange_code = 'DCE 期权';

-- DCE 期权 B 黄大豆2号期权
UPDATE public.symbol SET exchange_fee = '交易0.2元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'B' AND exchange_code = 'DCE 期权';

-- DCE 期权 BZ_O 纯苯期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'BZ_O' AND exchange_code = 'DCE 期权';

-- DCE 期权 C 玉米期权
UPDATE public.symbol SET exchange_fee = '交易0.6元/手；行权0.6元/手', updated_at = NOW() WHERE symbol_code = 'C' AND exchange_code = 'DCE 期权';

-- DCE 期权 C_MS 玉米系列期权
UPDATE public.symbol SET exchange_fee = '交易0.6元/手；行权0.6元/手', updated_at = NOW() WHERE symbol_code = 'C_MS' AND exchange_code = 'DCE 期权';

-- DCE 期权 CS_O 玉米淀粉期权
UPDATE public.symbol SET exchange_fee = '交易0.2元/手；行权0.2元/手', updated_at = NOW() WHERE symbol_code = 'CS_O' AND exchange_code = 'DCE 期权';

-- DCE 期权 EB 苯乙烯期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'EB' AND exchange_code = 'DCE 期权';

-- DCE 期权 EG 乙二醇期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'EG' AND exchange_code = 'DCE 期权';

-- DCE 期权 I 铁矿石期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'I' AND exchange_code = 'DCE 期权';

-- DCE 期权 JD_O 鸡蛋期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'JD_O' AND exchange_code = 'DCE 期权';

-- DCE 期权 JM_O 焦煤期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'JM_O' AND exchange_code = 'DCE 期权';

-- DCE 期权 L 聚乙烯期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'L' AND exchange_code = 'DCE 期权';

-- DCE 期权 LG_O 原木期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'LG_O' AND exchange_code = 'DCE 期权';

-- DCE 期权 LH_O 生猪期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'LH_O' AND exchange_code = 'DCE 期权';

-- DCE 期权 M 豆粕期权
UPDATE public.symbol SET exchange_fee = '交易1元/手（日内0.5元/手）；行权1元/手', updated_at = NOW() WHERE symbol_code = 'M' AND exchange_code = 'DCE 期权';

-- DCE 期权 M_MS 豆粕系列期权
UPDATE public.symbol SET exchange_fee = '交易1元/手（日内0.5元/手）；行权1元/手', updated_at = NOW() WHERE symbol_code = 'M_MS' AND exchange_code = 'DCE 期权';

-- DCE 期权 P 棕榈油期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'P' AND exchange_code = 'DCE 期权';

-- DCE 期权 PG 液化石油气期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'PG' AND exchange_code = 'DCE 期权';

-- DCE 期权 PP 聚丙烯期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'PP' AND exchange_code = 'DCE 期权';

-- DCE 期权 V 聚氯乙烯期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'V' AND exchange_code = 'DCE 期权';

-- DCE 期权 Y 豆油期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'Y' AND exchange_code = 'DCE 期权';

-- DCE 期权 Y_MS 豆油系列期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'Y_MS' AND exchange_code = 'DCE 期权';

-- GFEX 期权 LC 碳酸锂期权
UPDATE public.symbol SET exchange_fee = '交易3元/手；行权3元/手', updated_at = NOW() WHERE symbol_code = 'LC' AND exchange_code = 'GFEX 期权';

-- GFEX 期权 PD 钯期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'PD' AND exchange_code = 'GFEX 期权';

-- GFEX 期权 PS 多晶硅期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'PS' AND exchange_code = 'GFEX 期权';

-- GFEX 期权 PT 铂期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'PT' AND exchange_code = 'GFEX 期权';

-- GFEX 期权 SI 工业硅期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'SI' AND exchange_code = 'GFEX 期权';

-- INE 期权 BC 国际铜期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'BC' AND exchange_code = 'INE 期权';

-- INE 期权 NR_O 20号胶期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'NR_O' AND exchange_code = 'INE 期权';

-- INE 期权 SC 原油期权
UPDATE public.symbol SET exchange_fee = '交易10元/手；行权10元/手', updated_at = NOW() WHERE symbol_code = 'SC' AND exchange_code = 'INE 期权';

-- SHFE 期权 AD_O 铸造铝合金期权
UPDATE public.symbol SET exchange_fee = '交易5元/手；行权5元/手', updated_at = NOW() WHERE symbol_code = 'AD_O' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 AG 白银期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'AG' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 AL 铝期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'AL' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 AO 氧化铝期权
UPDATE public.symbol SET exchange_fee = '交易3.5元/手；行权3.5元/手', updated_at = NOW() WHERE symbol_code = 'AO' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 AU 黄金期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'AU' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 BR 丁二烯橡胶期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'BR' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 BU 石油沥青期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'BU' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 CU 铜期权
UPDATE public.symbol SET exchange_fee = '交易5元/手；行权5元/手', updated_at = NOW() WHERE symbol_code = 'CU' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 FU 燃料油期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'FU' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 NI_O 镍期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'NI_O' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 OP_O 胶版印刷纸期权
UPDATE public.symbol SET exchange_fee = '交易5元/手；行权5元/手', updated_at = NOW() WHERE symbol_code = 'OP_O' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 PB 铅期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'PB' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 RB 螺纹钢期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'RB' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 RU 天然橡胶期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'RU' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 SN 锡期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'SN' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 SP_O 纸浆期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'SP_O' AND exchange_code = 'SHFE 期权';

-- SHFE 期权 ZN 锌期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'ZN' AND exchange_code = 'SHFE 期权';

-- ZCE 期权 AP 苹果期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'AP' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 CF 棉花期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'CF' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 CJ 红枣期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'CJ' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 FGC/FGP 玻璃期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'FGC/FGP' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 MA 甲醇期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'MA' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 OI 菜籽油期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'OI' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 PF 短纤期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'PF' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 PK 花生期权
UPDATE public.symbol SET exchange_fee = '交易0.8元/手；行权0.8元/手', updated_at = NOW() WHERE symbol_code = 'PK' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 PLC/PLP 丙烯期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'PLC/PLP' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 PRC/PRP 瓶片期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'PRC/PRP' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 PX 对二甲苯期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'PX' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 RM 菜粕期权
UPDATE public.symbol SET exchange_fee = '交易0.8元/手；行权0.8元/手', updated_at = NOW() WHERE symbol_code = 'RM' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 SA 纯碱期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'SA' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 SF 硅铁期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'SF' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 SH 烧碱期权
UPDATE public.symbol SET exchange_fee = '交易2元/手；行权2元/手', updated_at = NOW() WHERE symbol_code = 'SH' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 SM 锰硅期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'SM' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 SR 白糖期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'SR' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 SRMSC/SRMSP 白糖系列期权
UPDATE public.symbol SET exchange_fee = '交易1.5元/手；行权1.5元/手', updated_at = NOW() WHERE symbol_code = 'SRMSC/SRMSP' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 TA PTA期权
UPDATE public.symbol SET exchange_fee = '交易0.5元/手；行权0.5元/手', updated_at = NOW() WHERE symbol_code = 'TA' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 UR 尿素期权
UPDATE public.symbol SET exchange_fee = '交易1元/手；行权1元/手', updated_at = NOW() WHERE symbol_code = 'UR' AND exchange_code = 'ZCE 期权';

-- ZCE 期权 ZCC/ZCP 动力煤期权
UPDATE public.symbol SET exchange_fee = '交易150元/手；行权150元/手', updated_at = NOW() WHERE symbol_code = 'ZCC/ZCP' AND exchange_code = 'ZCE 期权';
