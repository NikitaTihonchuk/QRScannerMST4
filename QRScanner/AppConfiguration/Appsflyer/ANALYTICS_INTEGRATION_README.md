# Интеграция Analytics: AppsFlyer + AppMetrica

## 📋 Обзор

В приложении теперь настроена двойная аналитика:
- **AppsFlyer** - для атрибуции и отслеживания маркетинговых кампаний
- **AppMetrica** - для детальной аналитики событий и поведения пользователей

Все события автоматически дублируются в обе системы через единый API.

## 🚀 Настройка

### 1. Добавьте API ключ AppMetrica

В файле `AppConfiguration.swift` замените плейсхолдер на реальный API ключ:

```swift
self.appMetricaAPIKey = "YOUR_APPMETRICA_API_KEY"  // ← Замените на реальный ключ
```

### 2. Инициализация

Инициализация происходит автоматически в `QRScannerApp.swift`:

```swift
// Порядок инициализации:
// 1. ATT разрешение
// 2. AppMetrica (не требует ATT)
// 3. AppsFlyer (использует ATT статус)
// 4. Запуск AppsFlyer SDK
```

## 📊 Использование

### Логирование событий

Все события автоматически дублируются в обе системы:

```swift
// Простое событие
AppsFlyerManager.shared.logEvent(name: "button_clicked", values: [
    "button_name": "premium_upgrade"
])

// Событие подписки
AppsFlyerManager.shared.logSubscriptionEvent(
    productId: "premium_monthly",
    price: "9.99",
    currency: "USD"
)

// Событие открытия paywall
AppsFlyerManager.shared.logPaywallOpened(paywallId: "main_paywall")

// Событие закрытия paywall
AppsFlyerManager.shared.logPaywallClosed(paywallId: "main_paywall", purchased: true)
```

### Специфичные события AppMetrica

Если нужно логировать событие только в AppMetrica:

```swift
// QR код сканирован
AppMetricaManager.shared.logQRCodeScanned(type: "url", isPremium: true)

// QR код создан
AppMetricaManager.shared.logQRCodeCreated(type: "vcard")

// Достигнут лимит сканирований
AppMetricaManager.shared.logScanLimitReached()

// Просмотр рекламы
AppMetricaManager.shared.logAdWatched(adType: "rewarded", reward: "free_scan")
```

### Свойства пользователя (AppMetrica)

```swift
// Установка произвольного свойства
AppMetricaManager.shared.setUserProperty(key: "user_level", value: "advanced")

// Установка премиум статуса
AppMetricaManager.shared.setPremiumStatus(true)
```

### Отслеживание дохода (AppMetrica)

```swift
AppMetricaManager.shared.logRevenue(
    productId: "premium_yearly",
    price: Decimal(99.99),
    currency: "USD",
    quantity: 1
)
```

## 🔗 Атрибуция

Данные атрибуции из AppsFlyer автоматически передаются в AppMetrica:

```swift
// Это происходит автоматически в AppsFlyerManager:
AppMetricaManager.shared.sendAppsFlyerAttribution(conversionInfo)
```

## 📝 Стандартные события

### События подписок
- `subscription_purchased` - покупка подписки
- `trial_started` - начало пробного периода

### События paywall
- `paywall_opened` - открытие экрана покупки
- `paywall_closed` - закрытие экрана (с параметром `purchased`)

### События QR кодов (AppMetrica)
- `qr_scanned` - сканирование QR кода
- `qr_created` - создание QR кода
- `scan_limit_reached` - достижение лимита сканирований

### События рекламы (AppMetrica)
- `ad_watched` - просмотр рекламы

### Технические события
- `att_status` - статус разрешения ATT

## 🎯 Примеры интеграции

### В экране сканирования

```swift
// При успешном сканировании
private func handleScanResult(_ code: String) {
    // ... ваша логика ...
    
    // Логируем событие
    AppMetricaManager.shared.logQRCodeScanned(
        type: type.rawValue,
        isPremium: apphudManager.hasPremium
    )
}

// При достижении лимита
if scanLimitManager.hasReachedLimit {
    AppMetricaManager.shared.logScanLimitReached()
}
```

### В экране создания QR

```swift
// При создании QR кода
func createQRCode(type: QRCodeType) {
    // ... ваша логика ...
    
    AppMetricaManager.shared.logQRCodeCreated(type: type.rawValue)
}
```

### При просмотре рекламы

```swift
// После просмотра rewarded ad
RewardedAdManager.shared.showAd { reward in
    AppMetricaManager.shared.logAdWatched(
        adType: "rewarded",
        reward: "free_scan"
    )
}
```

### При покупке подписки

```swift
// После успешной покупки
AppsFlyerManager.shared.logSubscriptionEvent(
    productId: product.id,
    price: product.price,
    currency: "USD"
)

// Revenue автоматически логируется в AppMetrica через дублирование
```

## 🔍 Отладка

### Логи AppsFlyer
```
✅ AppsFlyer SDK инициализирован
   Dev Key: GAgckFyN4yETigBtP4qtRG
   Apple App ID: 6749377146
📊 AppsFlyer Event: subscription_purchased
   Values: ["product_id": "premium", "price": "9.99"]
```

### Логи AppMetrica
```
✅ AppMetrica SDK инициализирован
   API Key: ваш_ключ
   Device ID: abc123...
📊 AppMetrica Event: subscription_purchased
   Parameters: ["product_id": "premium", "price": "9.99"]
```

## ⚠️ Важные замечания

1. **API ключ AppMetrica** - обязательно замените плейсхолдер на реальный ключ
2. **Debug режим** - логи включены только в DEBUG сборках
3. **ATT разрешение** - AppsFlyer ждет ATT статус, AppMetrica работает независимо
4. **Дублирование событий** - все события из `AppsFlyerManager.logEvent()` автоматически идут в обе системы

## 📚 Дополнительные ресурсы

- [AppsFlyer Documentation](https://dev.appsflyer.com/)
- [AppMetrica Documentation](https://appmetrica.io/docs/)
- [ATT Best Practices](https://developer.apple.com/app-store/user-privacy-and-data-use/)
