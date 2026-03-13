#!/usr/bin/env python3
"""
Convert wineries.csv to wineries.json for faster loading in Swift (JSONDecoder + Codable).

Usage:
  python3 csv_to_json.py [path/to/wineries.csv] [path/to/wineries.json]
  Default: reads VivinoApp/wineries.csv, writes VivinoApp/wineries.json

Optional: --limit N  output only first N rows (for a smaller test file).
"""
import csv
import json
import sys
import os

def parse_float(s):
    s = (s or "").strip()
    if not s: return None
    try: return float(s)
    except ValueError: return None

def parse_int(s):
    s = (s or "").strip()
    if not s: return None
    try: return int(float(s))
    except ValueError: return None

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    default_csv = os.path.join(script_dir, "..", "VivinoApp", "wineries.csv")
    default_json = os.path.join(script_dir, "..", "VivinoApp", "wineries.json")

    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    limit = None
    if "--limit" in sys.argv:
        i = sys.argv.index("--limit")
        if i + 1 < len(sys.argv):
            limit = int(sys.argv[i + 1])

    csv_path = args[0] if args else default_csv
    json_path = args[1] if len(args) >= 2 else default_json

    if not os.path.isfile(csv_path):
        print(f"Error: CSV not found: {csv_path}", file=sys.stderr)
        sys.exit(1)

    rows = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader):
            if limit is not None and i >= limit:
                break
            r = {
                "name": (row.get("name") or "").strip(),
                "region": (row.get("region") or "").strip(),
                "country": (row.get("country") or "").strip(),
                "globalRating": parse_float(row.get("globalRating")) or 0.0,
                "ratingsCount": parse_int(row.get("ratingsCount")) or 0,
                "winesListed": parse_int(row.get("winesListed")) or 0,
                "pageviews12m": parse_int(row.get("pageviews12m")) or 0,
                "pageviewRankPercent": parse_float(row.get("pageviewRankPercent")) or 0.0,
                "pageviewRankTotal": parse_int(row.get("pageviewRankTotal")) or 0,
                "scans12m": parse_int(row.get("scans12m")) or 0,
                "scanRankPercent": parse_float(row.get("scanRankPercent")) or 0.0,
                "scanRankTotal": parse_int(row.get("scanRankTotal")) or 0,
                "buyButtonCoverage": parse_float(row.get("buyButtonCoverage")) or 0.0,
                "bottlesSold12m": parse_int(row.get("bottlesSold12m")) or 0,
                "newToBrandPageviews12m": parse_int(row.get("newToBrandPageviews12m")) or 0,
                "newToBrandOrders12m": parse_int(row.get("newToBrandOrders12m")) or 0,
                "topEngagedCountryPageviews": (row.get("topEngagedCountryPageviews") or "").strip(),
                "topEngagedCountryBottlesSold": (row.get("topEngagedCountryBottlesSold") or "").strip() or None,
                "wineryStatus": (row.get("wineryStatus") or "unclaimed").strip().lower(),
                "wineryId": parse_float(row.get("wineryId")),
            }
            if r["wineryStatus"] not in ("claimed", "unclaimed", "sponsor"):
                r["wineryStatus"] = "unclaimed"
            rows.append(r)

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(rows, f, ensure_ascii=False, separators=(",", ":"))

    print(f"Wrote {len(rows)} wineries to {json_path}")

if __name__ == "__main__":
    main()
