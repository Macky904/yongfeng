import urllib.request, urllib.parse, json, time

# 新浪财经实时新闻(滚动) 公开接口，搜索关键词
def fetch_sina_news(keyword, max_try=3):
    # 新浪搜索新闻接口（公开）
    url = ("https://search.sina.com.cn/news?q=" + urllib.parse.quote(keyword)
           + "&range=all&title=1&sort=time&page=1")
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
    for _ in range(max_try):
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=20) as r:
                html = r.read().decode("gbk", errors="ignore")
            return html
        except Exception as e:
            print("  sina err:", repr(e)); time.sleep(3)
    return ""

kw = "豆粕"
html = fetch_sina_news(kw)
print("len(html):", len(html))
# 粗略抽取标题（新浪结果页 <a ...>标题</a> 在 class="fgray" 之类）
import re
titles = re.findall(r'<a[^>]+href="https?://[^"]+"[^>]*>(.*?)</a>', html, re.S)
titles = [re.sub(r'<[^>]+>', '', t).strip() for t in titles]
titles = [t for t in titles if len(t) > 4][:10]
print("sample titles for '豆粕':")
for t in titles:
    print(" -", t)
