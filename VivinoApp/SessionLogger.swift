import Foundation

/// Logs contact captures to a local CSV in the app's Documents directory. No network; works fully offline.
struct SessionRecord: Identifiable {
    let id = UUID()
    let timestamp: String
    let wineryName: String
    let country: String
    let contactName: String
    let contactEmail: String
    let globalRating: String
    let ratingsCount: String
    let winesListed: String
    let pageviews12m: String
    let pageviewRankPercent: String
    let pageviewRankTotal: String
    let scans12m: String
    let scanRankPercent: String
    let scanRankTotal: String
    let buyButtonCoverage: String
    let bottlesSold12m: String
    let newToBrandPageviews12m: String
    let newToBrandOrders12m: String
    let topEngagedCountryPageviews: String
    let topEngagedCountryBottlesSold: String

    var displayTimestamp: String {
        let fmt = ISO8601DateFormatter()
        guard let date = fmt.date(from: timestamp) else { return timestamp }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }
}

struct SessionLogger {
    /// Log a sent report. Always logs when a report is sent, even if session is paused.
    static func log(
        winery: Winery,
        contactName: String,
        contactEmail: String,
        isRecording: Bool
    ) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent("prowein2026_session.csv")

        let header = "timestamp,wineryName,country,contactName,contactEmail," +
            "globalRating,ratingsCount,winesListed," +
            "pageviews12m,pageviewRankPercent,pageviewRankTotal," +
            "scans12m,scanRankPercent,scanRankTotal," +
            "buyButtonCoverage,bottlesSold12m," +
            "newToBrandPageviews12m,newToBrandOrders12m," +
            "topEngagedCountryPageviews,topEngagedCountryBottlesSold\n"

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let row = [
            timestamp, winery.name, winery.country,
            contactName, contactEmail,
            String(winery.globalRating), String(winery.ratingsCount),
            String(winery.winesListed),
            String(winery.pageviews12m), String(winery.pageviewRankPercent),
            String(winery.pageviewRankTotal), String(winery.scans12m),
            String(winery.scanRankPercent), String(winery.scanRankTotal),
            String(winery.buyButtonCoverage), String(winery.bottlesSold12m),
            String(winery.newToBrandPageviews12m), String(winery.newToBrandOrders12m),
            winery.topEngagedCountryPageviews,
            winery.topEngagedCountryBottlesSold ?? ""
        ].joined(separator: ",") + "\n"

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            try? (header + row).write(to: fileURL, atomically: true, encoding: .utf8)
        } else {
            guard let rowData = row.data(using: .utf8),
                  let handle = try? FileHandle(forWritingTo: fileURL) else { return }
            defer { try? handle.close() }
            handle.seekToEndOfFile()
            handle.write(rowData)
        }
    }

    static func loadAll() -> [SessionRecord] {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent("prowein2026_session.csv")
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return [] }

        let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] }

        return lines.dropFirst().compactMap { line in
            let cols = line.components(separatedBy: ",")
            guard cols.count >= 20 else { return nil }
            return SessionRecord(
                timestamp: cols[0],
                wineryName: cols[1],
                country: cols[2],
                contactName: cols[3],
                contactEmail: cols[4],
                globalRating: cols[5],
                ratingsCount: cols[6],
                winesListed: cols[7],
                pageviews12m: cols[8],
                pageviewRankPercent: cols[9],
                pageviewRankTotal: cols[10],
                scans12m: cols[11],
                scanRankPercent: cols[12],
                scanRankTotal: cols[13],
                buyButtonCoverage: cols[14],
                bottlesSold12m: cols[15],
                newToBrandPageviews12m: cols[16],
                newToBrandOrders12m: cols[17],
                topEngagedCountryPageviews: cols[18],
                topEngagedCountryBottlesSold: cols[19]
            )
        }
    }
}
