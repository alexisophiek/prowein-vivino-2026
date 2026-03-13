import Foundation

/// A single session log entry. Stored in JSON with a stable id so we can update when email is sent.
struct SessionRecord: Identifiable, Codable {
    let id: String
    let timestamp: String
    let wineryName: String
    let country: String
    var contactName: String
    var contactEmail: String
    var emailSentAt: String?
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

    var displaySentAt: String {
        if let sent = emailSentAt, !sent.isEmpty, let date = ISO8601DateFormatter().date(from: sent) {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            return f.string(from: date)
        }
        return "—"
    }
}

private let sessionFile = "prowein2026_sessions.json"
private let exportCSVFile = "prowein2026_session.csv"

struct SessionLogger {
    private static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(sessionFile)
    }

    private static var exportCSVURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(exportCSVFile)
    }

    /// Log a session (presave before send or when paused and email sent). Returns session id for later update.
    static func log(
        winery: Winery,
        contactName: String,
        contactEmail: String,
        isRecording: Bool,
        emailSentAt: Date? = nil
    ) -> String {
        let id = UUID().uuidString
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let record = SessionRecord(
            id: id,
            timestamp: timestamp,
            wineryName: winery.name,
            country: winery.country,
            contactName: contactName,
            contactEmail: contactEmail,
            emailSentAt: emailSentAt.map { ISO8601DateFormatter().string(from: $0) },
            globalRating: String(winery.globalRating),
            ratingsCount: String(winery.ratingsCount),
            winesListed: String(winery.winesListed),
            pageviews12m: String(winery.pageviews12m),
            pageviewRankPercent: String(winery.pageviewRankPercent),
            pageviewRankTotal: String(winery.pageviewRankTotal),
            scans12m: String(winery.scans12m),
            scanRankPercent: String(winery.scanRankPercent),
            scanRankTotal: String(winery.scanRankTotal),
            buyButtonCoverage: String(winery.buyButtonCoverage),
            bottlesSold12m: String(winery.bottlesSold12m),
            newToBrandPageviews12m: String(winery.newToBrandPageviews12m),
            newToBrandOrders12m: String(winery.newToBrandOrders12m),
            topEngagedCountryPageviews: winery.topEngagedCountryPageviews,
            topEngagedCountryBottlesSold: winery.topEngagedCountryBottlesSold ?? ""
        )
        var list = loadAllRecords()
        list.append(record)
        saveRecords(list)
        return id
    }

    /// Update an existing session with contact details (e.g. when user taps Send in live mode).
    static func updateSession(id sessionId: String, contactName: String, contactEmail: String) {
        var list = loadAllRecords()
        guard let idx = list.firstIndex(where: { $0.id == sessionId }) else { return }
        list[idx].contactName = contactName
        list[idx].contactEmail = contactEmail
        saveRecords(list)
    }

    /// Update an existing session when the email was actually sent.
    static func updateSession(id sessionId: String, emailSentAt: Date) {
        let sent = ISO8601DateFormatter().string(from: emailSentAt)
        var list = loadAllRecords()
        guard let idx = list.firstIndex(where: { $0.id == sessionId }) else { return }
        list[idx].emailSentAt = sent
        saveRecords(list)
    }

    static func loadAll() -> [SessionRecord] {
        loadAllRecords().reversed()
    }

    /// Export current records to CSV for Share (Session Log share button).
    static func exportToCSV(records: [SessionRecord]) -> URL {
        let header = "id,timestamp,wineryName,country,contactName,contactEmail,emailSentAt," +
            "globalRating,ratingsCount,winesListed,pageviews12m,pageviewRankPercent,pageviewRankTotal," +
            "scans12m,scanRankPercent,scanRankTotal,buyButtonCoverage,bottlesSold12m," +
            "newToBrandPageviews12m,newToBrandOrders12m,topEngagedCountryPageviews,topEngagedCountryBottlesSold\n"
        let rows = records.reversed().map { r in
            [r.id, r.timestamp, r.wineryName, r.country, r.contactName, r.contactEmail, r.emailSentAt ?? "",
             r.globalRating, r.ratingsCount, r.winesListed, r.pageviews12m, r.pageviewRankPercent, r.pageviewRankTotal,
             r.scans12m, r.scanRankPercent, r.scanRankTotal, r.buyButtonCoverage, r.bottlesSold12m,
             r.newToBrandPageviews12m, r.newToBrandOrders12m, r.topEngagedCountryPageviews, r.topEngagedCountryBottlesSold]
                .map { escapeCSV($0) }
                .joined(separator: ",")
        }
        let content = header + rows.joined(separator: "\n")
        try? content.write(to: exportCSVURL, atomically: true, encoding: .utf8)
        return exportCSVURL
    }

    private static func escapeCSV(_ s: String) -> String {
        if s.contains(",") || s.contains("\"") || s.contains("\n") {
            return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return s
    }

    private static func loadAllRecords() -> [SessionRecord] {
        guard let data = try? Data(contentsOf: fileURL),
              let list = try? JSONDecoder().decode([SessionRecord].self, from: data) else {
            return []
        }
        return list
    }

    private static func saveRecords(_ list: [SessionRecord]) {
        guard let data = try? JSONEncoder().encode(list) else { return }
        try? data.write(to: fileURL)
    }
}
