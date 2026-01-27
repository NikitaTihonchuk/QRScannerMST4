import Foundation
import Foundation
import AppMetricaCore
import Combine

class AppMetricaManager: NSObject, ObservableObject {
    static let shared = AppMetricaManager()
    
    // Published properties для отслеживания статуса
    @Published var isInitialized = false
    @Published var appMetricaDeviceID: String?
    
    private override init() {
        super.init()
    }
    
    /// Инициализация AppMetrica SDK
    func initialize() {
        // Защита от повторной инициализации
        guard !isInitialized else {
            print("⚠️ AppMetrica уже инициализирован, пропускаем повторную инициализацию")
            return
        }
        
        guard let configuration = AppMetricaConfiguration(apiKey: AppConfiguration.main.appMetricaAPIKey) else {
            print("❌ AppMetrica: Не удалось создать конфигурацию")
            return
        }
        
        // Настройка дополнительных параметров
        configuration.locationTracking = true // Отключаем отслеживание геолокации
        configuration.sessionsAutoTracking = true // Автоматическое отслеживание сессий
        
        #if DEBUG
        configuration.areLogsEnabled = false // Включаем логи для отладки
        #else
        configuration.areLogsEnabled = false
        #endif
        
        AppMetrica.activate(with: configuration)
        
        // Обновляем UI-свойства в главном потоке
        DispatchQueue.main.async { [weak self] in
            self?.isInitialized = true
            self?.appMetricaDeviceID = AppMetrica.deviceID
            
            print("✅ AppMetrica SDK инициализирован")
            print("   API Key: \(AppConfiguration.main.appMetricaAPIKey)")
            print("   Device ID: \(self?.appMetricaDeviceID ?? "unknown")")
        }
    }
    
    /// Отправка атрибуции из AppsFlyer в AppMetrica
    func sendAppsFlyerAttribution(_ data: [AnyHashable: Any]) {
        guard isInitialized else {
            print("⚠️ AppMetrica не инициализирован")
            return
        }
        
        AppMetrica.reportExternalAttribution(data, from: .appsflyer)
        print("✅ AppMetrica: AppsFlyer attribution отправлена")
    }
    
    // MARK: - Event Logging
    
    /// Логирование события в AppMetrica
    func logEvent(name: String, parameters: [String: Any]? = nil) {
        guard isInitialized else {
            print("⚠️ AppMetrica не инициализирован. Событие '\(name)' не отправлено.")
            return
        }
        
        AppMetrica.reportEvent(name: name, parameters: parameters, onFailure: { error in
            print("❌ AppMetrica Event Error: \(error.localizedDescription)")
        })
        
        print("📊 AppMetrica Event: \(name)")
        if let parameters = parameters {
            print("   Parameters: \(parameters)")
        }
    }
    
    /// Стандартные события для подписок
    func logSubscriptionEvent(productId: String, price: String, currency: String) {
        logEvent(name: "subscription_purchased", parameters: [
            "product_id": productId,
            "price": price,
            "currency": currency
        ])
    }
    
    /// Событие начала trial периода
    func logTrialStarted(productId: String) {
        logEvent(name: "trial_started", parameters: [
            "product_id": productId
        ])
    }
    
    /// Событие открытия paywall
    func logPaywallOpened(paywallId: String) {
        logEvent(name: "paywall_opened", parameters: [
            "paywall_id": paywallId
        ])
    }
    
    /// Событие закрытия paywall
    func logPaywallClosed(paywallId: String, purchased: Bool) {
        logEvent(name: "paywall_closed", parameters: [
            "paywall_id": paywallId,
            "purchased": purchased
        ])
    }
    
    /// Событие сканирования QR кода
    func logQRCodeScanned(type: String, isPremium: Bool) {
        logEvent(name: "qr_scanned", parameters: [
            "qr_type": type,
            "is_premium": isPremium
        ])
    }
    
    /// Событие успешного сканирования QR кода
    func logQRScanSuccess(type: String, source: String, isPremium: Bool, remainingScans: Int?) {
        var params: [String: Any] = [
            "qr_type": type,
            "scan_source": source, // "camera" или "gallery"
            "is_premium": isPremium
        ]
        
        if let remaining = remainingScans {
            params["remaining_scans"] = remaining
        }
        
        logEvent(name: "qr_scan_success", parameters: params)
    }
    
    /// Событие сканирования с камеры
    func logQRScanFromCamera(type: String, isPremium: Bool) {
        logEvent(name: "qr_scan_from_camera", parameters: [
            "qr_type": type,
            "is_premium": isPremium
        ])
    }
    
    /// Событие сканирования из галереи
    func logQRScanFromGallery(type: String, isPremium: Bool, multipleDetected: Bool) {
        logEvent(name: "qr_scan_from_gallery", parameters: [
            "qr_type": type,
            "is_premium": isPremium,
            "multiple_detected": multipleDetected
        ])
    }
    
    /// Событие обнаружения нескольких QR-кодов
    func logMultipleQRCodesDetected(count: Int, isPremium: Bool) {
        logEvent(name: "qr_scan_multiple_detected", parameters: [
            "qr_count": count,
            "is_premium": isPremium
        ])
    }
    
    /// Событие неудачного сканирования (QR не найден)
    func logQRScanFailed(source: String, isPremium: Bool) {
        logEvent(name: "qr_scan_failed", parameters: [
            "scan_source": source,
            "is_premium": isPremium
        ])
    }
    
    /// Событие создания QR кода
    func logQRCodeCreated(type: String) {
        logEvent(name: "qr_created", parameters: [
            "qr_type": type
        ])
    }
    
    /// Событие достижения лимита сканирований
    func logScanLimitReached() {
        logEvent(name: "scan_limit_reached")
    }
    
    /// Событие просмотра рекламы
    func logAdWatched(adType: String, reward: String? = nil) {
        var params: [String: Any] = ["ad_type": adType]
        if let reward = reward {
            params["reward"] = reward
        }
        logEvent(name: "ad_watched", parameters: params)
    }
    
    /// Событие открытия экрана сканирования
    func logScanScreenOpened(isPremium: Bool, remainingScans: Int?) {
        var params: [String: Any] = ["is_premium": isPremium]
        if let remaining = remainingScans {
            params["remaining_scans"] = remaining
        }
        logEvent(name: "scan_screen_opened", parameters: params)
    }
    
    /// Событие использования вспышки
    func logFlashToggled(enabled: Bool, isPremium: Bool) {
        logEvent(name: "flash_toggled", parameters: [
            "enabled": enabled,
            "is_premium": isPremium
        ])
    }
    
    /// Событие переключения камеры
    func logCameraSwitched(position: String, isPremium: Bool) {
        logEvent(name: "camera_switched", parameters: [
            "camera_position": position, // "front" или "back"
            "is_premium": isPremium
        ])
    }
    
    /// Событие открытия галереи
    func logGalleryOpened(isPremium: Bool) {
        logEvent(name: "gallery_opened", parameters: [
            "is_premium": isPremium
        ])
    }
    
    /// Событие показа предупреждения о последнем бесплатном скане
    func logLastScanWarningShown(isPremium: Bool) {
        logEvent(name: "last_scan_warning_shown", parameters: [
            "is_premium": isPremium
        ])
    }
    
    /// Событие клика на "Get Unlimited" в предупреждении
    func logLastScanWarningUpgradeClicked() {
        logEvent(name: "last_scan_warning_upgrade_clicked")
    }
    
    /// Событие показа paywall из-за достижения лимита
    func logPaywallShownFromScanLimit() {
        logEvent(name: "paywall_shown_from_scan_limit")
    }
    
    // MARK: - User Properties
    
    /// Установка свойств пользователя
    func setUserProperty(key: String, value: String) {
        guard isInitialized else { return }
        
        let profile = MutableUserProfile()
        let attribute = ProfileAttribute.customString(key).withValue(value)
        profile.apply(attribute)
        
        AppMetrica.reportUserProfile(profile, onFailure: { error in
            print("❌ AppMetrica User Property Error: \(error.localizedDescription)")
        })
        
        print("👤 AppMetrica User Property: \(key) = \(value)")
    }
    
    /// Установка премиум статуса пользователя
    func setPremiumStatus(_ hasPremium: Bool) {
        setUserProperty(key: "premium_status", value: hasPremium ? "premium" : "free")
    }
    
    // MARK: - Revenue Tracking
    
    /// Отслеживание покупки (Revenue)
    func logRevenue(productId: String, price: Decimal, currency: String, quantity: Int = 1) {
        guard isInitialized else { return }
        
        let revenueInfo = MutableRevenueInfo(
            priceDecimal: price as NSDecimalNumber,
            currency: currency
        )
        revenueInfo.productID = productId
        revenueInfo.quantity = UInt(quantity)
        
        AppMetrica.reportRevenue(revenueInfo, onFailure: { error in
            print("❌ AppMetrica Revenue Error: \(error.localizedDescription)")
        })
        
        print("💰 AppMetrica Revenue: \(price) \(currency) - \(productId)")
    }
}
