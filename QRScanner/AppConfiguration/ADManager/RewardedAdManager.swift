import GoogleMobileAds
import UIKit

@MainActor
final class RewardedAdManager: NSObject {

    static let shared = RewardedAdManager()

    private var rewardedAd: RewardedAd?
    private var isLoading = false

    /// TEST Rewarded Ad Unit ID
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"

    private override init() {
        super.init()
    }

    // MARK: - Public API

    func loadAd() async {
        guard rewardedAd == nil, !isLoading else { return }
        isLoading = true

        do {
            rewardedAd = try await RewardedAd.load(
                with: adUnitID,
                request: Request()
            )
            rewardedAd?.fullScreenContentDelegate = self
            print("✅ RewardedAd loaded")
            
            // Логируем успешную загрузку
            AppMetricaManager.shared.logEvent(name: "ad_loaded", parameters: [
                "ad_type": "rewarded"
            ])
        } catch {
            print("❌ Failed to load RewardedAd:", error)
            
            // Логируем ошибку загрузки
            AppMetricaManager.shared.logEvent(name: "ad_load_failed", parameters: [
                "ad_type": "rewarded",
                "error": error.localizedDescription
            ])
            
            rewardedAd = nil
        }

        isLoading = false
    }

    /// Показывает рекламу и вызывает completion ТОЛЬКО если награда получена
    func showAd(
        onReward: @escaping (_ reward: AdReward) -> Void
    ) {
        guard let ad = rewardedAd else {
            print("⚠️ RewardedAd not ready")
            
            // Логируем неудачу показа
            AppMetricaManager.shared.logEvent(name: "ad_show_failed", parameters: [
                "ad_type": "rewarded",
                "reason": "not_ready"
            ])
            return
        }

        guard let rootVC = UIApplication.topViewController() else {
            print("❌ No rootViewController")
            
            // Логируем неудачу показа
            AppMetricaManager.shared.logEvent(name: "ad_show_failed", parameters: [
                "ad_type": "rewarded",
                "reason": "no_root_vc"
            ])
            return
        }

        // Логируем показ рекламы
        AppMetricaManager.shared.logEvent(name: "ad_shown", parameters: [
            "ad_type": "rewarded"
        ])
        
        ad.present(from: rootVC) { [weak self] in
            guard let self else { return }
            let reward = ad.adReward
            print("🎁 User earned reward:", reward.amount, reward.type)
            
            // Логируем получение награды
            AppMetricaManager.shared.logAdWatched(
                adType: "rewarded",
                reward: "\(reward.amount) \(reward.type)"
            )
            
            onReward(reward)
        }

        rewardedAd = nil
    }
}

extension RewardedAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("ℹ️ RewardedAd dismissed")
        
        // Логируем закрытие рекламы
        AppMetricaManager.shared.logEvent(name: "ad_dismissed", parameters: [
            "ad_type": "rewarded"
        ])
        
        Task {
            await loadAd()
        }
    }

    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("❌ Failed to present RewardedAd:", error)
        
        // Логируем ошибку показа
        AppMetricaManager.shared.logEvent(name: "ad_present_failed", parameters: [
            "ad_type": "rewarded",
            "error": error.localizedDescription
        ])
        
        Task {
            await loadAd()
        }
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        // Логируем impression (когда реклама реально показана пользователю)
        AppMetricaManager.shared.logEvent(name: "ad_impression", parameters: [
            "ad_type": "rewarded"
        ])
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        // Логируем клик по рекламе
        AppMetricaManager.shared.logEvent(name: "ad_clicked", parameters: [
            "ad_type": "rewarded"
        ])
    }
}
