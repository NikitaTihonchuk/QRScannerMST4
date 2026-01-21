import SwiftUI
import GoogleMobileAds
import Combine

@main
struct QRScannerApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var appsFlyerManager = AppsFlyerManager.shared
    @StateObject private var appMetricaManager = AppMetricaManager.shared
    @ObservedObject private var apphudManager = ApphudManager.shared

    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var firstTime: Bool = true
    init() {
        MobileAds.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(appsFlyerManager)
                    .environmentObject(appMetricaManager)
                    .task {
                        await initializeApp()
                    }
                    .onAppear() {
                        if !apphudManager.hasPremium {
                            if firstTime {
                                Task {
                                    try? await Task.sleep(nanoseconds: 3_000_000_000) // 0.3 сек
                                    await AppOpenAdManager.shared.showAdIfAvailable()
                                }
                            }
                        }
                        firstTime = false
                    }
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        handleScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
                        if !apphudManager.hasPremium {
                            Task {
                                try? await Task.sleep(nanoseconds: 1_000_000_000) // 0.3 сек
                                await AppOpenAdManager.shared.showAdIfAvailable()
                            }
                        }
                        
                    }
                    .onOpenURL { url in
                        // Обработка deep links
                        AppsFlyerManager.shared.handleOpenURL(url)
                    }
            } else {
                OnboardingMainScreen()
                    .environmentObject(appsFlyerManager)
                    .environmentObject(appMetricaManager)
                    .task {
                        await initializeApp()
                    }
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        handleScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
                    }
                    .onOpenURL { url in
                        // Обработка deep links
                        AppsFlyerManager.shared.handleOpenURL(url)
                    }
            }
        }
    }
    
    /// Инициализация приложения с правильной последовательностью
    private func initializeApp() async {
        print("🚀 Инициализация приложения...")
        
        // Шаг 1: Инициализируем AppMetrica (не требует ATT, делаем сразу)
        print("📱 Шаг 1: Инициализация AppMetrica...")
        AppMetricaManager.shared.initialize()
        
        // Для пользователей, которые уже прошли онбординг, не показываем ATT повторно
        guard !hasCompletedOnboarding else {
            print("✅ Пользователь уже прошел онбординг, пропускаем ATT запрос")
            
            // Инициализируем AppsFlyer для существующих пользователей
            if !appsFlyerManager.isInitialized {
                print("📱 Инициализация AppsFlyer...")
                await appsFlyerManager.initialize()
                appsFlyerManager.start()
            }
            
            return
        }
        
        // Даем пользователю увидеть интерфейс перед показом ATT alert
        // Apple рекомендует задержку минимум 1 секунду
        print("⏳ Ожидание перед показом ATT...")
        try? await Task.sleep(for: .seconds(1))
        
        // Шаг 2: Запрашиваем разрешение ATT (только для новых пользователей)
        print("📱 Шаг 2: Запрос разрешения ATT...")
        let attStatus = await appsFlyerManager.requestATTPermission()
        print("✅ ATT статус получен: \(attStatus.description)")
        
        // Шаг 3: Инициализируем AppsFlyer (после получения ATT статуса)
        print("📱 Шаг 3: Инициализация AppsFlyer...")
        await appsFlyerManager.initialize()
        
        // Шаг 4: Запускаем AppsFlyer SDK
        print("📱 Шаг 4: Запуск AppsFlyer SDK...")
        appsFlyerManager.start()

        print("✅ Инициализация приложения завершена")
    }
    
    private func handleScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("🟢 App стал активным")
            // Запускаем AppsFlyer только если уже инициализирован
            if appsFlyerManager.isInitialized {
                AppsFlyerManager.shared.start()
            }


        case .inactive:
            print("🟡 App стал неактивным")

        case .background:
            print("🔴 App ушел в фон")

        @unknown default:
            break
        }
    }
}
