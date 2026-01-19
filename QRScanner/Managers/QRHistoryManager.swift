import Foundation
import Combine
import SwiftUI

// MARK: - History Item Model
struct HistoryItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let content: String
    let type: QRCodeType
    let actionType: HistoryActionType
    let date: Date
    
    enum HistoryActionType: String, Codable {
        case scanned
        case created
    }
    
    init(id: UUID = UUID(), title: String, content: String, type: QRCodeType, actionType: HistoryActionType, date: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.type = type
        self.actionType = actionType
        self.date = date
    }
}

// MARK: - QR History Item Model (Legacy - for backwards compatibility)
struct QRHistoryItem: Codable, Identifiable {
    let id: UUID
    let content: String
    let type: QRCodeType
    let scannedDate: Date
    
    init(id: UUID = UUID(), content: String, type: QRCodeType, scannedDate: Date) {
        self.id = id
        self.content = content
        self.type = type
        self.scannedDate = scannedDate
    }
    
    init(from scannedQR: ScannedQRCode) {
        self.id = UUID()
        self.content = scannedQR.content
        self.type = scannedQR.type
        self.scannedDate = scannedQR.scannedDate
    }
}

// MARK: - QRCodeType Codable Extension
extension QRCodeType: Codable {
    enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "url": self = .url
        case "email": self = .email
        case "phone": self = .phone
        case "text": self = .text
        default: self = .text
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .url: try container.encode("url")
        case .email: try container.encode("email")
        case .phone: try container.encode("phone")
        case .text: try container.encode("text")
        }
    }
}

// MARK: - History Manager
@MainActor
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published private(set) var historyItems: [HistoryItem] = []
    
    private let userDefaultsKey = "qr_history_v2"
    private let maxHistoryItems = 100
    private let saveQueue = DispatchQueue(label: "com.qrscanner.historyQueue", qos: .utility)
    
    private init() {
        loadHistory()
    }
    
    // MARK: - Add Scanned Item
    func addScannedItem(content: String, type: QRCodeType) {
        let title = generateTitle(for: content, type: type)
        let newItem = HistoryItem(
            title: title,
            content: content,
            type: type,
            actionType: .scanned,
            date: Date()
        )
        addItem(newItem)
    }
    
    // MARK: - Add Created Item
    func addCreatedItem(name: String, content: String, type: MyQRCodeItem.QRCodeContentType) {
        let qrType = convertToQRCodeType(type)
        let newItem = HistoryItem(
            title: name,
            content: content,
            type: qrType,
            actionType: .created,
            date: Date()
        )
        addItem(newItem)
    }
    
    // MARK: - Add Item
    private func addItem(_ item: HistoryItem) {
        // Remove duplicates based on content
        historyItems.removeAll { $0.content == item.content && $0.actionType == item.actionType }
        
        // Add to beginning
        historyItems.insert(item, at: 0)
        
        // Limit size
        if historyItems.count > maxHistoryItems {
            historyItems = Array(historyItems.prefix(maxHistoryItems))
        }
        
        saveHistoryAsync()
    }
    
    // MARK: - Generate Title
    private func generateTitle(for content: String, type: QRCodeType) -> String {
        switch type {
        case .url:
            return "Website Link"
        case .email:
            return "Email Address"
        case .phone:
            return "Phone Number"
        case .text:
            if content.contains("WIFI:") {
                return "WiFi Network"
            } else if content.contains("VCARD") || content.contains("BEGIN:VCARD") {
                return "Contact Info"
            } else {
                return "Text Message"
            }
        }
    }
    
    // MARK: - Convert Type
    private func convertToQRCodeType(_ type: MyQRCodeItem.QRCodeContentType) -> QRCodeType {
        switch type {
        case .url: return .url
        case .email: return .email
        case .phone: return .phone
        case .text, .wifi, .contact: return .text
        }
    }
    
    // MARK: - Load History
    private func loadHistory() {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            guard let data = UserDefaults.standard.data(forKey: self.userDefaultsKey) else {
                Task { @MainActor in
                    self.historyItems = []
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let items = try decoder.decode([HistoryItem].self, from: data)
                Task { @MainActor in
                    self.historyItems = items
                }
            } catch {
                print("Failed to load history: \(error)")
                Task { @MainActor in
                    self.historyItems = []
                }
            }
        }
    }
    
    // MARK: - Save History (Async)
    private func saveHistoryAsync() {
        let itemsToSave = historyItems
        saveQueue.async {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(itemsToSave)
                UserDefaults.standard.set(data, forKey: self.userDefaultsKey)
            } catch {
                print("Failed to save history: \(error)")
            }
        }
    }
    
    // MARK: - Delete Item
    func deleteItem(at offsets: IndexSet) {
        historyItems.remove(atOffsets: offsets)
        saveHistoryAsync()
    }
    
    // MARK: - Delete Item by ID
    func deleteItem(id: UUID) {
        historyItems.removeAll { $0.id == id }
        saveHistoryAsync()
    }
    
    // MARK: - Clear All History
    func clearAllHistory() {
        historyItems.removeAll()
        saveHistoryAsync()
    }
}

// MARK: - QR History Manager (Legacy - keeping for compatibility)
@MainActor
class QRHistoryManager: ObservableObject {
    static let shared = QRHistoryManager()
    
    @Published private(set) var historyItems: [QRHistoryItem] = []
    
    private let userDefaultsKey = "qr_scan_history"
    private let maxHistoryItems = 100
    private let saveQueue = DispatchQueue(label: "com.qrscanner.historyQueue", qos: .utility)
    
    private init() {
        loadHistory()
    }
    
    // MARK: - Save to History
    func saveToHistory(_ scannedQR: ScannedQRCode) {
        let newItem = QRHistoryItem(from: scannedQR)
        
        // Also save to new HistoryManager
        Task { @MainActor in
            HistoryManager.shared.addScannedItem(content: scannedQR.content, type: scannedQR.type)
        }
        
        if let existingIndex = historyItems.firstIndex(where: { $0.content == newItem.content }) {
            historyItems.remove(at: existingIndex)
        }
        
        historyItems.insert(newItem, at: 0)
        
        if historyItems.count > maxHistoryItems {
            historyItems = Array(historyItems.prefix(maxHistoryItems))
        }
        
        saveHistoryAsync()
    }
    
    // MARK: - Load History
    private func loadHistory() {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            guard let data = UserDefaults.standard.data(forKey: self.userDefaultsKey) else {
                Task { @MainActor in
                    self.historyItems = []
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let items = try decoder.decode([QRHistoryItem].self, from: data)
                Task { @MainActor in
                    self.historyItems = items
                }
            } catch {
                print("Failed to load history: \(error)")
                Task { @MainActor in
                    self.historyItems = []
                }
            }
        }
    }
    
    // MARK: - Save History (Async)
    private func saveHistoryAsync() {
        let itemsToSave = historyItems
        saveQueue.async {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(itemsToSave)
                UserDefaults.standard.set(data, forKey: self.userDefaultsKey)
            } catch {
                print("Failed to save history: \(error)")
            }
        }
    }
    
    // MARK: - Delete Item
    func deleteItem(at offsets: IndexSet) {
        historyItems.remove(atOffsets: offsets)
        saveHistoryAsync()
    }
    
    // MARK: - Delete Item by ID
    func deleteItem(id: UUID) {
        historyItems.removeAll { $0.id == id }
        saveHistoryAsync()
    }
    
    // MARK: - Clear All History
    func clearAllHistory() {
        historyItems.removeAll()
        saveHistoryAsync()
    }
    
    // MARK: - Check if item exists
    func isInHistory(content: String) -> Bool {
        return historyItems.contains { $0.content == content }
    }
}
