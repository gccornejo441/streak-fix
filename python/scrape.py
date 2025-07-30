from bs4 import BeautifulSoup
import json

with open("shops.html", "r", encoding="utf-8") as f:
    soup = BeautifulSoup(f, "lxml")

items = soup.find_all("li", class_="collection-item")
parsed = []
for li in items:
    script = li.find("script", type="application/ld+json")
    data = json.loads(script.string) if script else {}

    name = data.get("name")
    url  = data.get("url")

    addr = data.get("address", {})
    street = addr.get("streetAddress", "")
    city   = addr.get("addressLocality", "")
    region = addr.get("addressRegion", "")
    address = ", ".join(filter(None, (street, city, region)))

    desc_div = li.find("div", class_="description")
    description = desc_div.get_text(strip=True) if desc_div else ""

    parsed.append({
        "Shop Name":   name,
        "Description": description,
        "Address":     address,
        "URL":         url
    })

# write to JSON file
output_path = "shops.json"
with open(output_path, "w", encoding="utf-8") as out:
    json.dump(parsed, out, indent=2, ensure_ascii=False)

print(f"Wrote {len(parsed)} shops to {output_path}")
