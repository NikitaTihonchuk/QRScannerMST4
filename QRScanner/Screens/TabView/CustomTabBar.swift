import SwiftUI


struct CustomTabBar: View {
    @Binding var selectedTab: Int
    private let tabs = TabViewStruct.tabs
    
    var body: some View {
        ZStack {
            // Tab Bar с вырезом
            TabBarShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
                .frame(height: 92)
            
            HStack(spacing: 0) {
                // Первые два таба (Home, Scan QR)
                ForEach(0..<2) { index in
                    TabBarItem(
                        tab: tabs[index],
                        isSelected: selectedTab == index,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                            }
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    )
                }
                
                // Пустое место для центральной кнопки
                Spacer()
                    .frame(width: 80)
                
                // Последние два таба (My QR Codes, History)
                ForEach(2..<4) { index in
                    TabBarItem(
                        tab: tabs[index],
                        isSelected: selectedTab == index,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                            }
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .frame(height: 84)
            
            // Центральная кнопка Create поверх TabBar
            CentralCreateButton()
                .offset(y: -45) // Поднимаем кнопку вверх
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 4
                    }
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
        }
        .frame(height: 84)
    }
}
