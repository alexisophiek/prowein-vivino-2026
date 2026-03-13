import Foundation

/// Codable representation for loading from JSON. Decode into this, then map to Winery.
struct WineryRecord: Codable {
    let name: String
    let region: String
    let country: String
    let globalRating: Double
    let ratingsCount: Int
    let winesListed: Int
    let pageviews12m: Int
    let pageviewRankPercent: Double
    let pageviewRankTotal: Int
    let scans12m: Int
    let scanRankPercent: Double
    let scanRankTotal: Int
    let buyButtonCoverage: Double
    let bottlesSold12m: Int
    let newToBrandPageviews12m: Int
    let newToBrandOrders12m: Int
    let topEngagedCountryPageviews: String
    let topEngagedCountryBottlesSold: String?
    let wineryStatus: String
    let wineryId: Double?  // CSV/JSON often use float; we convert to Int?
}

struct Winery: Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let country: String
    let globalRating: Double
    let ratingsCount: Int
    let winesListed: Int
    let pageviews12m: Int
    let pageviewRankPercent: Double     // e.g. 1.0 = top 1%
    let pageviewRankTotal: Int          // total wineries in same country
    let scans12m: Int
    let scanRankPercent: Double
    let scanRankTotal: Int
    let buyButtonCoverage: Double       // 0.0 to 1.0
    let bottlesSold12m: Int
    let newToBrandPageviews12m: Int
    let newToBrandOrders12m: Int
    let topEngagedCountryPageviews: String    // top pageview country outside origin
    let topEngagedCountryBottlesSold: String?  // top bottles-sold country outside origin. nil if no sales
    /// Winery status: "claimed", "unclaimed", or "sponsor". In UI, "sponsor" is displayed as "Partner".
    let wineryStatus: String
    /// Vivino numeric winery ID. Used for profile preview link. nil when not available in data.
    let wineryId: Int?

    /// Display label for status: "Partner" when sponsor, otherwise capitalized (e.g. "Claimed", "Unclaimed").
    var wineryStatusDisplayName: String {
        switch wineryStatus.lowercased() {
        case "sponsor": return "Partner"
        case "claimed": return "Claimed"
        case "unclaimed": return "Unclaimed"
        default: return wineryStatus.isEmpty ? "Unclaimed" : wineryStatus.prefix(1).uppercased() + wineryStatus.dropFirst().lowercased()
        }
    }

    /// Memberwise initializer (used by CSV parsing and SampleData; preserved because we also have init(from: WineryRecord)).
    init(
        name: String,
        region: String,
        country: String,
        globalRating: Double,
        ratingsCount: Int,
        winesListed: Int,
        pageviews12m: Int,
        pageviewRankPercent: Double,
        pageviewRankTotal: Int,
        scans12m: Int,
        scanRankPercent: Double,
        scanRankTotal: Int,
        buyButtonCoverage: Double,
        bottlesSold12m: Int,
        newToBrandPageviews12m: Int,
        newToBrandOrders12m: Int,
        topEngagedCountryPageviews: String,
        topEngagedCountryBottlesSold: String?,
        wineryStatus: String,
        wineryId: Int?
    ) {
        self.name = name
        self.region = region
        self.country = country
        self.globalRating = globalRating
        self.ratingsCount = ratingsCount
        self.winesListed = winesListed
        self.pageviews12m = pageviews12m
        self.pageviewRankPercent = pageviewRankPercent
        self.pageviewRankTotal = pageviewRankTotal
        self.scans12m = scans12m
        self.scanRankPercent = scanRankPercent
        self.scanRankTotal = scanRankTotal
        self.buyButtonCoverage = buyButtonCoverage
        self.bottlesSold12m = bottlesSold12m
        self.newToBrandPageviews12m = newToBrandPageviews12m
        self.newToBrandOrders12m = newToBrandOrders12m
        self.topEngagedCountryPageviews = topEngagedCountryPageviews
        self.topEngagedCountryBottlesSold = topEngagedCountryBottlesSold
        self.wineryStatus = wineryStatus
        self.wineryId = wineryId
    }

    init(from record: WineryRecord) {
        let rawStatus = record.wineryStatus.trimmingCharacters(in: .whitespaces).lowercased()
        let wineryStatus: String
        switch rawStatus {
        case "claimed", "unclaimed", "sponsor": wineryStatus = rawStatus
        default: wineryStatus = "unclaimed"
        }
        self.init(
            name: record.name,
            region: record.region,
            country: record.country,
            globalRating: record.globalRating,
            ratingsCount: record.ratingsCount,
            winesListed: record.winesListed,
            pageviews12m: record.pageviews12m,
            pageviewRankPercent: record.pageviewRankPercent,
            pageviewRankTotal: record.pageviewRankTotal,
            scans12m: record.scans12m,
            scanRankPercent: record.scanRankPercent,
            scanRankTotal: record.scanRankTotal,
            buyButtonCoverage: record.buyButtonCoverage,
            bottlesSold12m: record.bottlesSold12m,
            newToBrandPageviews12m: record.newToBrandPageviews12m,
            newToBrandOrders12m: record.newToBrandOrders12m,
            topEngagedCountryPageviews: record.topEngagedCountryPageviews,
            topEngagedCountryBottlesSold: record.topEngagedCountryBottlesSold,
            wineryStatus: wineryStatus,
            wineryId: record.wineryId.map { Int($0) }
        )
    }
}
