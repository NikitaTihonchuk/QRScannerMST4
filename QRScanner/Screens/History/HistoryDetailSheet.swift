import Foundation
import SwiftUI

struct HistoryDetailSheet: View {
    let item: HistoryItem
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F6F7FA")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(item.actionType == .scanned ? Color(hex: "5AC8FA") : Color(hex: "4CAF50"))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: item.actionType == .scanned ? "qrcode.viewfinder" : "plus")
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Info
                        VStack(spacing: 12) {
                            InfoRow(title: "Title", value: item.title)
                            InfoRow(title: "Type", value: item.type.title)
                            InfoRow(title: "Content", value: item.content)
                            InfoRow(title: "Action", value: item.actionType == .scanned ? "Scanned" : "Created")
                            InfoRow(title: "Date", value: formatFullDate(item.date))
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                copyToClipboard(item.content)
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
                            
                            Button(action: {
                                shareContent(item.content)
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Share")
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
                            
                            Button(action: {
                                HistoryManager.shared.deleteItem(id: item.id)
                                isPresented = false
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
            .navigationTitle("History Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(Color(hex: "5AC8FA"))
                }
            }
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
