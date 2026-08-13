import urllib.request, urllib.parse, json, time

UA = {"User-Agent": "Mozilla/5.0 (research)"}

def gdelt(query, maxrecords=10):
    url = ("https://api.gdeltproject.org/api/v2/doc/doc?query="
           + urllib.parse.quote(query)
           + f"&mode=ArtList&maxrecords={maxrecords}&format=json&sort=datedesc")
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))

# 方案A: 中文关键词 + 中国来源
queries = {
    "豆粕+China源": '(豆粕 OR 豆油 OR 棕榈油 OR 菜粕 OR 菜油) sourcecountry:China',
    "农产品期货+China源": '(农产品 期货 OR 豆粕 OR 菜籽) sourcecountry:China',
}
for name, q in queries.items():
    print("====", name, "====")
    try:
        d = gdelt(q, 8)
        arts = d.get("articles", [])
        print("  cnt:", len(arts))
        cn = [a for a in arts if a.get("sourcecountry") == "China" or ".cn" in (a.get("domain") or "")]
        print("  China相关:", len(cn))
        for a in cn[:4]:
            print("   -", a.get("title"), "|", a.get("domain"), "|", a.get("sourcecountry"))
    except Exception as e:
        print("  err:", repr(e))
    time.sleep(5)
