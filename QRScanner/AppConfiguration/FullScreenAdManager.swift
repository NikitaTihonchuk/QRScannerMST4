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
                return
            }

            guard let self = self, let ad = ad else { return }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.isAdReady = true

            print("✅ Interstitial ready")
        }
    }

    func show() {
        guard isAdReady,
              let ad = interstitialAd,
              let root = UIApplication.topViewController()
        else {
            print("⚠️ Cannot show ad")
            return
        }

        ad.present(from: root)
    }

}

extension FullScreenAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        load()
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
