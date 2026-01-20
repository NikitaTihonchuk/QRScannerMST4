import GoogleMobileAds

final class AppOpenAdManager: NSObject {

    static let shared = AppOpenAdManager()

    private(set) var appOpenAd: AppOpenAd?
    private var isShowingAd = false
    private var loadTime: Date?

    let timeout: TimeInterval = 4 * 3600 // 4 часа

    private override init() {
        super.init()
    }

    func isAdAvailable() -> Bool {
        guard let loadTime = loadTime else { return false }
        return appOpenAd != nil &&
               Date().timeIntervalSince(loadTime) < timeout
    }

    func loadAd() async {
        // Не загружаем, если уже есть свежая реклама
        guard !isAdAvailable() else { return }

        do {
            print("---I want to show an ad")
            appOpenAd = try await AppOpenAd.load(
                with: "ca-app-pub-3940256099942544/9257395921",
                request: Request()
            )
            appOpenAd?.fullScreenContentDelegate = self
            loadTime = Date()
        } catch {
            print("---Failed to load AppOpenAd:", error)
            appOpenAd = nil
            loadTime = nil
        }
    }

    func showAdIfAvailable() async {
        guard !isShowingAd, isAdAvailable() else {
            await loadAd()
            return
        }

        await MainActor.run {
            guard let rootVC = UIApplication.topViewController() else {
                print("❌ No rootViewController yet")
                return
            }

            guard let ad = appOpenAd else { return }

            print("✅ Presenting AppOpenAd")
            isShowingAd = true
            ad.present(from: rootVC)
        }
    }

}

extension AppOpenAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false
        appOpenAd = nil
        loadTime = nil

        Task {
            await self.loadAd()  // Загружаем следующую
        }
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        appOpenAd = nil
        loadTime = nil

        Task {
            await self.loadAd()
        }
    }
}

