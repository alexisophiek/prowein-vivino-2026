import SwiftUI

struct SessionLogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var records: [SessionRecord] = []
    @State private var searchText = ""

    private var filteredRecords: [SessionRecord] {
        guard !searchText.isEmpty else { return records }
        let q = searchText.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        return records.filter {
            $0.wineryName.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(q) ||
            $0.country.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(q) ||
            $0.contactName.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(q) ||
            $0.contactEmail.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(q)
        }
    }

    private var csvFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("prowein2026_session.csv")
    }

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "tray",
                        description: Text("Recorded sessions will appear here after you send reports.")
                    )
                } else {
                    List(filteredRecords) { record in
                        NavigationLink(destination: SessionDetailView(record: record)) {
                            HStack(spacing: 12) {
                                FlagView(country: record.country)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(record.wineryName)
                                        .font(.body.weight(.medium))
                                    Text(record.displayTimestamp)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(text: $searchText, prompt: "Search by winery, country, or contact")
            .navigationTitle("Session Log")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !records.isEmpty {
                        ShareLink(
                            item: csvFileURL,
                            preview: SharePreview("ProWein 2026 Session Log", image: Image(systemName: "tablecells"))
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .onAppear { records = SessionLogger.loadAll().reversed() }
        }
    }
}

// MARK: - Detail

struct SessionDetailView: View {
    let record: SessionRecord

    var body: some View {
        List {
            Section("Contact") {
                detailRow("Name", record.contactName)
                detailRow("Email", record.contactEmail)
                detailRow("Sent", record.displayTimestamp)
            }

            Section("Winery") {
                detailRow("Winery", record.wineryName)
                detailRow("Country", record.country)
                detailRow("Global Rating", record.globalRating)
                detailRow("Ratings (12m)", record.ratingsCount)
                detailRow("Wines Listed", record.winesListed)
            }

            Section("Engagement") {
                detailRow("Pageviews (12m)", record.pageviews12m)
                detailRow("Pageview Rank", "Top \(record.pageviewRankPercent)% of \(record.pageviewRankTotal)")
                detailRow("Scans (12m)", record.scans12m)
                detailRow("Scan Rank", "Top \(record.scanRankPercent)% of \(record.scanRankTotal)")
            }

            Section("Sales") {
                detailRow("Buy Button Coverage", formatPercent(record.buyButtonCoverage))
                detailRow("Bottles Sold (12m)", record.bottlesSold12m)
                detailRow("New-to-Brand Pageviews", record.newToBrandPageviews12m)
                detailRow("New-to-Brand Orders", record.newToBrandOrders12m)
            }

            Section("Top Engaged Country") {
                detailRow("By Pageviews", record.topEngagedCountryPageviews)
                detailRow("By Bottles Sold", record.topEngagedCountryBottlesSold.isEmpty ? "—" : record.topEngagedCountryBottlesSold)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(record.wineryName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }

    private func formatPercent(_ raw: String) -> String {
        guard let val = Double(raw) else { return raw }
        return "\(Int(val * 100))%"
    }
}
