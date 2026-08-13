import urllib.request, urllib.parse, json, time

def fetch(url, ref=None):
    headers = {"User-Agent": "Mozilla/5.0", "Referer": ref or "https://futures.eastmoney.com/"}
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=20) as r:
        return r.read().decode("utf-8")

cate = urllib.parse.quote("豆粕")
url = (f"https://newsapi.eastmoney.com/kuaixun/v1/getlist?type=1&sort=1"
       f"&pageindex=1&pagesize=10&cate={cate}")
print("URL:", url)
try:
    txt = fetch(url)
    print("raw head:", txt[:400])
    # 尝试解析
    try:
        data = json.loads(txt)
        print("keys:", list(data.keys())[:10])
    except Exception as e:
        print("json parse err:", e)
except Exception as e:
    print("err:", repr(e))
