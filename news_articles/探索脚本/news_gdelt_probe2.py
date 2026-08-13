import urllib.request, json, urllib.parse, time

q = "(豆粕 OR 豆油 OR 棕榈油 OR 菜籽 OR 菜粕 OR 菜油 OR 农产品 OR 期货)"
url = ("https://api.gdeltproject.org/api/v2/doc/doc?query="
       + urllib.parse.quote(q)
       + "&mode=ArtList&maxrecords=5&format=json&sort=datedesc")

ok = False
for attempt in range(1, 6):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (research)"})
        with urllib.request.urlopen(req, timeout=30) as r:
            data = json.loads(r.read().decode("utf-8"))
        arts = data.get("articles", [])
        print(f"[attempt {attempt}] OK, articles:", len(arts))
        for a in arts[:3]:
            print("---")
            print("title:", a.get("title"))
            print("url  :", a.get("url"))
            print("domain:", a.get("domain"), "| seendate:", a.get("seendate"))
        ok = True
        break
    except urllib.error.HTTPError as e:
        print(f"[attempt {attempt}] HTTP {e.code}, retry after 20s")
        time.sleep(20)
    except Exception as e:
        print(f"[attempt {attempt}] ERR {repr(e)}, retry after 20s")
        time.sleep(20)

if not ok:
    print("GDELT 仍限流，稍后再试")
