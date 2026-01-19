import SwiftUI

struct PaywallView: View {
    var isOnbording: Bool
    var onboardingAction: () -> Void?
    @ObservedObject private var apphudManager = ApphudManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProductId: String?
    
    private var products: [ProductInformation] {
        apphudManager.products.sorted {
            extractPrice($0.price) < extractPrice($1.price)
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Image("pwBackground")
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            if isOnbording {
                                onboardingAction()
                            } else {
                                dismiss()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(Color(hex: "FFFFFF"))
                                    .shadow(radius: 0.5)
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "000000"))
                                    .frame(width: 32, height: 32)
                                
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            apphudManager.restoreProduct(isOB: false)
                        }) {
                            Text(Localization.Paywall.restore)
                                .font(.custom(FontEnum.interMedium.rawValue, size: 16))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Main QR Code Image
                    Image("qrCodeImagePaywall")
                        .resizable()
                        .frame(width: 320, height: 320)
                        .padding(.top, 20)
                    
                    VStack(spacing: 0) {
                        // Title
                        Text(Localization.Paywall.title)
                            .font(.custom(FontEnum.interBold.rawValue, size: 34))
                            .foregroundColor(Color(hex: "000000"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                        
                        // Subtitle
                        Text(Localization.Paywall.subtitle)
                            .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                            .foregroundColor(Color(hex: "5A5A5A"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .padding(.horizontal, 32)
                        
                        // Features List
                        VStack(spacing: 16) {
                            FeatureRow(
                                icon: "unlimitedQRScansImage",
                                title: Localization.Paywall.unlimitedQRScans,
                                description: Localization.Paywall.unlimitedQRScansDesc
                            )
                            
                            FeatureRow(
                                icon: "createAllQRTypesImage",
                                title: Localization.Paywall.createAllQRTypes,
                                description: Localization.Paywall.createAllQRTypesDesc
                            )
                            
                            FeatureRow(
                                icon: "noAdsImage",
                                title: Localization.Paywall.noAds,
                                description: Localization.Paywall.noAdsDesc
                            )
                            
                            FeatureRow(
                                icon: "cloudBackupImage",
                                title: Localization.Paywall.cloudBackup,
                                description: Localization.Paywall.cloudBackupDesc
                            )
                            
                            FeatureRow(
                                icon: "advancesAnalyticsImage",
                                title: Localization.Paywall.advancedAnalytics,
                                description: Localization.Paywall.advancedAnalyticsDesc
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        
                        // Subscription Plans (Dynamic)
                        VStack(spacing: 16) {
                            ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                                SubscriptionPlanCell(
                                    product: product,
                                    isSelected: selectedProductId == product.id,
                                    planIndex: index,
                                    totalPlans: products.count,
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedProductId = product.id
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        .onAppear {
                            // Auto-select first product if none selected
                            if selectedProductId == nil, let firstProduct = products.first {
                                selectedProductId = firstProduct.id
                            }
                        }
                        
                        // Continue Button
                        Button(action: {
                            guard let productId = selectedProductId else { return }
                            apphudManager.purchase(productId: productId)
                        }) {
                            Text(Localization.Paywall.continueButton)
                                .font(.custom(FontEnum.interSemiBold.rawValue, size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "5AC8FA"), Color(hex: "4A9FE8")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        
                        // Footer Text
                        VStack(spacing: 8) {
                            Text(Localization.Paywall.autoRenewable)
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "8E8E93"))
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    // Open Terms of Service
                                }) {
                                    Text(Localization.Paywall.termsOfService)
                                        .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                        .foregroundColor(Color(hex: "000000"))
                                        .underline()
                                }
                                
                                Text("•")
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                Button(action: {
                                    // Open Privacy Policy
                                }) {
                                    Text(Localization.Paywall.privacyPolicy)
                                        .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                        .foregroundColor(Color(hex: "000000"))
                                        .underline()
                                }
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                    .offset(y: -50)
                }
            }
        }
    }
}

private extension PaywallView {
    
    func extractPrice(_ price: String) -> Double {
        let digits = price
            .replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }
        return Double(digits) ?? 0
    }
}

// MARK: - Subscription Plan Cell
struct SubscriptionPlanCell: View {
    let product: ProductInformation
    let isSelected: Bool
    let planIndex: Int
    let totalPlans: Int
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: topBadgeAlignment) {
            Button(action: onTap) {
                VStack(spacing: 8) {
                    // Plan Title
                    Text(planTitle)
                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 18))
                        .foregroundColor(Color(hex: "000000"))
                    
                    // Price with Period
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(product.price)
                            .font(.custom(FontEnum.interBold.rawValue, size: 28))
                            .foregroundColor(Color(hex: "000000"))
                        
                        Text(periodText)
                            .font(.custom(FontEnum.interRegular.rawValue, size: 16))
                            .foregroundColor(Color(hex: "5A5A5A"))
                    }
                    
                    // Optional: Discount or Trial info
                    if let discountView = discountInfoView {
                        discountView
                    }
                    
                    // Bottom Info Text
                    Text(bottomInfoText)
                        .font(.custom(FontEnum.interRegular.rawValue, size: 14))
                        .foregroundColor(Color(hex: "5A5A5A"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.top, hasTopBadge ? 16 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: isSelected ? Color(hex: "5AC8FA").opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color(hex: "5AC8FA") : Color.clear, lineWidth: 2)
                )
            }
            
            // Badge (if applicable)
            if let badge = badgeView {
                badge
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var planTitle: String {
        switch product.period {
        case "week": return Localization.Paywall.weeklyPlan
        case "month": return Localization.Paywall.monthlyPlan
        case "year": return Localization.Paywall.yearlyPlan
        default: return product.name
        }
    }
    
    private var periodText: String {
        switch product.period {
        case "week": return Localization.Paywall.perWeek
        case "month": return Localization.Paywall.perMonth
        case "year": return Localization.Paywall.perYear
        default: return "/" + product.period
        }
    }
    
    private var bottomInfoText: String {
        if product.hasTrial, let trialDuration = product.trialDuration {
            return formatTrialText(trialDuration)
        } else if product.period == "year" {
            return Localization.Paywall.bestValueOption
        } else {
            return Localization.Paywall.cancelAnytime
        }
    }
    
    private var discountInfoView: AnyView? {
        // Show discount for yearly plan (assumed to be most expensive)
        guard product.period == "year" else { return nil }
        
        return AnyView(
            HStack(spacing: 8) {
                Text("$99.99")
                    .font(.custom(FontEnum.interRegular.rawValue, size: 14))
                    .foregroundColor(Color(hex: "B0B0B0"))
                    .strikethrough()
                
                Text(Localization.Paywall.saveAmount)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 14))
                    .foregroundColor(Color(hex: "34C759"))
            }
        )
    }
    
    // MARK: - Badge Logic
    
    private var hasTopBadge: Bool {
        return planIndex == 0 // First item gets "Most Popular"
    }
    
    private var topBadgeAlignment: Alignment {
        if planIndex == 0 {
            return .top
        } else if product.period == "year" {
            return .topTrailing
        }
        return .top
    }
    
    private var badgeView: AnyView? {
        if planIndex == 0 {
            // Most Popular Badge (first product)
            return AnyView(
                Text(Localization.Paywall.mostPopular)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(hex: "5AC8FA")))
                    .offset(y: -12)
            )
        } else if product.period == "year" {
            // Save Badge for yearly
            return AnyView(
                Text(Localization.Paywall.savePercent)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(hex: "34C759")))
                    .offset(x: -12, y: -12)
            )
        }
        return nil
    }
    
    // MARK: - Helper Methods
    
    private func formatTrialText(_ trialDuration: String) -> String {
        // Format: "3-day" or "7-day"
        let components = trialDuration.split(separator: "-")
        guard components.count == 2,
              let number = components.first,
              let unit = components.last else {
            return Localization.Paywall.freeTrialDays
        }
        
        return Localization.Paywall.freeTrialDays
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(Color(hex: "000000"))
                
                Text(description)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 14))
                    .foregroundColor(Color(hex: "5A5A5A"))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FFFFFF"))
        )
        .shadow(radius: 0.5)
    }
}


