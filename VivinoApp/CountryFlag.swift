import Foundation
import SwiftUI

/// Country flag image asset. Asset names follow `flag_{iso}_24` (e.g. `flag_us_24`).
/// Use `CountryFlag(isoCode:)` to get the asset name for a given ISO 3166-1 alpha-2 code.
struct CountryFlag: RawRepresentable {
    let rawValue: String

    init?(rawValue: String) {
        guard rawValue.hasPrefix("flag_"), rawValue.hasSuffix("_24"),
              rawValue.count == 11, rawValue.dropFirst(5).dropLast(3).allSatisfy({ $0.isLetter || $0.isNumber })
        else { return nil }
        self.rawValue = rawValue
    }

    /// Creates a country flag from a 2-letter ISO 3166-1 alpha-2 code (e.g. "US", "fr").
    init?(isoCode: String) {
        let code = isoCode.lowercased()
        guard code.count == 2, code.allSatisfy({ $0.isLetter }) else { return nil }
        self.rawValue = "flag_\(code)_24"
    }

    /// ISO 3166-1 alpha-2 code (e.g. "us") derived from the asset name.
    var isoCode: String? {
        guard rawValue.hasPrefix("flag_"), rawValue.hasSuffix("_24"), rawValue.count == 11 else { return nil }
        return String(rawValue.dropFirst(5).dropLast(3))
    }
}

// MARK: - Country display name → ISO code (for winery/API country strings)

private let countryNameToISO: [String: String] = [
    "Albania": "al", "Argentina": "ar", "Armenia": "am", "Australia": "au", "Austria": "at",
    "Belgium": "be", "Bolivia": "bo", "Brazil": "br", "Bulgaria": "bg", "Canada": "ca",
    "Chile": "cl", "China": "cn", "Colombia": "co", "Croatia": "hr", "Cyprus": "cy",
    "Czech Republic": "cz", "Denmark": "dk", "Finland": "fi", "France": "fr", "Georgia": "ge",
    "Germany": "de", "Greece": "gr", "Hong Kong": "hk", "Hungary": "hu", "Ireland": "ie",
    "Israel": "il", "Italy": "it", "Japan": "jp", "Lebanon": "lb", "Luxembourg": "lu",
    "Mexico": "mx", "Moldova": "md", "Monaco": "mc", "Netherlands": "nl", "New Zealand": "nz",
    "Norway": "no", "Poland": "pl", "Portugal": "pt", "Romania": "ro", "Russia": "ru",
    "Serbia": "rs", "Singapore": "sg", "Slovakia": "sk", "Slovenia": "si", "South Africa": "za",
    "Spain": "es", "Sweden": "se", "Switzerland": "ch", "Turkey": "tr", "Ukraine": "ua",
    "United Kingdom": "gb", "UK": "gb", "Great Britain": "gb", "Uruguay": "uy",
    "USA": "us", "United States": "us", "Antarctica": "aq",
    "South Korea": "kr", "North Korea": "kp", "Vietnam": "vn", "Thailand": "th", "India": "in",
    "Indonesia": "id", "Malaysia": "my", "Philippines": "ph", "Egypt": "eg", "Morocco": "ma",
    "Tunisia": "tn", "Algeria": "dz", "Kenya": "ke", "Nigeria": "ng", "Ghana": "gh",
    "Ethiopia": "et", "Tanzania": "tz", "Uganda": "ug", "Zimbabwe": "zw", "Zambia": "zm",
    "Botswana": "bw", "Namibia": "na", "Mozambique": "mz", "Angola": "ao", "Cameroon": "cm",
    "Ivory Coast": "ci", "Senegal": "sn", "Malawi": "mw", "Mali": "ml", "Burkina Faso": "bf",
    "Niger": "ne", "Chad": "td", "Sudan": "sd", "Libya": "ly", "Saudi Arabia": "sa",
    "United Arab Emirates": "ae", "UAE": "ae", "Qatar": "qa", "Kuwait": "kw", "Bahrain": "bh",
    "Oman": "om", "Yemen": "ye", "Iraq": "iq", "Iran": "ir", "Jordan": "jo", "Syria": "sy",
    "Pakistan": "pk", "Bangladesh": "bd", "Sri Lanka": "lk", "Nepal": "np", "Myanmar": "mm",
    "Cambodia": "kh", "Laos": "la", "Taiwan": "tw", "Macau": "mo", "Malta": "mt",
    "Iceland": "is", "Estonia": "ee", "Latvia": "lv", "Lithuania": "lt", "Belarus": "by",
    "Kazakhstan": "kz", "Uzbekistan": "uz", "Azerbaijan": "az", "Armenia": "am", "Kosovo": "xk",
]

/// Returns the 2-letter ISO code for a country display name (e.g. "France" → "fr"), or nil if unknown.
func isoCode(forCountryName name: String) -> String? {
    let trimmed = name.trimmingCharacters(in: .whitespaces)
    if let iso = countryNameToISO[trimmed] { return iso }
    if let iso = countryNameToISO[trimmed.lowercased().replacingOccurrences(of: " ", with: " ")] { return iso }
    return nil
}
