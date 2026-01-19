import StoreKit
import AdServices
import Combine
import ApphudSDK
import iAd

final class ApphudManager: ObservableObject {
    
    static let shared = ApphudManager()
    
    @Published var onboarding_close_delay: Double?
    @Published var paywall_close_delay: Double?
    @Published var onboarding_button_title: String?
    @Published var is_review_enabled: Bool = true
    @Published var onboarding_subtitle_alpha: Double = 1
    @Published var paywall_button_title: String?
    
    @Published var isOnboardingTrial: Bool = false
    @Published var isPaywallTrial: Bool = false
    
    @Published var onboardingPrice: String = "-//-"
    @Published var paywallPrice: String = "-//-"
    @Published var onboardingPeriod: String = "week"
    @Published var paywallPeriod: String = "week"
    @Published var onboardingTrialDuration: String = "-"
    @Published var paywallTrialDuration: String = "-"
    @Published var paywallPriceWithTrial: String = "-//-"
    @Published var paywallPeriodWithTrial: String = "week"
    @Published var paywallPriceNoTrial: String = "-//-"
    @Published var paywallPeriodNoTrial: String = "week"
    
    @Published var result: ResultType?
    @Published var errorOnboardingNetworkAlert: Bool = false
    @Published var errorPaywallNetworkAlert: Bool = false
    @Published var showPaywallErrorAlert = false
    private var paywallWeekProductWithTrial: ApphudProduct?
    private var paywallWeekProductNoTrial: ApphudProduct?
    
    private var onboardingProduct: ApphudProduct?
    private var paywallProduct: ApphudProduct?
    
    @Published var apphudProducts: [ApphudProduct] = []
    @Published var products: [ProductInformation] = []

    
    private init() {
        
        Task {
            await getProduct(.paywall)
        }
        
        addAttribution(typeOfAttribution: .appleAdsAttribution)
    }
    
    var hasPremium: Bool {
        Apphud.hasActiveSubscription()
        //true
    }
    
    private func getProduct(_ product: ProdType) async {
        guard let paywall = await Apphud.paywall(product.rawValue) else { return }
        
        await MainActor.run {
           
            savePaywallProducts(paywall)
            savePaywallInfo(paywall)
            
            
            getTrial(paywall.products.first) { result in
                do {
                    let hasTrial = try result.get()
                    self.isPaywallTrial = hasTrial
                } catch {
                    self.isPaywallTrial = false
                }
            }
        }
    }
    
    
//    private func savePaywallInfo(_ paywall: ApphudPaywall) {
//        let paywallProducts = paywall.products
//        apphudProducts = paywallProducts
//        for product in paywallProducts {
//           
//            Task {
//                let price = (try? await product.product()?.displayPrice) ?? "-//-"
//                let period = await getSubscriptionPeriod(try? await product.product())
//                print("---product \(product), price: \(price), period: \(period)")
//                DispatchQueue.main.async {
//                    self.paywallPrice = price
//                    self.paywallPeriod = period
//                    self.objectWillChange.send()
//                }
//            }
//        }
//    }
     
    private func savePaywallInfo(_ paywall: ApphudPaywall) {
        Task {
            var result: [ProductInformation] = []

            for apphudProduct in paywall.products {
                guard let storeProduct = try? await apphudProduct.product() else { continue }

                let price = storeProduct.displayPrice
                let period = await getSubscriptionPeriod(storeProduct)
                let hasTrial = storeProduct.subscription?.introductoryOffer != nil
                let trialDuration = hasTrial ? trialCode(for: apphudProduct) : nil

                let info = ProductInformation(
                    id: apphudProduct.productId,
                    name: storeProduct.displayName,
                    period: period,
                    price: price,
                    hasTrial: hasTrial,
                    trialDuration: trialDuration
                )

                result.append(info)
            }

            await MainActor.run {
                self.products = result
            }
        }
    }
    
    func purchase(productId: String) {
        print("---productId: \(productId)")
        guard let product = apphudProducts.first(where: { $0.productId == productId }) else {
            for product in apphudProducts {
                print("---productId: \(product.productId)" )
            }
            return
        }

        Task {
            let result = await Apphud.purchase(product)

            await MainActor.run {
                if result.success {
                    self.result = .purchasePaywallSuccess
                } else {
                    self.result = .purchasePaywallError
                    self.showPaywallErrorAlert = true
                }
            }
        }
    }


   
    
    private func getSubscriptionPeriod(_ product: Product?) async -> String {
        guard let product = product else { return "week" }
        
        if let subscriptionInfo = product.subscription {
            let period = subscriptionInfo.subscriptionPeriod
            
            switch period.unit {
            case .day:
                return period.value == 7 ? "week" : (period.value == 1 ? "day" : "days")
            case .week:
                return period.value == 1 ? "week" : "weeks"
            case .month:
                return period.value == 1 ? "month" : "months"
            case .year:
                return period.value == 1 ? "year" : "years"
            @unknown default:
                return "week"
            }
        }
        
        return "week"
    }
    
    private func getTrial(_ product: ApphudProduct?, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let skProduct = product?.skProduct else {
            completion(.failure(NSError(domain: "", code: 0)))
            return
        }
        Apphud.checkEligibilityForIntroductoryOffer(product: skProduct, callback: { bool in
            completion(.success(bool))
        })
    }
    
    private func trialCode(for product: ApphudProduct?) -> String {
        guard let skProduct = product?.skProduct,
              let introPrice = skProduct.introductoryPrice else {
            return "-"
        }
        
        let period = introPrice.subscriptionPeriod
        let unit: String
        
        switch period.unit {
        case .day: unit = period.numberOfUnits == 1 ? "day" : "day"
        case .week: unit = period.numberOfUnits == 1 ? "week" : "week"
        case .month: unit = period.numberOfUnits == 1 ? "month" : "month"
        case .year: unit = period.numberOfUnits == 1 ? "year" : "year"
        @unknown default: unit = "day"
        }
        
        return "\(period.numberOfUnits)-\(unit)"
    }
    
    
    private func savePaywallProducts(_ paywall: ApphudPaywall) {
        apphudProducts = paywall.products

        for product in paywall.products {
            if let skProduct = product.skProduct, skProduct.introductoryPrice != nil {
                paywallWeekProductWithTrial = product
                paywallTrialDuration = trialCode(for: product)
                
                Task {
                    let price = (try? await product.product()?.displayPrice) ?? "-//-"
                    let period = await getSubscriptionPeriod(try? await product.product())
                    DispatchQueue.main.async {
                        self.paywallPriceWithTrial = price
                        self.paywallPeriodWithTrial = period
                    }
                }
            } else {
                paywallWeekProductNoTrial = product
                
                Task {
                    let price = (try? await product.product()?.displayPrice) ?? "-//-"
                    let period = await getSubscriptionPeriod(try? await product.product())
                    DispatchQueue.main.async {
                        self.paywallPriceNoTrial = price
                        self.paywallPeriodNoTrial = period
                    }
                }
            }
        }
        
        if paywallWeekProductWithTrial == nil {
            paywallTrialDuration = "-"
        }
    }
    
    
    
    private func getApphudProduct(prod: ProdPeriodType, isTrial: Bool) -> ApphudProduct? {
        switch prod {
        case .week:
            return isTrial ? paywallWeekProductWithTrial : paywallWeekProductNoTrial
        case .onboarding:
            return onboardingProduct
        }
    }
    
    func purchaseProduct(prod: ProdPeriodType, isTrial: Bool) {
        guard let product = getApphudProduct(prod: prod, isTrial: isTrial) else { return }
        Task {
            let result = await Apphud.purchase(product)
            DispatchQueue.main.async {
                if result.success {
                    self.result = .purchasePaywallSuccess
                } else {
                    self.result = .purchasePaywallError
                    self.showErrorAlert(isPurchase: true)
                    self.showPaywallErrorAlert = true
                }
            }
        }
    }
    
    func restoreProduct(isOB: Bool) {
        Task {
            await Apphud.restorePurchases { subscriptions, purchases, error in
                DispatchQueue.main.async {
                    if Apphud.hasActiveSubscription() {
                        self.result = isOB ? .restoreOBSuccess : .restorePaywallSuccess
                    } else {
                        self.result = isOB ? .restoreOBError : .restorePaywallError
                        self.showErrorAlert(isPurchase: false)
                        self.showPaywallErrorAlert = true
                    }
                }
            }
        }
    }
    
    private func addAttribution(typeOfAttribution: ApphudAttributionProvider) {
        if #available(iOS 14.3, *) {
            DispatchQueue.global(qos: .default).async {
                if let token = try? AAAttribution.attributionToken() {
                    DispatchQueue.main.async {
                        Apphud.addAttribution(data: nil, from: typeOfAttribution, identifer: token, callback: nil)
                    }
                }
            }
        } else {
            ADClient.shared().requestAttributionDetails { data, _ in
                data.map { Apphud.addAttribution(data: $0, from: typeOfAttribution, callback: nil) }
            }
        }
    }
    
    private func showErrorAlert(isPurchase: Bool) {
        if isPurchase {
            self.result = .purchasePaywallError
        } else {
            self.result = .restorePaywallError
        }
    }
    
    func cleanResult() {
        result = nil
        showPaywallErrorAlert = false
    }
}

struct ProductInformation: Identifiable {
    let id: String
    let name: String
    let period: String
    let price: String
    let hasTrial: Bool
    let trialDuration: String?
}


enum ProdType: String {
    case paywall = "main_paywall"
}

enum ProdPeriodType {
    case onboarding
    case week
}

enum ResultType {
    case purchaseOBSuccess
    case restoreOBSuccess
    case purchasePaywallSuccess
    case restorePaywallSuccess
    case purchaseOBError
    case restoreOBError
    case purchasePaywallError
    case restorePaywallError
}
