import SwiftUI

struct OnboardingPageView: View {
    let screen: OnboardingStruct
    
    var body: some View {
        VStack(spacing: 0) {
            // Image
            Image(screen.image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
                .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 40)
            
            // Subtitle
            Text(screen.subtitleText)
                .font(.custom(FontEnum.interSemiBold.rawValue, size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 20)
            
            // Description (если есть)
            if !screen.subtitleDescriptionText.isEmpty {
                Text(screen.subtitleDescriptionText)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 16))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            }
            
            Spacer()
        }
    }
}
