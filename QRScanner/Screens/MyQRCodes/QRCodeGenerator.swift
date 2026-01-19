import UIKit
import CoreImage

class QRCodeGenerator {
    static func generateQRCode(from string: String, size: CGSize = CGSize(width: 512, height: 512)) -> UIImage? {
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
        
        guard let ciImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: size.width / ciImage.extent.width,
                                         y: size.height / ciImage.extent.height)
        let scaledImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
