import Combine
import SwiftUI
import Foundation


class MyQRCodesManager: ObservableObject {
    static let shared = MyQRCodesManager()
    
    @Published var myQRCodes: [MyQRCodeItem] = []
    
    private let userDefaultsKey = "SavedMyQRCodes"
    
    private init() {
        loadQRCodes()
    }
    
    func saveQRCode(name: String, content: String, qrImage: UIImage, type: MyQRCodeItem.QRCodeContentType) {
        guard let imageData = qrImage.pngData() else { return }
        
        let newItem = MyQRCodeItem(
            id: UUID(),
            name: name,
            content: content,
            qrImageData: imageData,
            createdDate: Date(),
            type: type
        )
        
        myQRCodes.insert(newItem, at: 0)
        saveToUserDefaults()
        
        // Add to history
        Task { @MainActor in
            HistoryManager.shared.addCreatedItem(name: name, content: content, type: type)
        }
    }
    
    func deleteQRCode(id: UUID) {
        myQRCodes.removeAll { $0.id == id }
        saveToUserDefaults()
    }
    
    func clearAll() {
        myQRCodes.removeAll()
        saveToUserDefaults()
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(myQRCodes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadQRCodes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([MyQRCodeItem].self, from: data) {
            myQRCodes = decoded
        }
    }
}
