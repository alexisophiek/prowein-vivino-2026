import SwiftUI
import UIKit

/// Presents the system share sheet so the user can send the report with any app (Mail, Gmail, Outlook, etc.).
/// Does not require Apple Mail to be configured.
struct ShareSheet: UIViewControllerRepresentable {
    let pdfData: Data
    let fileName: String
    /// Optional: suggested recipient, subject, and body so the user can paste into their mail app.
    var emailSuggestion: String? = nil
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        try? pdfData.write(to: fileURL)

        var items: [Any] = [fileURL]
        if let suggestion = emailSuggestion {
            items.append(suggestion)
        }

        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: fileURL)
            isPresented = false
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
