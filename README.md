# Prowein x Vivino 2026

iOS app (SwiftUI) for **Prowein 2026** with Vivino: winery search, reports, country flags.

## Open & run

1. Open **`VivinoApp.xcodeproj`** in Xcode.
2. Select an iPhone simulator (e.g. iPhone 16) and press **Run** (▶).

## Project layout

- `VivinoApp.xcodeproj` — Xcode project
- `VivinoApp/` — Source and assets
  - `ContentView.swift` — main SwiftUI view (winery search, cards, flags)
  - `WineryModel.swift`, `SampleData.swift`, `WineryLoader.swift`
  - `CountryFlag.swift` — flag asset model (ISO code → `flag_xx_24` image)
  - `Assets.xcassets` — app icon, flags (`flag_*_24`), vivino-star
  - `wineries.csv` — sample data

## Country flags

Flags use asset names `flag_{iso}_24` (e.g. `flag_us_24`). The app resolves country names (e.g. from API) to ISO and shows the image or an emoji fallback.
