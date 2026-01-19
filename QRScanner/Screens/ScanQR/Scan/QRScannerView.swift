import SwiftUI
import AVFoundation

struct QRScannerView: UIViewRepresentable {
    @ObservedObject var viewModel: QRScannerViewModel
    var onCodeScanned: (String) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .clear
        containerView.tag = 999 // Tag для идентификации
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Проверяем готовность сессии
        guard let captureSession = viewModel.captureSession else {
            // Если сессии нет, очищаем view
            if let previewLayer = context.coordinator.previewLayer {
                previewLayer.removeFromSuperlayer()
                context.coordinator.previewLayer = nil
            }
            return
        }
        
        // Если preview layer еще не создан, создаем
        if context.coordinator.previewLayer == nil {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            
            // Create mask layer for rounded corners
            let maskLayer = CAShapeLayer()
            previewLayer.mask = maskLayer
            
            uiView.layer.addSublayer(previewLayer)
            
            viewModel.videoPreviewLayer = previewLayer
            context.coordinator.previewLayer = previewLayer
            context.coordinator.maskLayer = maskLayer
        }
        
        // Обновляем размеры и маску
        if let previewLayer = context.coordinator.previewLayer,
           let maskLayer = context.coordinator.maskLayer {
            // Position the camera preview in the center as a square
            let squareSize: CGFloat = 260
            let squareRect = CGRect(
                x: (uiView.bounds.width - squareSize) / 2,
                y: (uiView.bounds.height - squareSize) / 2,
                width: squareSize,
                height: squareSize
            )
            
            if previewLayer.frame != squareRect {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                previewLayer.frame = squareRect
                
                // Update mask to match the frame with rounded corners
                let maskRect = CGRect(x: 0, y: 0, width: squareSize, height: squareSize)
                let maskPath = UIBezierPath(roundedRect: maskRect, cornerRadius: 0)
                maskLayer.path = maskPath.cgPath
                CATransaction.commit()
            }
        }
        
        // Check if code was scanned - only process once per unique code
        if let code = viewModel.scannedCode,
           code != context.coordinator.lastProcessedCode {
            context.coordinator.lastProcessedCode = code
            onCodeScanned(code)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
        var maskLayer: CAShapeLayer?
        var lastProcessedCode: String?
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        // Clean up
        coordinator.previewLayer?.removeFromSuperlayer()
        coordinator.previewLayer = nil
        coordinator.maskLayer = nil
        coordinator.lastProcessedCode = nil
    }
}


#Preview {
    QRScannerView(viewModel: QRScannerViewModel(), onCodeScanned: {_ in })
}
