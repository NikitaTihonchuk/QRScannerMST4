import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - My QR Code Item Model
struct MyQRCodeItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let content: String
    let qrImageData: Data
    let createdDate: Date
    let type: QRCodeContentType
    
    enum QRCodeContentType: String, Codable {
        case text
        case url
        case email
        case phone
        case wifi
        case contact
        
        var icon: String {
            switch self {
            case .text: return "text.alignleft"
            case .url: return "link"
            case .email: return "envelope.fill"
            case .phone: return "phone.fill"
            case .wifi: return "wifi"
            case .contact: return "person.fill"
            }
        }
        
        var title: String {
            switch self {
            case .text: return "Text"
            case .url: return "Website"
            case .email: return "Email"
            case .phone: return "Phone"
            case .wifi: return "Wi-Fi"
            case .contact: return "Contact"
            }
        }
    }
    
    var qrImage: UIImage? {
        UIImage(data: qrImageData)
    }
}
