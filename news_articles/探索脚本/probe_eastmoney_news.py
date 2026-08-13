import urllib.request, urllib.parse, json, time

def fetch_em_news(keyword, pagesize=10):
    # 东方财富 新闻搜索 (公开接口)
    url = ("https://search-api-web.eastmoney.com/search/jsonp?"
           "cb=cb&param=" + urllib.parse.quote(json.dumps({
               "搜索关键词": keyword,
               "分页大小": pagesize,
               "页码": 1,
               "站点列表": ["19", "21"],  # 19=财经新闻, 21=滚动新闻
           }, ensure_ascii=False)))
    headers = {"User-Agent": "Mozilla/5.0", "Referer": "https://so.eastmoney.com/"}
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=20) as r:
            txt = r.read().decode("utf-8")
        # jsonp: cb({...})
        txt = txt[txt.index("(")+1: txt.rindex(")")]
        data = json.loads(txt)
        return data
    except Exception as e:
        print("  em err:", repr(e))
        return None

for kw in ["豆粕", "豆油", "棕榈油"]:
    print("==== keyword:", kw, "====")
    d = fetch_em_news(kw)
    if not d:
        continue
    # 不同结构自适应
    items = d.get("NewsList") or d.get("List") or d.get("data", {}).get("NewsList") or []
    print("  items:", len(items))
    for it in items[:3]:
        print("   -", it.get("title") or it.get("Title"), "|", it.get("date") or it.get("Date"), "|", it.get("url") or it.get("Url") or it.get("link"))
    time.sleep(1)
