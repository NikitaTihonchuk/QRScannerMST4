import SwiftUI
import Combine

struct MyQRCodesScreen: View {
    @StateObject private var qrCodesManager = MyQRCodesManager.shared
    @State private var selectedQRCode: MyQRCodeItem?
    @State private var showingDeleteAlert = false
    @State private var searchText = ""
    @State private var selectedFilter: QRCodeFilter = .all
    @State private var isSearching = false
    @State private var activeMenuID: UUID?
    @FocusState private var isSearchFieldFocused: Bool
    
    enum QRCodeFilter: String, CaseIterable {
        case all = "All"
        case url = "URL"
        case text = "Text"
        case wifi = "WiFi"
        case contact = "Contact"
        
        var contentType: MyQRCodeItem.QRCodeContentType? {
            switch self {
            case .all: return nil
            case .url: return .url
            case .text: return .text
            case .wifi: return .wifi
            case .contact: return .contact
            }
        }
    }
    
    var filteredQRCodes: [MyQRCodeItem] {
        var codes = qrCodesManager.myQRCodes
        
        // Apply type filter
        if let contentType = selectedFilter.contentType {
            codes = codes.filter { $0.type == contentType }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            codes = codes.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return codes
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F6F7FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                VStack(spacing: 0) {
                    if isSearching {
                        // Search Bar
                        HStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                TextField("Search QR codes...", text: $searchText)
                                    .font(.custom(FontEnum.interRegular.rawValue, size: 16))
                                    .foregroundColor(Color(hex: "000000"))
                                    .focused($isSearchFieldFocused)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "8E8E93"))
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(hex: "F2F2F7"))
                            .cornerRadius(10)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isSearching = false
                                    searchText = ""
                                    isSearchFieldFocused = false
                                }
                            }) {
                                Text("Cancel")
                                    .font(.custom(FontEnum.interRegular.rawValue, size: 16))
                                    .foregroundColor(Color(hex: "5AC8FA"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    } else {
                        HStack {
                            Text("My QR Codes")
                                .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                                .foregroundColor(Color(hex: "000000"))
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isSearching = true
                                    isSearchFieldFocused = true
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "5A5A5A"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    // Filter Pills
                    if !qrCodesManager.myQRCodes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(QRCodeFilter.allCases, id: \.self) { filter in
                                    FilterPillButton(
                                        title: filter.rawValue,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedFilter = filter
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(.bottom)
                .background(
                    Color(hex: "FFFFFF")
                )
                
                if qrCodesManager.myQRCodes.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color(hex: "E5E7EB"))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "qrcode")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Created QR Codes")
                                .font(.custom(FontEnum.interSemiBold.rawValue, size: 20))
                                .foregroundColor(.black)
                            
                            Text("Create QR codes and save them here\nfor quick access later")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                                .foregroundColor(Color(hex: "5A5A5A"))
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                } else if filteredQRCodes.isEmpty {
                    // No search results
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "B0B0B0"))
                        
                        Text("No Results Found")
                            .font(.custom(FontEnum.interSemiBold.rawValue, size: 20))
                            .foregroundColor(.black)
                        
                        Text("Try searching with different keywords")
                            .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                            .foregroundColor(Color(hex: "5A5A5A"))
                        
                        Spacer()
                    }
                } else {
                    // QR Codes Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(filteredQRCodes) { qrCode in
                                MyQRCodeCard(
                                    qrCode: qrCode,
                                    activeMenuID: $activeMenuID
                                )
                                .onTapGesture {
                                    // Close menu if open
                                    if activeMenuID != nil {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            activeMenuID = nil
                                        }
                                    } else {
                                        selectedQRCode = qrCode
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { _ in
                        // Close menu on scroll
                        if activeMenuID != nil {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                activeMenuID = nil
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedQRCode) { qrCode in
            MyQRCodeDetailSheet(qrCode: qrCode, isPresented: .constant(false))
        }
        .alert("Clear All QR Codes", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                qrCodesManager.clearAll()
            }
        } message: {
            Text("Are you sure you want to delete all created QR codes? This action cannot be undone.")
        }
        .onTapGesture {
            // Close menu on tap outside
            if activeMenuID != nil {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    activeMenuID = nil
                }
            }
        }
    }
    
    private func copyToClipboard(_ content: String) {
        UIPasteboard.general.string = content
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func shareQRCode(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}




#Preview {
    MyQRCodesScreen()
}

