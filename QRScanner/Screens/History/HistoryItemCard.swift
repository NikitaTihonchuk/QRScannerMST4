import Foundation
import SwiftUI

// MARK: - History Item Card
struct HistoryItemCard: View {
    let item: HistoryItem
    @State private var showActionMenu = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(item.actionType == .scanned ? Color(hex: "5AC8FA") : Color(hex: "4CAF50"))
                    .frame(width: 56, height: 56)
                
                Image(systemName: item.actionType == .scanned ? "qrcode.viewfinder" : "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(item.content)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 14))
                    .foregroundColor(Color(hex: "5A5A5A"))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(item.actionType == .scanned ? "Scanned" : "Created")
                        .font(.custom(FontEnum.interRegular.rawValue, size: 12))
                        .foregroundColor(Color(hex: "B0B0B0"))
                    
                    Text("•")
                        .foregroundColor(Color(hex: "B0B0B0"))
                    
                    Text(formatTime(item.date))
                        .font(.custom(FontEnum.interRegular.rawValue, size: 12))
                        .foregroundColor(Color(hex: "B0B0B0"))
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    copyToClipboard(item.content)
                }) {
                    Image("copyHistoryIcon")
                }
                
                Button(action: {
                    shareContent(item.content)
                }) {
                    Image("shareHistoryIcon")

                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func copyToClipboard(_ content: String) {
        UIPasteboard.general.string = content
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func shareContent(_ content: String) {
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
