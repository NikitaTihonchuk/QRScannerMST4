import SwiftUI

struct OnboardingStruct: Identifiable {
    var id: Int
    var titleText: String
    var subtitleText: String
    var subtitleDescriptionText: String
    var image: String
    
    static let obScreens: [OnboardingStruct] = [
        OnboardingStruct(
            id: 1,
            titleText: Localization.Onboarding.welcome,
            subtitleText: Localization.Onboarding.welcomeSubtitle,
            subtitleDescriptionText: "",
            image: "onboarding1Image"
        ),
        OnboardingStruct(
            id: 2,
            titleText: Localization.Onboarding.scanTitle,
            subtitleText: Localization.Onboarding.scanSubtitle,
            subtitleDescriptionText: Localization.Onboarding.scanDescription,
            image: "onboarding2Image"
        ),
        OnboardingStruct(
            id: 3,
            titleText: Localization.Onboarding.createTitle,
            subtitleText: Localization.Onboarding.createSubtitle,
            subtitleDescriptionText: Localization.Onboarding.createDescription,
            image: "onboarding3Image"
        ),
        OnboardingStruct(
            id: 4,
            titleText: Localization.Onboarding.manageTitle,
            subtitleText: Localization.Onboarding.manageSubtitle,
            subtitleDescriptionText: Localization.Onboarding.manageDescription,
            image: "onboarding4Image"
        )
    ]
}
