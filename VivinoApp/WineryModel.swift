import Foundation

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
}
