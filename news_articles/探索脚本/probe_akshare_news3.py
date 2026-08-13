import akshare as ak, inspect

# 看 futures_news_shmet 签名
print("futures_news_shmet sig:", inspect.signature(ak.futures_news_shmet))
print("doc:", (ak.futures_news_shmet.__doc__ or "")[:600])

# 搜索含 futures/news/spot 的函数
funcs = [n for n in dir(ak) if any(k in n.lower() for k in ['futures_news','news_fut','spot','cffex','dce','zce','shfe','ine'])]
print("\ncandidates:", funcs)

# 试试 stock_news_em 能否用期货代码（一般不行），但看看期货品种新闻是否有专用
# 直接列所有含 'news' 的函数全貌
allnews = [n for n in dir(ak) if 'news' in n.lower()]
print("\nALL news funcs:")
for n in allnews:
    try:
        sig = inspect.signature(getattr(ak, n))
        print(" ", n, sig)
    except Exception:
        print(" ", n, "(no sig)")
