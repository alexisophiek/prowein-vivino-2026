import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    var isHTML: Bool = false
    var attachmentData: Data? = nil
    var attachmentMimeType: String = "application/pdf"
    var attachmentFileName: String = "report.pdf"
    @Binding var isPresented: Bool
    /// When set (live session), we update this session with emailSentAt instead of logging a new one.
    var sessionId: String? = nil
    var winery: Winery? = nil
    var contactName: String? = nil
    var contactEmail: String? = nil
    var onSent: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: isHTML)
        if let data = attachmentData {
            vc.addAttachmentData(data, mimeType: attachmentMimeType, fileName: attachmentFileName)
        }
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        init(_ parent: MailView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult, error: Error?) {
            if result == .sent {
                if let id = parent.sessionId {
                    SessionLogger.updateSession(id: id, emailSentAt: Date())
                } else if let w = parent.winery, let name = parent.contactName, let email = parent.contactEmail {
                    _ = SessionLogger.log(winery: w, contactName: name, contactEmail: email, isRecording: false, emailSentAt: Date())
                }
            }
            parent.onSent?()
            parent.isPresented = false
        }
    }
}
