import akshare as ak, inspect, time

# 列出 akshare 里跟 news / 新闻 相关的函数
news_funcs = [n for n in dir(ak) if 'news' in n.lower()]
print("news-related funcs:", news_funcs[:40])

# 尝试常用期货/财经新闻接口
candidates = [
    "news_economic_baidu",          # 百度财经新闻
    "news_sina_roll",               # 新浪滚动新闻
    "news_futures_sina",            # 新浪期货新闻
    "news_eastmoney_roll",          # 东方财富滚动
]
for fn in candidates:
    if not hasattr(ak, fn):
        print(f"[skip] {fn} 不存在"); continue
    try:
        f = getattr(ak, fn)
        sig = str(inspect.signature(f))
        print(f"\n>>> try {fn}{sig}")
        df = f() if "symbol" not in sig else None
        if df is None:
            # 需要参数，尝试常见默认
            try:
                df = f("期货") if "symbol" in sig else f()
            except Exception as e2:
                print("   param err:", e2); continue
        print("   rows:", len(df))
        print("   cols:", list(df.columns)[:12])
        print(df.head(3).to_string())
        break
    except Exception as e:
        print(f"   ERR {fn}:", repr(e)[:200])
    time.sleep(1)
