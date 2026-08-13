import urllib.request, urllib.parse, re, time

UA = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

def baidu_news(keyword, rn=10):
    url = "https://news.baidu.com/ns?word=" + urllib.parse.quote(keyword) + f"&rn={rn}&tn=news&ct=1"
    req = urllib.request.Request(url, headers={**UA, "Referer": "https://news.baidu.com/"})
    with urllib.request.urlopen(req, timeout=20) as r:
        html = r.read().decode(r.headers.get_content_charset() or "utf-8", errors="ignore")
    # 百度新闻结果：<a ... class="news-title" ...>标题</a> 及链接在 data-url / href
    # 更稳：抓所有 <a href="http..." >标题</a> 带 target=_blank 的
    blocks = re.findall(r'<h3[^>]*class="[^"]*news-title[^"]*"[^>]*>.*?</h3>', html, re.S)
    out = []
    for b in blocks:
        tm = re.search(r'<a[^>]+href="(.*?)"[^>]*>(.*?)</a>', b, re.S)
        if tm:
            link = tm.group(1)
            title = re.sub(r'<[^>]+>', '', tm.group(2)).strip()
            out.append((title, link))
    # 退路：直接抓 h3 下 a
    if not out:
        for m in re.finditer(r'<h3[^>]*>.*?<a[^>]+href="(.*?)"[^>]*>(.*?)</a>.*?</h3>', html, re.S):
            out.append((re.sub(r'<[^>]+>', '', m.group(2)).strip(), m.group(1)))
    return out

for kw in ["豆粕", "豆油", "棕榈油"]:
    print("====", kw, "====")
    try:
        items = baidu_news(kw)
        print("  cnt:", len(items))
        for t, l in items[:4]:
            print("   -", t, "|", l[:80])
    except Exception as e:
        print("  err:", repr(e))
    time.sleep(2)
