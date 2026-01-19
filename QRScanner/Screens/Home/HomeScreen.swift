import SwiftUI

struct HomeScreen: View {    
    private let buttons = HomeMainButtonStruct.homeMainButton
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    @Binding var selectedTab: Int
    @StateObject private var historyManager = HistoryManager.shared
    @State private var selectedHistoryItem: HistoryItem?
    
    // Get recent 3 items
    var recentItems: [HistoryItem] {
        Array(historyManager.historyItems.prefix(3))
    }
    
    var body: some View {
            ZStack {
                // Background
                Color(hex: "F6F7FA")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Localization.Home.welcome)
                                .font(.custom(FontEnum.interBold.rawValue, size: 32))
                                .foregroundColor(Color(hex: "000000"))
                            
                            Text(Localization.Home.manageSubtitle)
                                .font(.custom("Inter-Regular", size: 17))
                                .foregroundColor(Color(hex: "6C6C70"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Main buttons grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(buttons) { button in
                                HomeButtonCard(button: button, selectedTab: $selectedTab)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Recent Activity Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(Localization.Home.recentActivity)
                                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                                    .foregroundColor(Color(hex: "000000"))
                                
                                Spacer()
                                
                                if !recentItems.isEmpty {
                                    Button(action: {
                                        selectedTab = 3 // Navigate to History tab
                                    }) {
                                        Text(Localization.Home.seeAll)
                                            .font(.custom(FontEnum.interMedium.rawValue, size: 15))
                                            .foregroundColor(Color(hex: "5AC8FA"))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Recent activity list
                            if recentItems.isEmpty {
                                // Empty state
                                VStack(spacing: 12) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(hex: "B0B0B0"))
                                    
                                    Text(Localization.Home.noRecentActivity)
                                        .font(.custom(FontEnum.interMedium.rawValue, size: 16))
                                        .foregroundColor(Color(hex: "5A5A5A"))
                                    
                                    Text(Localization.Home.scanOrCreateQRCodesToSeeThemHere)
                                        .font(.custom(FontEnum.interRegular.rawValue, size: 14))
                                        .foregroundColor(Color(hex: "B0B0B0"))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(recentItems) { item in
                                        RecentActivityRow(
                                            icon: item.actionType == .scanned ? "qrcode.viewfinder" : "plus.circle.fill",
                                            iconColor: item.actionType == .scanned ? Color(hex: "5AC8FA") : Color(hex: "4CAF50"),
                                            title: item.title,
                                            subtitle: formatRelativeTime(item.date)
                                        )
                                        .onTapGesture {
                                            selectedHistoryItem = item
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .sheet(item: $selectedHistoryItem) { item in
                HistoryDetailSheet(item: item, isPresented: .constant(false))
            }
            .navigationBarHidden(true)
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
