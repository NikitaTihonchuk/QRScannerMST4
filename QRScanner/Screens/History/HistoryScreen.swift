import SwiftUI

struct HistoryScreen: View {
    @StateObject private var historyManager = HistoryManager.shared
    @State private var selectedFilter: HistoryFilter = .all
    @State private var selectedItem: HistoryItem?
    @State private var sortOrder: SortOrder = .newestFirst
    @State private var showSortMenu = false
    
    enum HistoryFilter: String, CaseIterable {
        case all = "All"
        case scanned = "Scanned"
        case created = "Created"
    }
    
    enum SortOrder: String, CaseIterable {
        case newestFirst = "Newest First"
        case oldestFirst = "Oldest First"
        
        var icon: String {
            switch self {
            case .newestFirst: return "arrow.down"
            case .oldestFirst: return "arrow.up"
            }
        }
    }
    
    var filteredItems: [HistoryItem] {
        var items: [HistoryItem]
        
        switch selectedFilter {
        case .all:
            items = historyManager.historyItems
        case .scanned:
            items = historyManager.historyItems.filter { $0.actionType == .scanned }
        case .created:
            items = historyManager.historyItems.filter { $0.actionType == .created }
        }
        
        // Apply sorting
        switch sortOrder {
        case .newestFirst:
            return items.sorted { $0.date > $1.date }
        case .oldestFirst:
            return items.sorted { $0.date < $1.date }
        }
    }
    
    var groupedItems: [String: [HistoryItem]] {
        Dictionary(grouping: filteredItems) { item in
            if Calendar.current.isDateInToday(item.date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(item.date) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d, yyyy"
                return formatter.string(from: item.date)
            }
        }
    }
    
    var sortedSections: [String] {
        let sections = groupedItems.keys.sorted { first, second in
            // Priority for "Today" and "Yesterday"
            if first == "Today" { return sortOrder == .newestFirst }
            if second == "Today" { return sortOrder == .oldestFirst }
            if first == "Yesterday" && second != "Today" { return sortOrder == .newestFirst }
            if second == "Yesterday" && first != "Today" { return sortOrder == .oldestFirst }
            
            // Sort other dates
            switch sortOrder {
            case .newestFirst:
                return first > second
            case .oldestFirst:
                return first < second
            }
        }
        return sections
    }
    
    // Helper function to sort items within a section
    func sortedItemsForSection(_ section: String) -> [HistoryItem] {
        let items = groupedItems[section] ?? []
        switch sortOrder {
        case .newestFirst:
            return items.sorted { $0.date > $1.date }
        case .oldestFirst:
            return items.sorted { $0.date < $1.date }
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F6F7FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                VStack(spacing: 0) {
                    HStack {
                        Text("History")
                            .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {
                            showSortMenu = true
                        }) {
                            Image("filterButton")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .confirmationDialog("Sort by", isPresented: $showSortMenu, titleVisibility: .visible) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button(order.rawValue) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    sortOrder = order
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(HistoryFilter.allCases, id: \.self) { filter in
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
                .padding(.bottom)
                .background(
                    Color(hex: "FFFFFF")
                        .ignoresSafeArea()
                )
                // History List
                if filteredItems.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color(hex: "E5E7EB"))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                        
                        VStack(spacing: 8) {
                            Text("No History Yet")
                                .font(.custom(FontEnum.interSemiBold.rawValue, size: 20))
                                .foregroundColor(.black)
                            
                            Text("Your scanned and created QR codes\nwill appear here")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                                .foregroundColor(Color(hex: "5A5A5A"))
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(sortedSections, id: \.self) { section in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Section Header
                                    Text(section)
                                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 18))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 20)
                                    
                                    // Section Items
                                    VStack(spacing: 12) {
                                        ForEach(sortedItemsForSection(section)) { item in
                                            HistoryItemCard(item: item)
                                                .onTapGesture {
                                                    selectedItem = item
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 140)
                    }
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            HistoryDetailSheet(item: item, isPresented: Binding(
                get: { selectedItem != nil },
                set: { if !$0 { selectedItem = nil } }
            ))
        }
    }
}

#Preview {
    HistoryScreen()
}
