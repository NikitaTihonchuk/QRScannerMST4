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
            
            // Логируем успешную загрузку
            await MainActor.run {
                AppMetricaManager.shared.logEvent(name: "ad_loaded", parameters: [
                    "ad_type": "app_open"
                ])
            }
        } catch {
            print("---Failed to load AppOpenAd:", error)
            
            // Логируем ошибку загрузки
            await MainActor.run {
                AppMetricaManager.shared.logEvent(name: "ad_load_failed", parameters: [
                    "ad_type": "app_open",
                    "error": error.localizedDescription
                ])
            }
            
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
                
                // Логируем неудачу показа
                AppMetricaManager.shared.logEvent(name: "ad_show_failed", parameters: [
                    "ad_type": "app_open",
                    "reason": "no_root_vc"
                ])
                return
            }

            guard let ad = appOpenAd else { return }

            print("✅ Presenting AppOpenAd")
            isShowingAd = true
            
            // Логируем показ рекламы
            AppMetricaManager.shared.logEvent(name: "ad_shown", parameters: [
                "ad_type": "app_open"
            ])
            
            ad.present(from: rootVC)
        }
    }

}

extension AppOpenAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false
        appOpenAd = nil
        loadTime = nil

        // Логируем закрытие рекламы
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_dismissed", parameters: [
                "ad_type": "app_open"
            ])
        }
        
        Task {
            await self.loadAd()  // Загружаем следующую
        }
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        appOpenAd = nil
        loadTime = nil

        // Логируем ошибку показа
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_present_failed", parameters: [
                "ad_type": "app_open",
                "error": error.localizedDescription
            ])
        }
        
        Task {
            await self.loadAd()
        }
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        // Логируем impression (когда реклама реально показана пользователю)
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_impression", parameters: [
                "ad_type": "app_open"
            ])
        }
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        // Логируем клик по рекламе
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_clicked", parameters: [
                "ad_type": "app_open"
            ])
        }
    }
}

