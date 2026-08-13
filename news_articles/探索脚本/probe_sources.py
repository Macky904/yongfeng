import urllib.request, urllib.parse, json, time, re

UA = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

def get(url, ref=None, timeout=20):
    h = dict(UA)
    if ref: h["Referer"] = ref
    req = urllib.request.Request(url, headers=h)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read(), r.headers.get_content_charset() or "utf-8"

KW = "豆粕"
results = {}

# 1) GDELT 中文短语（之前连通过，但相关性差）——测一下能否拿到中文源
try:
    q = urllib.parse.quote(f'"{KW}" (site:cn OR sourcecountry:China)')
    url = f"https://api.gdeltproject.org/api/v2/doc/doc?query={q}&mode=ArtList&maxrecords=5&format=json&sort=datedesc"
    raw, _ = get(url)
    d = json.loads(raw)
    arts = d.get("articles", [])
    cn = [a for a in arts if (a.get("sourcecountry")=="China" or ".cn" in (a.get("domain") or ""))]
    results["GDELT"] = (len(arts), len(cn), [a.get("title") for a in cn[:3]])
except Exception as e:
    results["GDELT"] = ("ERR", str(e))

time.sleep(3)

# 2) 百度新闻搜索 (公开)
try:
    url = "https://news.baidu.com/ns?word=" + urllib.parse.quote(KW) + "&rn=10&tn=news"
    raw, enc = get(url, ref="https://news.baidu.com/")
    html = raw.decode(enc, errors="ignore")
    titles = re.findall(r'<a[^>]+href="https?://[^"]+"[^>]*class="[^"]*news-title[^"]*"[^>]*>(.*?)</a>', html, re.S)
    titles = [re.sub(r'<[^>]+>', '', t).strip() for t in titles][:5]
    results["百度新闻"] = ("OK", len(titles), titles)
except Exception as e:
    results["百度新闻"] = ("ERR", str(e))

time.sleep(2)

# 3) 新华网/央视 RSS（公开 RSS）
rss_sources = {
    "新华财经RSS": "http://www.xinhuanet.com/fortune/news_finance.xml",
    "央视财经RSS": "https://rss.cctv.com/05/index.xml",
}
for name, u in rss_sources.items():
    try:
        raw, enc = get(u)
        xml = raw.decode(enc, errors="ignore")
        items = re.findall(r"<title>(.*?)</title>", xml, re.S)
        items = [re.sub(r"<[^>]+>", "", t).strip() for t in items[1:6]]
        results[name] = ("OK", len(items), items)
    except Exception as e:
        results[name] = ("ERR", str(e))
    time.sleep(1)

for k, v in results.items():
    print("###", k, "->", v[0] if isinstance(v, tuple) else v)
    if isinstance(v, tuple) and len(v) > 2:
        for t in v[2]:
            print("    -", t)
