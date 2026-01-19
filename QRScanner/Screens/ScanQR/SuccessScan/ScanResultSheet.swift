import SwiftUI

struct ScanResultSheet: View {
    let result: ScannedQRCode
    @Binding var isPresented: Bool
    @State private var showCopiedAlert = false
    @State private var showSavedAlert = false
    @State private var showShareSheet = false
    @StateObject private var historyManager = QRHistoryManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F5F5F7")
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Text(Localization.ScanResult.title)
                            .foregroundStyle(Color(hex: "000000"))
                            .font(.custom(FontEnum.interSemiBold.rawValue, size: 22.0))
                        
                        Spacer()
                        
                        Button {
                            isPresented = false
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(Color(hex: "E5E7EB"))
                                
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color(hex: "000000"))
                                    .frame(width: 10, height: 15)
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(
                        Rectangle()
                            .foregroundStyle(Color(hex: "FFFFFF"))
                            .ignoresSafeArea()
                        
                    )
                    ScrollView {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "34C759"))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color(hex: "77C97E"), radius: 10)
                        .padding(.top, 10)
                        
                        // Success message
                        VStack(spacing: 8) {
                            Text(Localization.ScanResult.scanSuccessful)
                                .font(.custom(FontEnum.interSemiBold.rawValue, size: 17))
                                .foregroundColor(.black)
                            
                            Text(Localization.ScanResult.qrCodeDecodedSuccessfully)
                                .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                        
                        // Content card
                        VStack(alignment: .leading, spacing: 16) {
                            // Type header
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "5AC8FA"))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: result.type.icon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(hex: "FFFFFF"))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.type.title)
                                        .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                                        .foregroundColor(Color(hex: "6C6C70"))
                                    
                                    Text(getDisplayContent())
                                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 17))
                                        .foregroundColor(.black)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            // Full content
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.ScanResult.fullContent)
                                    .font(.custom("Inter-Regular", size: 15))
                                    .foregroundColor(Color(hex: "6C6C70"))
                                
                                Text(result.content)
                                    .font(.custom("Inter-Regular", size: 17))
                                    .foregroundColor(.black)
                                    .textSelection(.enabled)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                Color(hex: "E5E7EB").opacity(0.5)
                            )
                            .cornerRadius(16)
                            .padding(.horizontal, 25)
                            
                            
                            // Metadata
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(Localization.ScanResult.scanned)
                                        .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                        .foregroundColor(Color(hex: "6C6C70"))
                                    
                                    Text(formatDate(result.scannedDate))
                                        .font(.custom(FontEnum.interMedium.rawValue, size: 15))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(Localization.ScanResult.type)
                                        .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                        .foregroundColor(Color(hex: "6C6C70"))
                                    
                                    Text(result.type == .url ? Localization.ScanResult.url : result.type.title.uppercased())
                                        .font(.custom(FontEnum.interMedium.rawValue, size: 15))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16.0)
                                .foregroundStyle(Color(hex: "FFFFFF"))
                                .shadow(color: .gray, radius: 1.0)
                                
                        )
                        .padding(.horizontal, 20)
                        
                        // Action button
                        if result.type == .url {
                            Button(action: {
                                openURL()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Text(Localization.ScanResult.openLink)
                                        .font(.custom("Inter-SemiBold", size: 17))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "5AC8FA"))
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top)
                        }
                        
                        // Bottom actions
                        HStack(spacing: 16) {
                            // Copy
                            Button(action: {
                                copyToClipboard()
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 24))
                                        .foregroundColor(.black)
                                    
                                    Text(Localization.ScanResult.copy)
                                        .font(.custom("Inter-Medium", size: 13))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                            
                            // Share
                            Button(action: {
                                showShareSheet = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 24))
                                        .foregroundColor(.black)
                                    
                                    Text(Localization.ScanResult.share)
                                        .font(.custom("Inter-Medium", size: 13))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                            
                            // Save
                            Button(action: {
                                saveToHistory()
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: historyManager.isInHistory(content: result.content) ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 24))
                                        .foregroundColor(historyManager.isInHistory(content: result.content) ? Color(hex: "5AC8FA") : .black)
                                    
                                    Text(historyManager.isInHistory(content: result.content) ? Localization.ScanResult.saved : Localization.ScanResult.save)
                                        .font(.custom("Inter-Medium", size: 13))
                                        .foregroundColor(historyManager.isInHistory(content: result.content) ? Color(hex: "5AC8FA") : .black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [result.content])
        }
        .overlay(
            Group {
                if showCopiedAlert {
                    CopiedAlertView()
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showSavedAlert {
                    SavedAlertView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
    
    private func getDisplayContent() -> String {
        if result.type == .url {
            return result.content
                .replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: "http://", with: "")
        }
        return result.content
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func openURL() {
        if let url = URL(string: result.content) {
            UIApplication.shared.open(url)
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = result.content
        withAnimation {
            showCopiedAlert = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedAlert = false
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func saveToHistory() {
        // Сохраняем в историю через менеджер
        historyManager.saveToHistory(result)
        
        // Показываем уведомление
        withAnimation {
            showSavedAlert = true
        }
        
        // Скрываем уведомление через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSavedAlert = false
            }
        }
        
        // Тактильная обратная связь
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}



#Preview {
    ScanResultSheet(
        result: ScannedQRCode(
            content: "https://www.example.com/product/special-offer-2024",
            type: .url,
            scannedDate: Date()
        ),
        isPresented: .constant(true)
    )
}
