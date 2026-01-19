import SwiftUI
import Foundation


struct ColorButton: View {
    let color: QRColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(uiColor: color.uiColor))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .overlay(
                            Circle()
                                .strokeBorder(Color(hex: "5AC8FA"), lineWidth: 2)
                        )
                        .opacity(isSelected ? 1 : 0)
                )
        }
    }
}
