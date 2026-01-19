import UIKit
import CoreImage

class QRCodeDetector {
    static func detectQRCode(in image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                 context: context,
                                 options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        
        // Return the first QR code found
        return features?.first?.messageString
    }
    
    static func detectAllQRCodes(in image: UIImage) -> [String] {
        guard let ciImage = CIImage(image: image) else { return [] }
        
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                 context: context,
                                 options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        
        // Return all QR codes found
        return features?.compactMap { $0.messageString } ?? []
    }
}
