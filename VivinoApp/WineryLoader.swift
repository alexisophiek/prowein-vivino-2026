import Foundation

/// Loads wineries from `wineries.csv` in the app bundle. Falls back to empty array if file is missing or invalid.
enum WineryLoader {
    private static let filename = "wineries"
    private static let `extension` = "csv"

    /// Load and parse CSV from the main bundle. Returns empty array on failure.
    static func loadFromBundle() -> [Winery] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: `extension`),
              let data = try? Data(contentsOf: url),
              let string = String(data: data, encoding: .utf8) else {
            return []
        }
        return parseCSV(string)
    }

    /// Parse CSV string into Winery array. First line is header; subsequent lines are data.
    static func parseCSV(_ string: String) -> [Winery] {
        let lines = string.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        guard lines.count >= 2 else { return [] }

        var result: [Winery] = []
        for (index, line) in lines.enumerated() {
            if index == 0 { continue } // skip header
            if line.isEmpty { continue }
            let fields = parseCSVLine(line)
            if let winery = winery(from: fields) {
                result.append(winery)
            }
        }
        return result
    }

    /// Parse a single CSV line, handling quoted fields (e.g. "South Australia").
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        for char in line {
            switch char {
            case "\"":
                inQuotes.toggle()
            case "," where !inQuotes:
                fields.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            default:
                current.append(char)
            }
        }
        fields.append(current.trimmingCharacters(in: .whitespaces))
        return fields
    }

    private static func winery(from fields: [String]) -> Winery? {
        guard fields.count >= 19 else { return nil }
        let name = fields[0]
        let region = fields[1]
        let country = fields[2]
        guard let globalRating = Double(fields[3]),
              let ratingsCount = Int(fields[4]),
              let winesListed = Int(fields[5]),
              let pageviews12m = Int(fields[6]),
              let pageviewRankPercent = Double(fields[7]),
              let pageviewRankTotal = Int(fields[8]),
              let scans12m = Int(fields[9]),
              let scanRankPercent = Double(fields[10]),
              let scanRankTotal = Int(fields[11]),
              let buyButtonCoverage = Double(fields[12]),
              let bottlesSold12m = Int(fields[13]),
              let newToBrandPageviews12m = Int(fields[14]),
              let newToBrandOrders12m = Int(fields[15]) else {
            return nil
        }
        let topEngagedCountryPageviews = fields[16]
        let topEngagedCountryBottlesSold: String? = fields[17].isEmpty ? nil : fields[17]
        let rawStatus = fields[18].trimmingCharacters(in: .whitespaces).lowercased()
        let wineryStatus: String
        switch rawStatus {
        case "claimed", "unclaimed", "sponsor": wineryStatus = rawStatus
        default: wineryStatus = "unclaimed"
        }
        let wineryIdRaw = fields.count >= 20 ? fields[19].trimmingCharacters(in: .whitespaces) : ""
        let wineryId: Int? = Int(wineryIdRaw) ?? Double(wineryIdRaw).map { Int($0) }

        return Winery(
            name: name,
            region: region,
            country: country,
            globalRating: globalRating,
            ratingsCount: ratingsCount,
            winesListed: winesListed,
            pageviews12m: pageviews12m,
            pageviewRankPercent: pageviewRankPercent,
            pageviewRankTotal: pageviewRankTotal,
            scans12m: scans12m,
            scanRankPercent: scanRankPercent,
            scanRankTotal: scanRankTotal,
            buyButtonCoverage: buyButtonCoverage,
            bottlesSold12m: bottlesSold12m,
            newToBrandPageviews12m: newToBrandPageviews12m,
            newToBrandOrders12m: newToBrandOrders12m,
            topEngagedCountryPageviews: topEngagedCountryPageviews,
            topEngagedCountryBottlesSold: topEngagedCountryBottlesSold,
            wineryStatus: wineryStatus,
            wineryId: wineryId
        )
    }
}


private extension Bool {
    init?(_ string: String) {
        let lower = string.lowercased()
        if lower == "true" || lower == "1" { self = true; return }
        if lower == "false" || lower == "0" { self = false; return }
        return nil
    }
}
