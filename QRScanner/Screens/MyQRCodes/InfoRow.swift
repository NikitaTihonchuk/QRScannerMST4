import SwiftUI
import Foundation

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(FontEnum.interMedium.rawValue, size: 13))
                .foregroundColor(Color(hex: "6C6C70"))
            
            Text(value)
                .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)
        }
    }
}
