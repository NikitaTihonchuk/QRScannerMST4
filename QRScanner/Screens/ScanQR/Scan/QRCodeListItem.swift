import SwiftUI
import Foundation


struct QRCodeListItem: View {
    let qrCode: String
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Number badge
            ZStack {
                Circle()
                    .fill(Color(hex: "5AC8FA"))
                    .frame(width: 40, height: 40)
                
                Text("\(index)")
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(detectQRType(qrCode).title)
                    .font(.custom(FontEnum.interMedium.rawValue, size: 13))
                    .foregroundColor(Color(hex: "6C6C70"))
                
                Text(getDisplayContent())
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 15))
                    .foregroundColor(.black)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "C7C7CC"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getDisplayContent() -> String {
        if detectQRType(qrCode) == .url {
            return qrCode
                .replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: "http://", with: "")
        }
        return qrCode
    }
    
    private func detectQRType(_ content: String) -> QRCodeType {
        if content.starts(with: "http://") || content.starts(with: "https://") {
            return .url
        } else if content.contains("@") {
            return .email
        } else if content.starts(with: "tel:") {
            return .phone
        } else {
            return .text
        }
    }
}
