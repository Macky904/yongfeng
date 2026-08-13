import urllib.request, json

# GDELT DOC 2.0 API (免费, 无需 key)
# query: 关键词 OR 组合; mode=ArtList 返回文章列表
q = "(豆粕 OR 豆油 OR 棕榈油 OR 菜籽 OR 菜粕 OR 菜油 OR 农产品 OR 期货)"
url = ("https://api.gdeltproject.org/api/v2/doc/doc?query="
       + urllib.parse.quote(q)
       + "&mode=ArtList&maxrecords=5&format=json&sort=datedesc")
import urllib.parse
url = ("https://api.gdeltproject.org/api/v2/doc/doc?query="
       + urllib.parse.quote(q)
       + "&mode=ArtList&maxrecords=5&format=json&sort=datedesc")

print("URL:", url)
try:
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode("utf-8"))
    arts = data.get("articles", [])
    print("articles returned:", len(arts))
    for a in arts[:3]:
        print("---")
        print("title :", a.get("title"))
        print("url   :", a.get("url"))
        print("domain:", a.get("domain"))
        print("seendate:", a.get("seendate"))
        print("sourcecountry:", a.get("sourcecountry"))
except Exception as e:
    print("ERROR:", repr(e))
