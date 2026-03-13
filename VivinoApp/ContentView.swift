import SwiftUI
import MessageUI
import UIKit

// MARK: - Vivino brand (accent only; system colors elsewhere for Apple feel)
let vivinoRed = Color(red: 0.675, green: 0.118, blue: 0.176)
let vivinoRedLight = vivinoRed.opacity(0.08)

// MARK: - Layout (Apple HIG–aligned spacing)
private let spacingXS: CGFloat = 8
private let spacingS: CGFloat = 12
private let spacingM: CGFloat = 16
private let spacingL: CGFloat = 20
private let spacingXL: CGFloat = 24
private let cornerRadiusCard: CGFloat = 12
private let cornerRadiusControl: CGFloat = 10

func compactFormat(_ n: Int) -> String {
    if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
    if n >= 1_000     { return String(format: "%.1fK", Double(n) / 1_000) }
    return "\(n)"
}

// Emoji fallback when flag image is missing (GeneratedCountryFlags.swift).
func flag(_ country: String) -> String { countryFlags[country] ?? "🌍" }

// MARK: - Rating star (Vivino star image or emoji fallback)
struct RatingStarView: View {
    private let imageName = "vivino-star"
    var body: some View {
        if UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        } else {
            Text("⭐").font(.title3)
        }
    }
}

// MARK: - Country flag (image from Assets when available, else emoji)
struct FlagView: View {
    let country: String
    private var flagAsset: CountryFlag? {
        if let iso = isoCode(forCountryName: country) {
            return CountryFlag(isoCode: iso)
        }
        return nil
    }
    var body: some View {
        if let asset = flagAsset, UIImage(named: asset.rawValue) != nil {
            Image(asset.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        } else {
            Text(flag(country)).font(.subheadline)
        }
    }
}

struct ContentView: View {
    @AppStorage("isRecording") var isRecording: Bool = true
    @State private var query = ""
    @State private var debouncedQuery = ""
    @State private var contactName = ""
    @State private var contactEmail = ""
    @State private var showSessionLog = false
    @State private var errorMessage = ""
    @State private var showShareSheet = false
    @State private var sharePDFData: Data? = nil
    @State private var shareFileName: String = "report.pdf"
    @State private var shareEmailSuggestion: String? = nil
    @State private var wineries: [Winery] = []
    @State private var winery: Winery? = nil
    @State private var isContactCardExpanded = false
    @State private var mailRecipient = ""
    @State private var mailSubject = ""
    @State private var mailBody = ""
    @State private var mailAttachment: Data? = nil
    @State private var mailAttachmentName = "report.pdf"
    @State private var showMail = false
    /// When session is paused, hold winery/contact until Mail or share sheet confirms send, then log.
    @State private var pendingLog: (winery: Winery, name: String, email: String)? = nil
    /// Cached so typing in contact form doesn't re-run the 250k filter on every keystroke (fixes contact-form keyboard lag).
    @State private var cachedSuggestions: [Winery] = []

    private func updateSuggestions() {
        guard debouncedQuery.count >= 2 else {
            cachedSuggestions = []
            return
        }
        let q = debouncedQuery.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        cachedSuggestions = Array(wineries.lazy.filter {
            $0.name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(q)
        }.prefix(8))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: spacingXL) {
                        headerView
                        if let w = winery {
                            WineryCardView(winery: w)
                        } else if !query.isEmpty {
                            Text("No winery found. Try another name.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.top, spacingXL * 2)
                        }
                    }
                    .padding(spacingXL)
                }
                .background(Color(.systemGroupedBackground))

                if winery != nil {
                    contactCardSection
                }
            }
            .searchable(text: $query, prompt: "Search winery name") {
                ForEach(cachedSuggestions) { w in
                    Button {
                        query = w.name
                        debouncedQuery = w.name
                        winery = w
                        updateSuggestions()
                        if isRecording {
                            SessionLogger.log(winery: w, contactName: "—", contactEmail: "—", isRecording: true)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(w.name).font(.body)
                            Text("\(w.region) · \(w.country)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .onChange(of: query) { _, newValue in
                if newValue.count < 2 {
                    debouncedQuery = newValue
                    updateSuggestions()
                } else {
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        if query == newValue {
                            debouncedQuery = newValue
                            updateSuggestions()
                        }
                    }
                }
            }
            .onChange(of: debouncedQuery) { _, _ in updateSuggestions() }
            .onSubmit(of: .search) {
                debouncedQuery = query
                updateSuggestions()
                let q = query.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                if let w = wineries.first(where: {
                    $0.name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(q)
                }) {
                    winery = w
                    if isRecording {
                        SessionLogger.log(winery: w, contactName: "—", contactEmail: "—", isRecording: true)
                    }
                } else {
                    winery = nil
                }
            }
            .autocorrectionDisabled()
            .navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(alignment: .bottomTrailing) {
            Button { showSessionLog = true } label: {
                Image(systemName: "list.clipboard")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(vivinoRed)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
            }
            .padding(.trailing, spacingXL)
            .padding(.bottom, spacingXL)
        }
        .fullScreenCover(isPresented: $showSessionLog) {
            SessionLogView()
        }
        .sheet(isPresented: $showMail) {
            MailView(recipient: mailRecipient, subject: mailSubject,
                     body: mailBody, isHTML: false,
                     attachmentData: mailAttachment,
                     attachmentFileName: mailAttachmentName,
                     isPresented: $showMail,
                     winery: pendingLog?.winery,
                     contactName: pendingLog?.name,
                     contactEmail: pendingLog?.email,
                     onSent: { pendingLog = nil })
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = sharePDFData {
                ShareSheet(pdfData: data, fileName: shareFileName,
                           emailSuggestion: shareEmailSuggestion,
                           isPresented: $showShareSheet,
                           onDismiss: {
                               if let p = pendingLog {
                                   SessionLogger.log(winery: p.winery, contactName: p.name, contactEmail: p.email, isRecording: false)
                                   pendingLog = nil
                               }
                           })
            }
        }
        .onAppear {
            wineries = WineryLoader.loadFromBundle()
            if wineries.isEmpty {
                wineries = sampleWineries
            }
            updateSuggestions()
        }
    }

    var headerView: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: spacingXS) {
                Image("vivino-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                Text("ProWein 2026")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, spacingXS)

            Button(action: { isRecording.toggle() }) {
                Label(isRecording ? "Live" : "Paused", systemImage: isRecording ? "record.circle.fill" : "record.circle")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isRecording ? vivinoRed : .secondary)
                    .symbolRenderingMode(isRecording ? .monochrome : .hierarchical)
            }
            .buttonStyle(.borderless)
        }
    }

    /// Contact card: expandable/collapsible so user can show and hide it.
    var contactCardSection: some View {
        VStack(spacing: 0) {
            Button {
                if isContactCardExpanded == false {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                withAnimation(.easeInOut(duration: 0.2)) { isContactCardExpanded.toggle() }
            } label: {
                HStack {
                    Text("Send Report")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: isContactCardExpanded ? "chevron.down" : "chevron.up")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, spacingL)
                .padding(.vertical, spacingS)
                .background(Color(.secondarySystemGroupedBackground))
            }
            .buttonStyle(.plain)

            if isContactCardExpanded {
                sendReportSection
            }
        }
    }

    /// Contact form: pure entry only (name, email). No winery lookup while typing.
    /// On Send, logs to session with the current winery already loaded on the page (no 250k reference).
    var sendReportSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Form {
                Section {
                    TextField("Contact name", text: $contactName)
                        .submitLabel(.next)
                    TextField("Email", text: $contactEmail)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .submitLabel(.done)
                } header: {
                    Text("Contact details")
                } footer: {
                    VStack(spacing: spacingXS) {
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(vivinoRed)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        Text("Contact is saved on this device. Choose Mail, Gmail, Outlook, or any app to send the report.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        if !isRecording {
                            Text("Session paused - sends are still logged.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                }

                Section {
                    Button(action: handleSend) {
                        Text("Send Report")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(vivinoRed)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadiusControl))
                    }
                    .listRowBackground(vivinoRed)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color(.secondarySystemGroupedBackground))
    }

    func handleSend() {
        errorMessage = ""
        guard let w = winery else {
            errorMessage = "Please search for a winery first."
            return
        }
        guard !contactName.trimmingCharacters(in: .whitespaces).isEmpty,
              !contactEmail.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter both name and email."
            return
        }
        guard contactEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }

        if isRecording {
            SessionLogger.log(winery: w, contactName: contactName,
                              contactEmail: contactEmail, isRecording: true)
        } else {
            pendingLog = (w, contactName, contactEmail)
        }

        // Generate branded PDF report
        let pdfData = ReportPDFGenerator.generate(winery: w, contactName: contactName)
        let safeName = w.name
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
        let subjectLine = "Your Vivino Report from Prowein - \(w.name)"
        let fileName = "Vivino Report - Prowein - \(safeName).pdf"

        let bodyText = """
        Hi \(contactName),

        It was great connecting with you at ProWein 2026!

        As promised, please find your personalised Vivino report for \(w.name) attached to this email. It includes your global rating, audience engagement, pageview and scan rankings in \(w.country), new-to-brand discovery metrics, and sales overview.

        A few quick highlights:
        • You're in the top \(Int(w.pageviewRankPercent))% of wineries in \(w.country) by pageviews
        • \(compactFormat(w.scans12m)) label scans in the last 12 months
        • Buy-button coverage is currently at \(Int(w.buyButtonCoverage * 100))%

        We'd love to help you get even more out of Vivino. If you have any questions about the data or would like to explore partnership opportunities, just reply to this email - we're happy to help.

        Cheers,
        The Vivino Partner Team
        """

        if MFMailComposeViewController.canSendMail() {
            mailRecipient = contactEmail
            mailSubject = subjectLine
            mailAttachment = pdfData
            mailAttachmentName = fileName
            mailBody = bodyText
            showMail = true
        } else {
            sharePDFData = pdfData
            shareFileName = fileName
            shareEmailSuggestion = "To: \(contactEmail)\nSubject: \(subjectLine)\n\n\(bodyText)"
            showShareSheet = true
        }

        contactName = ""
        contactEmail = ""
    }
}

// MARK: - WineryCardView (grouped, App Store–style card)

private let statFont = Font.title2.weight(.semibold)

struct WineryCardView: View {
    let winery: Winery

    private var profileURL: URL? {
        guard let wineryId = winery.wineryId else { return nil }
        return URL(string: "https://www.vivino.com/wineries/\(wineryId)")
    }

    private var ntbPVPct: Int {
        winery.pageviews12m > 0
            ? Int((Double(winery.newToBrandPageviews12m) / Double(winery.pageviews12m)) * 100)
            : 0
    }

    private var ntbOrdPct: Int {
        winery.bottlesSold12m > 0
            ? Int((Double(winery.newToBrandOrders12m) / Double(winery.bottlesSold12m)) * 100)
            : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacingL) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: spacingXS) {
                    Text(winery.name)
                        .font(.title2.weight(.semibold))
                    Text("\(winery.region) · \(winery.country)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 6) {
                    Text(winery.wineryStatusDisplayName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(winery.wineryStatus.lowercased() == "sponsor" ? vivinoRed : .secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            winery.wineryStatus.lowercased() == "sponsor"
                                ? vivinoRedLight
                                : Color(.tertiarySystemFill)
                        )
                        .clipShape(Capsule())

                    if let url = profileURL {
                        VStack(spacing: 4) {
                            Link(destination: url) {
                                Text("Profile preview")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(vivinoRed)
                                    .clipShape(Capsule())
                            }
                            Text("Opens in browser")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }

            // Data grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: spacingS) {
                globalRatingCell
                ratingsCell
                pageviewsCell
                scansCell
                newToBrandPageviewsCell
                newToBrandOrdersCell
                winesListedCell
                bottlesSoldCell
            }

            // Buy button coverage (full width)
            buyButtonSection

            // Most engaged country (full width)
            mostEngagedSection

            Text("All data representative of last 12 complete months.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(spacingL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadiusCard))
    }

    private var buyButtonSection: some View {
        VStack(alignment: .leading, spacing: spacingS) {
            Text("Buy button coverage")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: spacingS) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 8)
                        Capsule()
                            .fill(winery.buyButtonCoverage == 0 ? Color(.quaternarySystemFill) : vivinoRed)
                            .frame(width: max(0, geo.size.width * winery.buyButtonCoverage), height: 8)
                    }
                }
                .frame(height: 8)
                Text("\(Int(winery.buyButtonCoverage * 100))%")
                    .font(statFont)
                    .foregroundStyle(winery.buyButtonCoverage == 0 ? .secondary : vivinoRed)
                    .frame(minWidth: 36, alignment: .trailing)
            }
        }
        .padding(spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadiusControl))
    }

    /// Top engaged country excluding origin (data may have origin in CSV; we hide it).
    private func countryOutsideOrigin(_ value: String?) -> String? {
        guard let v = value, !v.isEmpty else { return nil }
        return v.trimmingCharacters(in: .whitespaces).lowercased() == winery.country.trimmingCharacters(in: .whitespaces).lowercased() ? nil : v
    }

    private var mostEngagedSection: some View {
        let pageviewsCountry = countryOutsideOrigin(winery.topEngagedCountryPageviews)
        let bottlesCountry = countryOutsideOrigin(winery.topEngagedCountryBottlesSold)
        return VStack(alignment: .leading, spacing: spacingS) {
            Text("Most engaged country (outside origin)")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("By pageviews")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    if let c = pageviewsCountry {
                        HStack(spacing: 6) {
                            FlagView(country: c)
                            Text(c)
                                .font(.subheadline.weight(.medium))
                        }
                    } else {
                        Text("—")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("By bottles sold")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    if let c = bottlesCountry {
                        HStack(spacing: 6) {
                            FlagView(country: c)
                            Text(c)
                                .font(.subheadline.weight(.medium))
                        }
                    } else if winery.topEngagedCountryBottlesSold == nil || winery.topEngagedCountryBottlesSold?.isEmpty == true {
                        Text("— No sales yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("—")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadiusControl))
    }

    private var globalRatingCell: some View {
        dataCell(label: "Global rating") {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(format: "%.1f", winery.globalRating))
                    .font(statFont)
                RatingStarView()
            }
        }
    }

    private var ratingsCell: some View {
        dataCell(label: "Ratings") {
            Text(winery.ratingsCount.formatted())
                .font(statFont)
        }
    }

    private var pageviewsCell: some View {
        dataCell(label: "Pageviews") {
            VStack(alignment: .leading, spacing: spacingXS) {
                Text(compactFormat(winery.pageviews12m))
                    .font(statFont)
                HStack(spacing: 6) {
                    Text("Top \(Int(winery.pageviewRankPercent))%")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(vivinoRed)
                        .clipShape(Capsule())
                    Text("of \(winery.pageviewRankTotal.formatted()) in \(winery.country)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var scansCell: some View {
        dataCell(label: "Scans") {
            VStack(alignment: .leading, spacing: spacingXS) {
                Text(compactFormat(winery.scans12m))
                    .font(statFont)
                HStack(spacing: 6) {
                    Text("Top \(Int(winery.scanRankPercent))%")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(vivinoRed)
                        .clipShape(Capsule())
                    Text("of \(winery.scanRankTotal.formatted()) in \(winery.country)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var newToBrandPageviewsCell: some View {
        dataCell(label: "New to brand (pageviews)") {
            VStack(alignment: .leading, spacing: spacingXS) {
                Text("\(ntbPVPct)%")
                    .font(statFont)
                    .foregroundStyle(vivinoRed)
                Text("First-time discoverers")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var newToBrandOrdersCell: some View {
        dataCell(label: "New to brand (orders)") {
            VStack(alignment: .leading, spacing: spacingXS) {
                if winery.bottlesSold12m > 0 {
                    Text("\(ntbOrdPct)%")
                        .font(statFont)
                        .foregroundStyle(vivinoRed)
                    Text("First-time buyers")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("—")
                        .font(statFont)
                        .foregroundStyle(.secondary)
                    Text("No sales yet")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var winesListedCell: some View {
        dataCell(label: "Wines listed") {
            Text("\(winery.winesListed)")
                .font(statFont)
        }
    }

    private var bottlesSoldCell: some View {
        dataCell(label: "Bottles sold") {
            Text(winery.bottlesSold12m.formatted())
                .font(statFont)
                .foregroundStyle(winery.bottlesSold12m == 0 ? .secondary : .primary)
        }
    }

    private func dataCell<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: spacingXS) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(spacingM)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadiusControl))
    }
}

#Preview {
    ContentView()
}
