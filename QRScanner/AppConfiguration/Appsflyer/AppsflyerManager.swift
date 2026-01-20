import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport
import Combine

@MainActor
class AppsFlyerManager: NSObject, ObservableObject {
    static let shared = AppsFlyerManager()

    // Published properties для отслеживания статуса
    @Published var isInitialized = false
    @Published var attStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    @Published var conversionData: [AnyHashable: Any]?
    @Published var appsFlyerUID: String?

    private override init() {
        super.init()
    }

    /// Инициализация AppsFlyer SDK
    /// Должна быть вызвана после получения разрешения ATT
    func initialize() {
        // Настройка AppsFlyer
        AppsFlyerLib.shared().appsFlyerDevKey = AppConfiguration.main.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = AppConfiguration.main.appleAppID

        // Устанавливаем delegate для получения conversion data
        AppsFlyerLib.shared().delegate = self

        // Включаем debug режим для разработки (отключите в продакшене!)
        #if DEBUG
        AppsFlyerLib.shared().isDebug = false
        #endif

        // Ждем разрешение ATT перед запуском SDK
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: AppConfiguration.main.attWaitTimeout)

        // Включаем сбор IDFA (если пользователь дал разрешение)
        // IDFA будет передан автоматически если есть разрешение ATT

        isInitialized = true
        print("✅ AppsFlyer SDK инициализирован")
        print("   Dev Key: \(AppConfiguration.main.appsFlyerDevKey)")
        print("   Apple App ID: \(AppConfiguration.main.appleAppID)")
        print("   ATT Timeout: \(AppConfiguration.main.attWaitTimeout)s")
    }

    /// Запуск AppsFlyer SDK
    /// Вызывается когда приложение становится активным
    func start() {
        guard isInitialized else {
            print("⚠️ AppsFlyer не инициализирован. Вызовите initialize() сначала.")
            return
        }

        AppsFlyerLib.shared().start()
        print("✅ AppsFlyer SDK запущен")

        // Получаем AppsFlyer UID
        let uid = AppsFlyerLib.shared().getAppsFlyerUID()
        self.appsFlyerUID = uid
        print("   AppsFlyer UID: \(uid)")
    }

    /// Запрос разрешения ATT
    /// Должен быть вызван перед инициализацией AppsFlyer
    func requestATTPermission() async -> ATTrackingManager.AuthorizationStatus {
        print("📱 Запрос разрешения ATT...")
        
        // Проверяем текущий статус
        let currentStatus = ATTrackingManager.trackingAuthorizationStatus
        print("   Текущий статус ATT: \(currentStatus.description)")

        // Если уже определен, возвращаем текущий статус
        if currentStatus != .notDetermined {
            self.attStatus = currentStatus
            handleATTStatus(currentStatus)
            return currentStatus
        }

        // Запрашиваем разрешение (покажет системный alert)
        print("   Показываем системный запрос ATT...")
        let status = await ATTrackingManager.requestTrackingAuthorization()
        self.attStatus = status
        handleATTStatus(status)

        return status
    }

    /// Обработка статуса ATT
    private func handleATTStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            print("✅ ATT: Разрешено (authorized)")
            print("   IDFA: \(ASIdentifierManager.shared().advertisingIdentifier.uuidString)")

        case .denied:
            print("❌ ATT: Отклонено (denied)")

        case .restricted:
            print("⚠️ ATT: Ограничено (restricted)")

        case .notDetermined:
            print("⚠️ ATT: Не определено (notDetermined)")

        @unknown default:
            print("⚠️ ATT: Неизвестный статус")
        }

        // Отправляем статус в AppsFlyer
        sendATTStatusToAppsFlyer(status)
    }

    /// Отправка статуса ATT в AppsFlyer
    private func sendATTStatusToAppsFlyer(_ status: ATTrackingManager.AuthorizationStatus) {
        // AppsFlyer автоматически собирает статус ATT,
        // но можно также отправить как custom event для аналитики
        let statusString: String
        switch status {
        case .authorized: statusString = "authorized"
        case .denied: statusString = "denied"
        case .restricted: statusString = "restricted"
        case .notDetermined: statusString = "notDetermined"
        @unknown default: statusString = "unknown"
        }

        logEvent(name: "att_status", values: ["status": statusString])
    }

    // MARK: - Event Logging

    /// Логирование события в AppsFlyer
    func logEvent(name: String, values: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(name, withValues: values)
        print("📊 AppsFlyer Event: \(name)")
        if let values = values {
            print("   Values: \(values)")
        }
    }

    /// Стандартные события для подписок
    func logSubscriptionEvent(productId: String, price: String, currency: String) {
        logEvent(name: AFEventSubscribe, values: [
            AFEventParamContentId: productId,
            AFEventParamPrice: price,
            AFEventParamCurrency: currency
        ])
    }

    /// Событие начала trial периода
    func logTrialStarted(productId: String) {
        logEvent(name: AFEventStartTrial, values: [
            AFEventParamContentId: productId
        ])
    }

    /// Событие открытия paywall
    func logPaywallOpened(paywallId: String) {
        logEvent(name: "paywall_opened", values: [
            "paywall_id": paywallId
        ])
    }

    /// Событие закрытия paywall
    func logPaywallClosed(paywallId: String, purchased: Bool) {
        logEvent(name: "paywall_closed", values: [
            "paywall_id": paywallId,
            "purchased": purchased
        ])
    }

    // MARK: - Deep Linking

    /// Обработка Universal Links и Deep Links
    func handleOpenURL(_ url: URL) {
        AppsFlyerLib.shared().handleOpen(url, options: nil)
        print("🔗 AppsFlyer handling URL: \(url)")
    }

    /// Обработка User Activity для Universal Links
    func handleUserActivity(_ userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        print("🔗 AppsFlyer handling User Activity")
    }
}

// MARK: - AppsFlyerLibDelegate

extension AppsFlyerManager: AppsFlyerLibDelegate {
    /// Вызывается при успешном получении conversion data
    nonisolated func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        Task { @MainActor in
            print("✅ AppsFlyer: Conversion Data получены")
            print("   Data: \(conversionInfo)")

            self.conversionData = conversionInfo

            // Передаем данные в AppHud для атрибуции
        //    ApphudManager.shared.sendAppsFlyerAttribution(conversionInfo)

            // Обрабатываем deep link данные
            if let status = conversionInfo["af_status"] as? String {
                if status == "Non-organic" {
                    print("   📱 Источник: Non-organic install")

                    if let mediaSource = conversionInfo["media_source"] as? String {
                        print("   📊 Media Source: \(mediaSource)")
                    }

                    if let campaign = conversionInfo["campaign"] as? String {
                        print("   🎯 Campaign: \(campaign)")
                    }
                } else {
                    print("   📱 Источник: Organic install")
                }
            }

            // Обрабатываем deep link
            if let deepLinkValue = conversionInfo["deep_link_value"] as? String {
                print("   🔗 Deep Link: \(deepLinkValue)")
                // Здесь можно добавить навигацию по deep link
            }
        }
    }

    /// Вызывается при ошибке получения conversion data
    nonisolated func onConversionDataFail(_ error: Error) {
        Task { @MainActor in
            print("❌ AppsFlyer: Ошибка получения Conversion Data")
            print("   Error: \(error.localizedDescription)")
        }
    }

    /// Вызывается при получении attribution data (опционально)
    nonisolated func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        Task { @MainActor in
            print("✅ AppsFlyer: Attribution Data получены")
            print("   Data: \(attributionData)")

            // Обрабатываем deep link из push notification или прямого открытия
            if let deepLinkValue = attributionData["deep_link_value"] as? String {
                print("   🔗 Deep Link from app open: \(deepLinkValue)")
                // Навигация по deep link
            }
        }
    }

    /// Вызывается при ошибке получения attribution data
    nonisolated func onAppOpenAttributionFailure(_ error: Error) {
        Task { @MainActor in
            print("❌ AppsFlyer: Ошибка получения Attribution Data")
            print("   Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Helper Extensions

extension ATTrackingManager.AuthorizationStatus {
    var description: String {
        switch self {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }
}
