import SwiftUI
import Foundation

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            // Animate press
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Execute action
            action()
            
            // Reset animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: icon.contains("fill") ? .semibold : .regular))
                    .foregroundColor(icon.contains("fill") ? Color(hex: "000000") : Color(hex: "000000"))
                
                Text(title)
                    .font(.custom(FontEnum.interMedium.rawValue, size: 14))
                    .foregroundColor(icon.contains("fill") ? Color(hex: "000000") : Color(hex: "000000"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                Color(hex: "FFFFFF")
            )
            .shadow(color: .white, radius: 4.0)
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
