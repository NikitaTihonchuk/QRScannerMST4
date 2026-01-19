import AVFoundation
import SwiftUI
import Combine

class QRScannerViewModel: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var isFlashOn = false
    @Published var scannedCode: String?
    @Published var currentCamera: AVCaptureDevice.Position = .back
    @Published var isSessionConfigured = false
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var currentVideoInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "com.qrscanner.sessionQueue", qos: .userInitiated)
    private var metadataOutput: AVCaptureMetadataOutput?
    
    override init() {
        super.init()
        // Не инициализируем камеру сразу - делаем это асинхронно
    }
    
    func setupCaptureSessionIfNeeded() {
        // Если уже настроено, пропускаем
        guard captureSession == nil else { return }
        
        // Настройка камеры в фоновом потоке
        sessionQueue.async { [weak self] in
            self?.setupCaptureSession()
        }
    }
    
    private func setupCaptureSession() {
        let session = AVCaptureSession()
        
        // Используем preset для лучшей производительности
        session.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { 
            print("Failed to get camera device")
            return 
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        session.beginConfiguration()
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
            currentVideoInput = videoInput
        } else {
            session.commitConfiguration()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            // Используем отдельную очередь для обработки метаданных
            let metadataQueue = DispatchQueue(label: "com.qrscanner.metadataQueue", qos: .userInitiated)
            metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
            metadataOutput.metadataObjectTypes = [.qr]
            
            self.metadataOutput = metadataOutput
        } else {
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        
        // Сохраняем сессию
        self.captureSession = session
        
        // Уведомляем о завершении настройки
        DispatchQueue.main.async {
            self.isSessionConfigured = true
        }
    }
    
    func startScanning() {
        // Сначала настраиваем сессию если нужно
        setupCaptureSessionIfNeeded()
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Проверяем готовность сессии
            guard let session = self.captureSession else {
                // Если сессия не готова, пробуем настроить и запустить снова
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.startScanning()
                }
                return
            }
            
            // Если уже работает, не запускаем заново
            guard !session.isRunning else {
                DispatchQueue.main.async {
                    self.isScanning = true
                }
                return
            }
            
            session.startRunning()
            
            DispatchQueue.main.async {
                self.isScanning = true
            }
        }
    }
    
    func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let session = self.captureSession,
                  session.isRunning else { return }
            
            session.stopRunning()
            
            DispatchQueue.main.async {
                self.isScanning = false
            }
        }
    }
    
    func resumeScanning() {
        scannedCode = nil
        startScanning()
    }
    
    func toggleFlash() {
        guard let device = currentVideoInput?.device else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    
                    if self.isFlashOn {
                        device.torchMode = .off
                        DispatchQueue.main.async {
                            self.isFlashOn = false
                        }
                    } else {
                        try device.setTorchModeOn(level: 1.0)
                        DispatchQueue.main.async {
                            self.isFlashOn = true
                        }
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used: \(error)")
                }
            }
        }
    }
    
    func switchCamera() {
        guard let captureSession = captureSession else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Turn off flash when switching
            if self.isFlashOn {
                DispatchQueue.main.async {
                    self.toggleFlash()
                }
            }
            
            captureSession.beginConfiguration()
            
            // Remove current input
            if let currentInput = self.currentVideoInput {
                captureSession.removeInput(currentInput)
            }
            
            // Toggle camera position
            let newPosition: AVCaptureDevice.Position = (self.currentCamera == .back) ? .front : .back
            
            // Get new camera
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                captureSession.commitConfiguration()
                return
            }
            
            // Create new input
            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                    self.currentVideoInput = newInput
                    DispatchQueue.main.async {
                        self.currentCamera = newPosition
                    }
                }
            } catch {
                print("Error switching camera: \(error)")
            }
            
            captureSession.commitConfiguration()
        }
    }
    
    // Cleanup метод
    func cleanup() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession?.stopRunning()
            
            // Очищаем ресурсы
            if let inputs = self.captureSession?.inputs {
                for input in inputs {
                    self.captureSession?.removeInput(input)
                }
            }
            
            if let outputs = self.captureSession?.outputs {
                for output in outputs {
                    self.captureSession?.removeOutput(output)
                }
            }
            
            DispatchQueue.main.async {
                self.isScanning = false
                self.isFlashOn = false
            }
        }
    }
}

extension QRScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Prevent multiple scans - check if we already have a scanned code
        guard scannedCode == nil else { return }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Vibrate на главном потоке
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            // Set scanned code immediately to prevent multiple scans
            DispatchQueue.main.async { [weak self] in
                self?.scannedCode = stringValue
                self?.isScanning = false
            }
            
            // Stop scanning в фоне
            sessionQueue.async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
}
