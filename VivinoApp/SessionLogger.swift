import Foundation

struct SessionLogger {
    static func log(
        winery: Winery,
        contactName: String,
        contactEmail: String,
        isRecording: Bool
    ) {
        guard isRecording else { return }

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
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                handle.write(row.data(using: .utf8)!)
                handle.closeFile()
            }
        }
    }
}
