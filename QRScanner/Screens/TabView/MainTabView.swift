import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var previousTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    HomeScreen(selectedTab: $selectedTab)
                case 1:
                    ScanQRScreenNew()
                case 2:
                    MyQRCodesScreen()
                case 3:
                    HistoryScreen()
                case 4:
                    AddNewQR {
                        // При закрытии возвращаемся на предыдущую вкладку
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = previousTab
                        }
                    }
                    .onAppear {
                        // Сохраняем предыдущую вкладку при открытии AddNewQR
                        if selectedTab == 4 && previousTab == 4 {
                           // previousTab = 0
                        }
                    }
                default:
                    HomeScreen(selectedTab: $selectedTab)
                }
            }
            
            // Custom Tab Bar with cutout
            CustomTabBar(selectedTab: $selectedTab)
                .onChange(of: selectedTab) { oldValue, newValue in
                    // Сохраняем предыдущую вкладку, если переходим не на AddNewQR
                    if newValue != 4 {
                        previousTab = newValue
                    } else if oldValue != 4 {
                        previousTab = oldValue
                    }
                }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    MainTabView()
}
