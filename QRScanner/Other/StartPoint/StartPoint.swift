import SwiftUI
import AppMetricaCore
import ApphudSDK

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      //Инициализация AppMetrica
    let configuration = AppMetricaConfiguration(apiKey: "8aca1b5c-f091-4da6-a57a-a68d74cbec54")
    AppMetrica.activate(with: configuration!)
    Apphud.start(apiKey: AppConfiguration.main.apphudKey)
    return true
  }

}
