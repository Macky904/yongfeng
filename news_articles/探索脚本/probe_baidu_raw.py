import urllib.request, urllib.parse, re

UA = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
kw = "豆粕"
url = "https://news.baidu.com/ns?word=" + urllib.parse.quote(kw) + "&rn=10&tn=news&ct=1"
req = urllib.request.Request(url, headers={**UA, "Referer": "https://news.baidu.com/"})
with urllib.request.urlopen(req, timeout=20) as r:
    html = r.read().decode(r.headers.get_content_charset() or "utf-8", errors="ignore")

print("HTML length:", len(html))
# 保存以便查看
open("baidu_sample.html", "w", encoding="utf-8").write(html)
# 找包含关键词的上下文片段
idx = html.find(kw)
print("first kw index:", idx)
if idx > 0:
    print(html[idx-200:idx+300])
# 列出所有 <a href= 中 http 的片段数量
print("http links count:", len(re.findall(r'href="https?://', html)))
# 找 h3 标签
print("h3 count:", len(re.findall(r'<h3', html)))
# 找 class 含 title 的
print("class*title count:", len(re.findall(r'class="[^"]*title', html)))
