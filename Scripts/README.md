# Scripts

## csv_to_json.py

Converts `wineries.csv` to `wineries.json` so the app can load data with `JSONDecoder` (faster and more idiomatic in Swift).

**Run from repo root or Scripts folder:**

```bash
# Full conversion (output: VivinoApp/wineries.json)
python3 Scripts/csv_to_json.py

# Or with paths
python3 Scripts/csv_to_json.py VivinoApp/wineries.csv VivinoApp/wineries.json

# Smaller file for testing (first 1000 rows)
python3 Scripts/csv_to_json.py --limit 1000
```

After generating `wineries.json`, add it to the Xcode project (VivinoApp target) and ensure it’s in **Copy Bundle Resources** so it’s included in the app. The app loads JSON first, then falls back to CSV if JSON is missing.
