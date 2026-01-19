import SwiftUI
import Foundation

struct MyQRCodeCard: View {
    let qrCode: MyQRCodeItem
    @Binding var activeMenuID: UUID?
    
    var isMenuActive: Bool {
        activeMenuID == qrCode.id
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Type Badge at Top
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: qrCode.type.icon)
                            .font(.system(size: 10, weight: .medium))
                        
                        Text(qrCode.type.title)
                            .font(.custom(FontEnum.interMedium.rawValue, size: 11))
                    }
                    .foregroundColor(Color(hex: "5AC8FA"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "5AC8FA").opacity(0.1))
                    .cornerRadius(6)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                
                // QR Code Preview
                if let qrImage = qrCode.qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .background(Color(hex: "5AC8FA"))
                        .cornerRadius(12)
                        .padding(.top, 8)
                }
                
                // Name and Menu Button
                HStack(alignment: .top, spacing: 4) {
                    Text(qrCode.name)
                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 15))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if isMenuActive {
                                activeMenuID = nil
                            } else {
                                activeMenuID = qrCode.id
                            }
                        }
                    }) {
                        Image("editButton")
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Content Preview
                Text(qrCode.content)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 12))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.top, 2)
                
                // Date and Views
                HStack(spacing: 8) {
                    Text(formatDate(qrCode.createdDate))
                        .font(.custom(FontEnum.interRegular.rawValue, size: 11))
                        .foregroundColor(Color(hex: "B0B0B0"))
                    
                    Spacer()
                    
                    
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Custom Action Menu
            if isMenuActive {
                ActionMenu(
                    onShare: {
                        activeMenuID = nil
                        if let image = qrCode.qrImage {
                            shareQRCode(image)
                        }
                    },
                    onEdit: {
                        activeMenuID = nil
                        // TODO: Implement edit functionality
                    },
                    onDelete: {
                        activeMenuID = nil
                        MyQRCodesManager.shared.deleteQRCode(id: qrCode.id)
                    }
                )
                .offset(x: 8, y: 8)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func shareQRCode(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
