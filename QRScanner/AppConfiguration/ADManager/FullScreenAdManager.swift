import GoogleMobileAds
import Combine

final class FullScreenAdManager: NSObject, ObservableObject {

    @Published private(set) var isAdReady = false

    private var interstitialAd: InterstitialAd?
    private let adUnitID = "ca-app-pub-3940256099942544/1033173712"

    override init() {
        super.init()
        load()
    }

    func load() {
        isAdReady = false

        InterstitialAd.load(
            with: adUnitID,
            request: Request()
        ) { [weak self] ad, error in

            if let error = error {
                print("❌ Interstitial load error:", error)
                
                // Логируем ошибку загрузки
                Task { @MainActor in
                    AppMetricaManager.shared.logEvent(name: "ad_load_failed", parameters: [
                        "ad_type": "interstitial",
                        "error": error.localizedDescription
                    ])
                }
                return
            }

            guard let self = self, let ad = ad else { return }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.isAdReady = true

            print("✅ Interstitial ready")
            
            // Логируем успешную загрузку
            Task { @MainActor in
                AppMetricaManager.shared.logEvent(name: "ad_loaded", parameters: [
                    "ad_type": "interstitial"
                ])
            }
        }
    }

    func show() {
        guard isAdReady,
              let ad = interstitialAd,
              let root = UIApplication.topViewController()
        else {
            print("⚠️ Cannot show ad")
            
            // Логируем неудачу показа
            Task { @MainActor in
                AppMetricaManager.shared.logEvent(name: "ad_show_failed", parameters: [
                    "ad_type": "interstitial",
                    "reason": !isAdReady ? "not_ready" : "no_root_vc"
                ])
            }
            return
        }

        ad.present(from: root)
        
        // Логируем показ рекламы
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_shown", parameters: [
                "ad_type": "interstitial"
            ])
        }
    }

}

extension FullScreenAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // Логируем закрытие рекламы
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_dismissed", parameters: [
                "ad_type": "interstitial"
            ])
        }
        
        interstitialAd = nil
        load()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        // Логируем ошибку показа
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_present_failed", parameters: [
                "ad_type": "interstitial",
                "error": error.localizedDescription
            ])
        }
        
        interstitialAd = nil
        load()
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        // Логируем impression (когда реклама реально показана пользователю)
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_impression", parameters: [
                "ad_type": "interstitial"
            ])
        }
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        // Логируем клик по рекламе
        Task { @MainActor in
            AppMetricaManager.shared.logEvent(name: "ad_clicked", parameters: [
                "ad_type": "interstitial"
            ])
        }
    }
}

extension UIApplication {

    static func topViewController(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController,
           let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}
