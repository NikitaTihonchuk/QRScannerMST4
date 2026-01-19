import SwiftUI
import Foundation


// MARK: - Supporting Views
struct ContentTypeButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if title == "Text" || title == "Contact" {
                VStack(spacing: 8) {
                    if title == "Text" {
                        Image("aIcon")
                    } else {
                        Image(systemName: icon)
                            .foregroundColor(isSelected ? Color(hex: "111111") : Color(hex: "111111"))
                    }
                    
                    Text(title)
                        .font(.custom(FontEnum.interMedium.rawValue, size: 15))
                        .foregroundColor(isSelected ? Color(hex: "111111") : Color(hex: "111111"))
                        .offset(y: title == "Text" ? -2 : 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: title == "Wi-Fi" ? 50 : 70)
                .background(isSelected ? Color(hex: "FFFFFF") : Color(hex: "F6F7FA"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "E5E7EB"), lineWidth: 2)
                )
                .shadow(color: .white ,radius: 10.0)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? Color(hex: "111111") : Color(hex: "111111"))
                    
                    Text(title)
                        .font(.custom(FontEnum.interMedium.rawValue, size: 15))
                        .foregroundColor(isSelected ? Color(hex: "111111") : Color(hex: "111111"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: title == "Wi-Fi" ? 50 : 70)
                .background(isSelected ? Color(hex: "FFFFFF") : Color(hex: "F6F7FA"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "E5E7EB"), lineWidth: 2)
                )
                .shadow(color: .white ,radius: 10.0)
            }
        }
    }
}
