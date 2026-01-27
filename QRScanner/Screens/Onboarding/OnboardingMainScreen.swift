import SwiftUI

struct OnboardingMainScreen: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let screens = OnboardingStruct.obScreens
    @State var showPaywall: Bool = false
    var body: some View {
        onboardingContent
    }
    
    private var onboardingContent: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "FFFFFF"),
                    Color(hex: "E8F7FF")
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // Title
                Text(getTitleForPage(currentPage))
                    .font(.custom(FontEnum.interBold.rawValue, size: 36))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                    .frame(height: 40)
                
                // TabView для свайпа между экранами
                TabView(selection: $currentPage) {
                    ForEach(screens) { screen in
                        OnboardingPageView(screen: screen)
                            .tag(screen.id - 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                    .frame(height: 20)
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<screens.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color(hex: "4DB3FF") : Color(hex: "D9D9D9"))
                            .frame(width: currentPage == index ? 32 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Next/Get Started button
                Button(action: {
                    if currentPage < screens.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        showPaywall = true
                    }
                }) {
                    Text(currentPage == screens.count - 1 ? Localization.Onboarding.getStarted : Localization.Onboarding.next)
                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "4DB3FF"))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Skip button
                Button(action: {
                    showPaywall = true
                }) {
                    Text(Localization.Onboarding.skip)
                        .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .padding(.bottom, 40)
            }
            
            if showPaywall {
                PaywallView(isOnbording: true, onboardingAction: {
                    completeOnboarding()
                })
            }
        }
    }
    
    private func getTitleForPage(_ page: Int) -> String {
        guard page < screens.count else { return "" }
        return screens[page].titleText
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}


#Preview {
    OnboardingMainScreen()
}

