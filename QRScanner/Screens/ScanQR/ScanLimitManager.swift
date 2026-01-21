import Foundation
import Combine

/// Менеджер для отслеживания лимита бесплатных сканирований
@MainActor
class ScanLimitManager: ObservableObject {
    static let shared = ScanLimitManager()
    
    // Максимальное количество бесплатных сканирований
    private let maxFreeScans = 5
    
    // Ключ для UserDefaults
    private let scanCountKey = "free_scan_count"
    
    // Текущее количество использованных сканирований
    @Published private(set) var usedScans: Int = 0
    
    private init() {
        loadScanCount()
    }
    
    // MARK: - Public Properties
    
    /// Оставшееся количество бесплатных сканирований
    var remainingScans: Int {
        max(0, maxFreeScans - usedScans)
    }
    
    /// Достигнут ли лимит бесплатных сканирований
    var hasReachedLimit: Bool {
        usedScans >= maxFreeScans
    }
    
    /// Можно ли выполнить бесплатное сканирование
    func canScan(hasPremium: Bool) -> Bool {
        return hasPremium || !hasReachedLimit
    }
    
    // MARK: - Public Methods
    
    /// Увеличить счетчик сканирований
    func incrementScanCount() {
        usedScans += 1
        saveScanCount()
        
        // Логируем достижение лимита
        if hasReachedLimit {
            AppMetricaManager.shared.logScanLimitReached()
        }
    }
    
    /// Сбросить счетчик (например, после покупки Premium)
    func resetScanCount() {
        usedScans = 0
        saveScanCount()
    }
    
    // MARK: - Private Methods
    
    private func loadScanCount() {
        usedScans = UserDefaults.standard.integer(forKey: scanCountKey)
    }
    
    private func saveScanCount() {
        UserDefaults.standard.set(usedScans, forKey: scanCountKey)
    }
}
