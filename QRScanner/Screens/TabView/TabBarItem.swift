import SwiftUI

struct TabBarItem: View {
    let tab: TabViewStruct
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(isSelected ? tab.iconOn : tab.iconOff)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                Text(tab.text)
                    .font(.custom(FontEnum.interMedium.rawValue, size: 10))
                    .foregroundColor(isSelected ? Color(hex: "4DB3FF") : Color(hex: "8E8E93"))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
