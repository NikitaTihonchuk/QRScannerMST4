import Foundation

struct AppConfiguration {
    static let main = AppConfiguration()

    let appId: String
    let email: String
    let privacyPolicy: URL
    let termsOfUse: URL

    // AppHud Configuration
    let apphudKey: String
    let paywallID: String

    // AppsFlyer Configuration
    let appsFlyerDevKey: String
    let appleAppID: String

    // ATT Configuration
    let attWaitTimeout: TimeInterval

    init() {
        self.appId = "6749377146"
        self.email = "678687@gmail.com"
        self.privacyPolicy = URL(string: "https://www.google.com")!
        self.termsOfUse = URL(string: "https://www.google.com")!

        // AppHud
        self.apphudKey = "app_ebq9rfssLurrm6oXta3zR7CrGPud54"
        self.paywallID = "inapp_paywall"

        // AppsFlyer
        self.appsFlyerDevKey = "GAgckFyN4yETigBtP4qtRG"
        self.appleAppID = "6749377146"

        // ATT - время ожидания разрешения ATT перед запуском AppsFlyer (рекомендуется 60 секунд)
        self.attWaitTimeout = 60
    }
}
