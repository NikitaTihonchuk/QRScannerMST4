import SwiftUI
import AppMetricaCore
import ApphudSDK
import GoogleMobileAds
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  
  var appOpenAdManager: AppOpenAdManager?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      // Инициализация AppMetrica через AppMetricaManager
      // Это нужно для случаев, когда приложение запускается не из UI (например, background fetch)
      AppMetricaManager.shared.initialize()
      
      // Инициализация Apphud
      Apphud.start(apiKey: AppConfiguration.main.apphudKey)
      
      // Инициализация Firebase
      FirebaseApp.configure()
      
      return true
  }

}
