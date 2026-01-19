import SwiftUI
import Foundation

struct SavedAlertView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "34C759"))
            
            Text(Localization.ScanResult.savedToHistory)
                .font(.custom("Inter-SemiBold", size: 15))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
    }
}
