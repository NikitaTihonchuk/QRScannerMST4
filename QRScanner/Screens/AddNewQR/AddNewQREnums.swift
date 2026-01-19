import Foundation
import UIKit

// MARK: - Models
enum QRContentType {
    case url, text, contact, wifi
}

enum QRColor {
    case black, blue, green, orange
    
    var uiColor: UIColor {
        switch self {
        case .black: return .black
        case .blue: return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1)
        case .green: return UIColor(red: 126/255, green: 217/255, blue: 87/255, alpha: 1)
        case .orange: return UIColor(red: 255/255, green: 159/255, blue: 64/255, alpha: 1)
        }
    }
}

enum WifiSecurityType: String {
    case wpa = "WPA"
    case wep = "WEP"
    case none = "nopass"
}
