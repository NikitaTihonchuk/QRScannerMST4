import SwiftUI
import Foundation

struct ActionMenu: View {
    let onShare: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Share Button
            Button(action: onShare) {
                VStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "4CAF50"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "arrow.turn.up.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                    
                    Text("Share All")
                        .font(.custom(FontEnum.interMedium.rawValue, size: 10))
                        .foregroundColor(Color(hex: "5A5A5A"))
                }
            }
            
            // Edit Button
            Button(action: onEdit) {
                VStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "5AC8FA"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                    
                    Text("Edit")
                        .font(.custom(FontEnum.interMedium.rawValue, size: 10))
                        .foregroundColor(Color(hex: "5A5A5A"))
                }
            }
            
            // Delete Button
            Button(action: onDelete) {
                VStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "FF9500"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                    
                    Text("Delete")
                        .font(.custom(FontEnum.interMedium.rawValue, size: 10))
                        .foregroundColor(Color(hex: "5A5A5A"))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
    }
}
