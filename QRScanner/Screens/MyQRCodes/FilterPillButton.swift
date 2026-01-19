import SwiftUI
import Foundation

// MARK: - Filter Pill Button
struct FilterPillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom(FontEnum.interMedium.rawValue, size: 14))
                .foregroundColor(isSelected ? .white : Color(hex: "5A5A5A"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "5AC8FA") : Color(hex: "E5E7EB"))
                .cornerRadius(20)
        }
    }
}
