import Foundation
import SwiftUI

struct HomeButtonCard: View {
    let button: HomeMainButtonStruct
    @Binding var selectedTab: Int
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            handleButtonTap()
        }) {
            VStack(spacing: 16) {
                // Circle icon container
                ZStack {
                    Circle()
                        .fill(getButtonColor(for: button.title))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: getIconName(for: button.title))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                
                // Text container with fixed height and centered content
                VStack(spacing: 4) {
                    Text(button.title)
                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 17))
                        .foregroundColor(Color(hex: "000000"))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                    
                    Text(button.subtitle)
                        .font(.custom("Inter-Regular", size: 13))
                        .foregroundColor(Color(hex: "5A5A5A"))
                        .lineLimit(1)
                }
                .frame(height: 68) // Фиксированная высота для всего текстового блока
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220) // Фиксированная общая высота карточки
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private func getButtonColor(for title: String) -> Color {
        if title.contains("Scan") {
            return Color(hex: "5AC8FA") // Blue
        } else if title.contains("Create") {
            return Color(hex: "34C759") // Green
        } else if title.contains("QR") && title.contains("Codes") {
            return Color(hex: "FF9F0A") // Orange
        } else {
            return Color(hex: "98989D") // Gray
        }
    }
    
    private func getIconName(for title: String) -> String {
        if title.contains("Scan") {
            return "qrcode.viewfinder"
        } else if title.contains("Create") {
            return "plus"
        } else if title.contains("QR") && title.contains("Codes") {
            return "folder.fill"
        } else {
            return "clock.arrow.circlepath"
        }
    }
    
    private func handleButtonTap() {
        print("Tapped: \(button.title)")
        selectedTab = button.id
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}
