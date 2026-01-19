import SwiftUI
import AVFoundation
import Combine

// MARK: - Camera Preview Layer
struct CameraPreviewView: View {
    let session: AVCaptureSession
    
    var body: some View {
        CameraPreviewRepresentable(session: session)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - UIViewRepresentable для AVCaptureVideoPreviewLayer
private struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // No updates needed
    }
    
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}

// MARK: - Camera Manager (Observable)
@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isSessionRunning = false
    @Published var scannedCode: String?
    @Published var error: CameraError?
    @Published var isFlashOn = false
    @Published var currentCameraPosition: AVCaptureDevice.Position = .back
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let metadataOutput = AVCaptureMetadataOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var currentDevice: AVCaptureDevice?
    
    enum CameraError: LocalizedError {
        case unauthorized
        case setupFailed
        case noCamera
        
        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return "Camera access is required to scan QR codes"
            case .setupFailed:
                return "Failed to setup camera"
            case .noCamera:
                return "No camera available"
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    func checkAuthorization() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            await setupCamera()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            isAuthorized = granted
            if granted {
                await setupCamera()
            }
        case .denied, .restricted:
            isAuthorized = false
            error = .unauthorized
        @unknown default:
            isAuthorized = false
        }
    }
    
    private func setupCamera() async {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            
            // Setup camera input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.currentCameraPosition) else {
                Task { @MainActor in
                    self.error = .noCamera
                }
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoInput = input
                    self.currentDevice = camera
                }
            } catch {
                Task { @MainActor in
                    self.error = .setupFailed
                }
                return
            }
            
            // Setup metadata output
            if self.session.canAddOutput(self.metadataOutput) {
                self.session.addOutput(self.metadataOutput)
                self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                self.metadataOutput.metadataObjectTypes = [.qr]
            }
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
                Task { @MainActor in
                    self.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                Task { @MainActor in
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    func resetScanning() {
        scannedCode = nil
        startSession()
    }
    
    func toggleFlash() {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let device = self.currentDevice,
                  device.hasTorch else {
                return
            }
            
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .off {
                    try device.setTorchModeOn(level: 1.0)
                    Task { @MainActor in
                        self.isFlashOn = true
                    }
                } else {
                    device.torchMode = .off
                    Task { @MainActor in
                        self.isFlashOn = false
                    }
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Failed to toggle flash: \(error)")
            }
        }
    }
    
    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            
            // Remove current input
            if let currentInput = self.videoInput {
                self.session.removeInput(currentInput)
            }
            
            // Switch position
            let newPosition: AVCaptureDevice.Position = self.currentCameraPosition == .back ? .front : .back
            
            // Get new camera
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                // Re-add the old input if switching fails
                if let oldInput = self.videoInput {
                    self.session.addInput(oldInput)
                }
                return
            }
            
            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.videoInput = newInput
                    self.currentDevice = newCamera
                    
                    Task { @MainActor in
                        self.currentCameraPosition = newPosition
                        // Turn off flash when switching to front camera
                        if newPosition == .front {
                            self.isFlashOn = false
                        }
                    }
                }
            } catch {
                // Re-add the old input if switching fails
                if let oldInput = self.videoInput {
                    self.session.addInput(oldInput)
                }
                print("Failed to switch camera: \(error)")
            }
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        // Haptic feedback
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        Task { @MainActor in
            self.scannedCode = stringValue
            self.stopSession()
        }
    }
}
