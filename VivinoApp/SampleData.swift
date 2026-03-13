import Foundation

let sampleWineries: [Winery] = [
    Winery(
        name: "Château Margaux", region: "Bordeaux", country: "France",
        globalRating: 4.2, ratingsCount: 1204, winesListed: 38,
        pageviews12m: 120100, pageviewRankPercent: 1.0, pageviewRankTotal: 39139,
        scans12m: 13800, scanRankPercent: 2.0, scanRankTotal: 33196,
        buyButtonCoverage: 0.0, bottlesSold12m: 0,
        newToBrandPageviews12m: 8200, newToBrandOrders12m: 0,
        topEngagedCountryPageviews: "United States", topEngagedCountryBottlesSold: nil,
        wineryStatus: "sponsor",
        wineryId: 1139
    ),
    Winery(
        name: "Domaine Leflaive", region: "Burgundy", country: "France",
        globalRating: 4.5, ratingsCount: 876, winesListed: 22,
        pageviews12m: 88000, pageviewRankPercent: 2.0, pageviewRankTotal: 39139,
        scans12m: 9400, scanRankPercent: 3.0, scanRankTotal: 33196,
        buyButtonCoverage: 0.62, bottlesSold12m: 4200,
        newToBrandPageviews12m: 31400, newToBrandOrders12m: 1180,
        topEngagedCountryPageviews: "United Kingdom", topEngagedCountryBottlesSold: "Germany",
        wineryStatus: "claimed",
        wineryId: 15612
    ),
    Winery(
        name: "Ridge Vineyards", region: "Sonoma", country: "USA",
        globalRating: 4.1, ratingsCount: 932, winesListed: 44,
        pageviews12m: 54000, pageviewRankPercent: 4.0, pageviewRankTotal: 12800,
        scans12m: 7100, scanRankPercent: 5.0, scanRankTotal: 11400,
        buyButtonCoverage: 0.87, bottlesSold12m: 17300,
        newToBrandPageviews12m: 19600, newToBrandOrders12m: 3240,
        topEngagedCountryPageviews: "Canada", topEngagedCountryBottlesSold: "Sweden",
        wineryStatus: "unclaimed",
        wineryId: 4573
    ),
    Winery(
        name: "Antinori", region: "Tuscany", country: "Italy",
        globalRating: 4.3, ratingsCount: 2140, winesListed: 67,
        pageviews12m: 210000, pageviewRankPercent: 0.5, pageviewRankTotal: 28400,
        scans12m: 31000, scanRankPercent: 1.0, scanRankTotal: 24900,
        buyButtonCoverage: 0.74, bottlesSold12m: 28900,
        newToBrandPageviews12m: 88200, newToBrandOrders12m: 7410,
        topEngagedCountryPageviews: "United States", topEngagedCountryBottlesSold: "Netherlands",
        wineryStatus: "sponsor",
        wineryId: 11981
    ),
    Winery(
        name: "Penfolds", region: "South Australia", country: "Australia",
        globalRating: 4.4, ratingsCount: 3810, winesListed: 52,
        pageviews12m: 178000, pageviewRankPercent: 1.2, pageviewRankTotal: 9200,
        scans12m: 24500, scanRankPercent: 1.5, scanRankTotal: 8100,
        buyButtonCoverage: 0.91, bottlesSold12m: 41200,
        newToBrandPageviews12m: 54100, newToBrandOrders12m: 9830,
        topEngagedCountryPageviews: "United Kingdom", topEngagedCountryBottlesSold: "Germany",
        wineryStatus: "sponsor",
        wineryId: 8230
    )
]
