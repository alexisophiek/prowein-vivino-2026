import UIKit

/// Generates a branded single-page PDF report for a winery.
struct ReportPDFGenerator {

    // MARK: - Brand colours
    private static let vivinoRed = UIColor(red: 0.675, green: 0.118, blue: 0.176, alpha: 1)
    private static let lightGray = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
    private static let mediumGray = UIColor.secondaryLabel

    // MARK: - Fonts
    private static func bold(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .bold) }
    private static func semibold(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .semibold) }
    private static func regular(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .regular) }
    private static func caption(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .medium) }

    // MARK: - Public API

    /// Returns PDF data for the given winery, addressed to `contactName`.
    /// Uses A4 to keep file size down and suit international (e.g. ProWein) recipients.
    static func generate(winery w: Winery, contactName: String) -> Data {
        let pageWidth: CGFloat = 595.28   // A4
        let pageHeight: CGFloat = 841.89
        let margin: CGFloat = 40
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { ctx in
            ctx.beginPage()
            // PDF uses bottom-left origin; flip so we can draw top-down (header at top, footer at bottom).
            ctx.cgContext.translateBy(x: 0, y: pageHeight)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            var y: CGFloat = margin

            // ── Header bar ──────────────────────────────────────────────
            let headerRect = CGRect(x: 0, y: 0, width: pageWidth, height: 80)
            vivinoRed.setFill()
            ctx.cgContext.fill(headerRect)

            let logoText = "vivino"
            let logoAttr: [NSAttributedString.Key: Any] = [
                .font: bold(28),
                .foregroundColor: UIColor.white
            ]
            let logoSize = (logoText as NSString).size(withAttributes: logoAttr)
            (logoText as NSString).draw(
                at: CGPoint(x: margin, y: (80 - logoSize.height) / 2),
                withAttributes: logoAttr
            )

            let tagline = "Prowein 2026 · Winery Report"
            let tagAttr: [NSAttributedString.Key: Any] = [
                .font: regular(13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
            let tagSize = (tagline as NSString).size(withAttributes: tagAttr)
            (tagline as NSString).draw(
                at: CGPoint(x: pageWidth - margin - tagSize.width, y: (80 - tagSize.height) / 2),
                withAttributes: tagAttr
            )

            y = 80 + 32

            // ── Winery name & location ──────────────────────────────────
            let nameAttr: [NSAttributedString.Key: Any] = [.font: bold(24), .foregroundColor: UIColor.label]
            (w.name as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: nameAttr)
            y += 32

            let locationAttr: [NSAttributedString.Key: Any] = [.font: regular(14), .foregroundColor: mediumGray]
            let location = "\(w.region) · \(w.country)  —  \(w.wineryStatusDisplayName)"
            (location as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: locationAttr)
            y += 30

            // ── Divider ─────────────────────────────────────────────────
            lightGray.setFill()
            ctx.cgContext.fill(CGRect(x: margin, y: y, width: contentWidth, height: 1))
            y += 20

            // ── Stat rows ───────────────────────────────────────────────
            let ntbPVPct = w.pageviews12m > 0
                ? Int((Double(w.newToBrandPageviews12m) / Double(w.pageviews12m)) * 100) : 0
            let ntbOrdPct = w.bottlesSold12m > 0
                ? Int((Double(w.newToBrandOrders12m) / Double(w.bottlesSold12m)) * 100) : 0

            let colWidth = contentWidth / 2

            // Row 1
            y = drawStatPair(
                ctx: ctx, y: y, x: margin, colWidth: colWidth,
                label1: "Global Rating", value1: String(format: "%.1f", w.globalRating),
                label2: "Ratings (last 12 months)", value2: w.ratingsCount.formatted()
            )

            // Row 2
            y = drawStatPair(
                ctx: ctx, y: y, x: margin, colWidth: colWidth,
                label1: "Pageviews (last 12 months)", value1: compactFmt(w.pageviews12m),
                sub1: "Top \(Int(w.pageviewRankPercent))% of \(w.pageviewRankTotal.formatted()) wineries in \(w.country)",
                label2: "Scans (last 12 months)", value2: compactFmt(w.scans12m),
                sub2: "Top \(Int(w.scanRankPercent))% of \(w.scanRankTotal.formatted()) wineries in \(w.country)"
            )

            // Row 3
            y = drawStatPair(
                ctx: ctx, y: y, x: margin, colWidth: colWidth,
                label1: "New-to-Brand Pageviews", value1: "\(ntbPVPct)%",
                sub1: "First-time discoverers",
                label2: "New-to-Brand Orders",
                value2: w.bottlesSold12m > 0 ? "\(ntbOrdPct)%" : "—",
                sub2: w.bottlesSold12m > 0 ? "First-time buyers" : "No sales on Vivino yet"
            )

            // Row 4
            y = drawStatPair(
                ctx: ctx, y: y, x: margin, colWidth: colWidth,
                label1: "Wines Listed", value1: "\(w.winesListed)",
                label2: "Bottles Sold (last 12 months)", value2: w.bottlesSold12m.formatted()
            )

            // ── Buy button coverage bar ─────────────────────────────────
            y += 4
            let bbLabel = "Buy Button Coverage"
            let bbLabelAttr: [NSAttributedString.Key: Any] = [.font: caption(11), .foregroundColor: mediumGray]
            (bbLabel as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: bbLabelAttr)
            y += 18

            let barHeight: CGFloat = 10
            let barWidth: CGFloat = contentWidth - 60
            lightGray.setFill()
            let barBg = UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: barWidth, height: barHeight), cornerRadius: 5)
            barBg.fill()

            vivinoRed.setFill()
            let fillW = max(0, barWidth * CGFloat(w.buyButtonCoverage))
            let barFg = UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: fillW, height: barHeight), cornerRadius: 5)
            barFg.fill()

            let pctText = "\(Int(w.buyButtonCoverage * 100))%"
            let pctAttr: [NSAttributedString.Key: Any] = [.font: semibold(14), .foregroundColor: vivinoRed]
            (pctText as NSString).draw(at: CGPoint(x: margin + barWidth + 10, y: y - 3), withAttributes: pctAttr)
            y += barHeight + 24

            // ── Most engaged countries ──────────────────────────────────
            let engLabel = "Most Engaged Country"
            (engLabel as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: bbLabelAttr)
            y += 20

            let engAttr: [NSAttributedString.Key: Any] = [.font: semibold(13), .foregroundColor: UIColor.label]
            let engSub: [NSAttributedString.Key: Any] = [.font: regular(11), .foregroundColor: mediumGray]

            ("By pageviews" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: engSub)
            let pvCountry = w.topEngagedCountryPageviews.isEmpty ? "—" : w.topEngagedCountryPageviews
            (pvCountry as NSString).draw(at: CGPoint(x: margin, y: y + 16), withAttributes: engAttr)

            ("By bottles sold" as NSString).draw(at: CGPoint(x: margin + colWidth, y: y), withAttributes: engSub)
            let bottlesCountry = (w.topEngagedCountryBottlesSold?.isEmpty ?? true) ? "No sales yet" : (w.topEngagedCountryBottlesSold ?? "No sales yet")
            (bottlesCountry as NSString).draw(at: CGPoint(x: margin + colWidth, y: y + 16), withAttributes: engAttr)

            y += 50

            // ── Footer ──────────────────────────────────────────────────
            let footerY = pageHeight - margin - 16
            lightGray.setFill()
            ctx.cgContext.fill(CGRect(x: margin, y: footerY - 12, width: contentWidth, height: 1))
            let footerAttr: [NSAttributedString.Key: Any] = [.font: regular(9), .foregroundColor: mediumGray]
            let footer = "Confidential — prepared for \(contactName) by Vivino at Prowein 2026. Data reflects the 12 months ending Feb 2026."
            (footer as NSString).draw(
                in: CGRect(x: margin, y: footerY, width: contentWidth, height: 20),
                withAttributes: footerAttr
            )
        }
    }

    // MARK: - Helpers

    private static func compactFmt(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000     { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }

    /// Draw a pair of stat cells side-by-side and return the new Y position. Top-down y.
    @discardableResult
    private static func drawStatPair(
        ctx: UIGraphicsPDFRendererContext,
        y: CGFloat,
        x: CGFloat,
        colWidth: CGFloat,
        label1: String, value1: String, sub1: String? = nil,
        label2: String, value2: String, sub2: String? = nil
    ) -> CGFloat {
        let labelAttr: [NSAttributedString.Key: Any] = [.font: caption(11), .foregroundColor: mediumGray]
        let valueAttr: [NSAttributedString.Key: Any] = [.font: semibold(20), .foregroundColor: UIColor.label]
        let subAttr: [NSAttributedString.Key: Any] = [.font: regular(10), .foregroundColor: mediumGray]

        var cy = y

        // Left column
        (label1 as NSString).draw(at: CGPoint(x: x, y: cy), withAttributes: labelAttr)
        (value1 as NSString).draw(at: CGPoint(x: x, y: cy + 16), withAttributes: valueAttr)
        if let s = sub1 {
            (s as NSString).draw(at: CGPoint(x: x, y: cy + 42), withAttributes: subAttr)
        }

        // Right column
        let rx = x + colWidth
        (label2 as NSString).draw(at: CGPoint(x: rx, y: cy), withAttributes: labelAttr)
        (value2 as NSString).draw(at: CGPoint(x: rx, y: cy + 16), withAttributes: valueAttr)
        if let s = sub2 {
            (s as NSString).draw(at: CGPoint(x: rx, y: cy + 42), withAttributes: subAttr)
        }

        cy += (sub1 != nil || sub2 != nil) ? 62 : 50
        return cy
    }
}
