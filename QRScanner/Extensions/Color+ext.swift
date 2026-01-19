import SwiftUI

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexPrefix = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var hexToInt: UInt64 = 0

        Scanner(string: hexPrefix).scanHexInt64(&hexToInt)

        let red = Double((hexToInt >> 16) & 0xFF) / 255.0
        let green = Double((hexToInt >> 8) & 0xFF) / 255.0
        let blue = Double((hexToInt) & 0xFF) / 255.0

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
