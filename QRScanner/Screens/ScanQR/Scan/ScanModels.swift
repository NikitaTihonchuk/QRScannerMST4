import SwiftUI
import Foundation

// MARK: - Models
struct ScannedQRCode {
    let content: String
    let type: QRCodeType
    let scannedDate: Date
}

enum QRCodeType: String {
    case url, email, phone, text
    
    var title: String {
        switch self {
        case .url: return "Website URL"
        case .email: return "Email"
        case .phone: return "Phone"
        case .text: return "Text"
        }
    }
    
    var icon: String {
        switch self {
        case .url: return "link"
        case .email: return "envelope.fill"
        case .phone: return "phone.fill"
        case .text: return "text.alignleft"
        }
    }
}
