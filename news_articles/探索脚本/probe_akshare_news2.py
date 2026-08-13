import akshare as ak, time

# 1) 通用新闻搜索 ak.news
print("==== ak.news(豆粕) ====")
try:
    df = ak.news(keyword="豆粕", start_date="20260801", end_date="20260807")
    print("rows:", len(df), "| cols:", list(df.columns))
    print(df.head(3).to_string())
except Exception as e:
    print("ERR ak.news:", repr(e)[:300])
time.sleep(1)

# 2) 期货新闻 futures_news_shmet
print("\n==== ak.futures_news_shmet ====")
try:
    df2 = ak.futures_news_shmet(symbol="豆粕")
    print("rows:", len(df2), "| cols:", list(df2.columns))
    print(df2.head(3).to_string())
except Exception as e:
    print("ERR futures_news_shmet:", repr(e)[:300])
time.sleep(1)

# 3) stock_news_em 思路不适用期货，跳过
# 4) 新浪期货新闻
print("\n==== ak.news_futures_sina? ====")
for fn in ["news_futures_sina", "futures_news_shmet", "news_report_time_baidu"]:
    print("  has", fn, hasattr(ak, fn))
