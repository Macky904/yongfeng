-- 补充 CFFEX 股指期权(HO/IO/MO)交易所基准交易费至 symbol.exchange_fee
-- 来源：Excel《期货期权手续费总表_单表_期权核验版》row217-219
--       中国金融期货交易所收费一览表2026-06（官网），核验结果=正确
-- 费用：交易15元/手；行权2元/手
begin;
update public.symbol set exchange_fee='交易15元/手；行权2元/手' where name='上证50股指期权' and exchange_code='CFFEX';
update public.symbol set exchange_fee='交易15元/手；行权2元/手' where name='沪深300股指期权' and exchange_code='CFFEX';
update public.symbol set exchange_fee='交易15元/手；行权2元/手' where name='中证1000股指期权' and exchange_code='CFFEX';
commit;
