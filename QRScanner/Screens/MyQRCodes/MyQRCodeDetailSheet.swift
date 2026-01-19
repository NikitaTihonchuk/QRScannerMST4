import SwiftUI

struct MyQRCodeDetailSheet: View {
    let qrCode: MyQRCodeItem
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var brightness: CGFloat = 1.0
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F6F7FA")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // QR Code Display
                        VStack(spacing: 16) {
                            if let qrImage = qrCode.qrImage {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 280, height: 280)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                                    .brightness(brightness - 1.0)
                            }
                            
                            // Brightness Control
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "sun.min")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "5A5A5A"))
                                    
                                    Slider(value: $brightness, in: 0.5...1.5)
                                        .accentColor(Color(hex: "5AC8FA"))
                                    
                                    Image(systemName: "sun.max")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "5A5A5A"))
                                }
                                
                                Text("Adjust brightness for better scanning")
                                    .font(.custom(FontEnum.interRegular.rawValue, size: 12))
                                    .foregroundColor(Color(hex: "B0B0B0"))
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // QR Code Info
                        VStack(spacing: 12) {
                            InfoRow(title: "Name", value: qrCode.name)
                            InfoRow(title: "Type", value: qrCode.type.title)
                            InfoRow(title: "Content", value: qrCode.content)
                            InfoRow(title: "Created", value: formatDate(qrCode.createdDate))
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Copy
                            Button(action: {
                                copyToClipboard(qrCode.content)
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Copy Content")
                                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "5AC8FA"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            // Share
                            Button(action: {
                                showShareSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Export QR Code")
                                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .foregroundColor(Color(hex: "5AC8FA"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "5AC8FA"), lineWidth: 2)
                                )
                            }
                            
                            // Delete
                            Button(action: {
                                showDeleteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Delete")
                                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .foregroundColor(Color(hex: "FF3B30"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "FF3B30"), lineWidth: 2)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("QR Code Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5AC8FA"))
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = qrCode.qrImage {
                ShareSheet(items: [image])
            }
        }
        .alert("Delete QR Code", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                MyQRCodesManager.shared.deleteQRCode(id: qrCode.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this QR code?")
        }
    }
    
    private func copyToClipboard(_ content: String) {
        UIPasteboard.general.string = content
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
