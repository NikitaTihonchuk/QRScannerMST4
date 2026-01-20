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
        } catch {
            print("❌ Failed to load RewardedAd:", error)
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
            return
        }

        guard let rootVC = UIApplication.topViewController() else {
            print("❌ No rootViewController")
            return
        }

        ad.present(from: rootVC) { [weak self] in
            guard let self else { return }
            let reward = ad.adReward
            print("🎁 User earned reward:", reward.amount, reward.type)
            onReward(reward)
        }

        rewardedAd = nil
    }
}

extension RewardedAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("ℹ️ RewardedAd dismissed")
        Task {
            await loadAd()
        }
    }

    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("❌ Failed to present RewardedAd:", error)
        Task {
            await loadAd()
        }
    }
}
