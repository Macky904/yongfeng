import urllib.request, urllib.parse, json, time

def em_search(keyword, pagesize=10):
    # 东方财富 搜索 (so.eastmoney.com 公开搜索 jsonp)
    payload = {
        "phone": "1",
        "searchType": "0",          # 0=资讯
        "pageSize": pagesize,
        "pageIndex": 1,
        "keyword": keyword,
        "type": "web",
    }
    param = urllib.parse.quote(json.dumps(payload, ensure_ascii=False))
    url = f"https://search-api-web.eastmoney.com/search/jsonp?cb=cb&param={param}"
    headers = {"User-Agent": "Mozilla/5.0", "Referer": "https://so.eastmoney.com/"}
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=20) as r:
            txt = r.read().decode("utf-8")
        s = txt.index("(") + 1
        e = txt.rindex(")")
        data = json.loads(txt[s:e])
        return data
    except Exception as ex:
        print("  err:", repr(ex))
        return None

for kw in ["豆粕", "豆油", "棕榈油"]:
    print("====", kw, "====")
    d = em_search(kw)
    if not d:
        continue
    # 自适应取列表
    lst = None
    for k in ("NewsList", "List", "list"):
        if isinstance(d.get(k), list):
            lst = d[k]; break
    if lst is None and isinstance(d.get("data"), dict):
        for k in ("NewsList", "List"):
            if isinstance(d["data"].get(k), list):
                lst = d["data"][k]; break
    print("  got items:", len(lst) if lst else 0)
    for it in (lst or [])[:3]:
        title = it.get("title") or it.get("Title") or it.get("name")
        date = it.get("date") or it.get("Date") or it.get("datetime") or it.get("publishTime")
        link = it.get("url") or it.get("Url") or it.get("link") or it.get("href")
        print("   -", title, "|", date, "|", link)
    time.sleep(1)
