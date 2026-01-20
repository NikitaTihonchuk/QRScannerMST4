import SwiftUI
import AVFoundation
import PhotosUI

struct ScanQRScreenNew: View {
    @ObservedObject private var apphudManager = ApphudManager.shared
    @StateObject private var cameraManager = CameraManager()
    @State private var showResultSheet = false
    @State private var scannedResult: ScannedQRCode?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showNoQRAlert = false
    @State private var showMultipleQRSheet = false
    @State private var detectedQRCodes: [String] = []
    @State private var isProcessingImage = false
    @State var isFreeScanEnable: Bool = false
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "F6F7FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("Scan QR Code")
                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom)
                .background(
                    Rectangle()
                        .foregroundStyle(Color(hex: "FFFFFF"))
                        .ignoresSafeArea()
                )
                .padding(.bottom, 40)
                
                // Info banner
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "5AC8FA"))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "info")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Align QR code within frame")
                            .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                            .foregroundColor(Color(hex: "5A5A5A"))
                        
                        Text("Keep your device steady")
                            .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                            .foregroundColor(Color(hex: "B0B0B0"))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 32)
                
                // Scanning frame
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "5AC8FA"), lineWidth: 3)
                        .frame(width: 280, height: 280)
                    // Camera preview
                    if apphudManager.hasPremium {
                        if cameraManager.isAuthorized {
                            CameraPreviewView(session: cameraManager.session)
                                .frame(width: 278, height: 278)
                        } else {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.black.opacity(0.8))
                                .frame(width: 260, height: 260)
                                .overlay {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        
                                        Text("Camera Access Required")
                                            .font(.custom(FontEnum.interMedium.rawValue, size: 14))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                }
                        }
                    } else {
                        if isFreeScanEnable {
                            if cameraManager.isAuthorized {
                                CameraPreviewView(session: cameraManager.session)
                                    .frame(width: 278, height: 278)
                            } else {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.black.opacity(0.8))
                                    .frame(width: 260, height: 260)
                                    .overlay {
                                        VStack(spacing: 12) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                            
                                            Text("Camera Access Required")
                                                .font(.custom(FontEnum.interMedium.rawValue, size: 14))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding()
                                    }
                            }
                        } else {
                            Button(action: {
                                RewardedAdManager.shared.showAd { reward in
                                    isFreeScanEnable = true
                                }

                            }, label: {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.black.opacity(0.8))
                                    .frame(width: 260, height: 260)
                                    .overlay {
                                        VStack(spacing: 12) {
                                            Image(systemName: "hand.tap")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                            
                                            Text("Tap to watch ads and get QR Code free scan")
                                                .font(.custom(FontEnum.interMedium.rawValue, size: 14))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                            
                                            
                                        }
                                        .padding()
                                    }
                            })
                        }
                    }
                }
                .frame(width: 260, height: 260)
                
                // Bottom controls
                HStack(spacing: 40) {
                    // Flash
                    Button(action: {
                        cameraManager.toggleFlash()
                    }) {
                        VStack(spacing: 8) {
                            Image("flashScanQRIcon")
                            
                            Text("Flash")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                    .disabled(cameraManager.currentCameraPosition == .front)
                    .opacity(cameraManager.currentCameraPosition == .front ? 0.5 : 1.0)
                    
                    // Switch Camera
                    Button(action: {
                        cameraManager.switchCamera()
                    }) {
                        VStack(spacing: 8) {
                            Image("switchScanQRIcon")
                            
                            Text("Switch")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 8) {
                            Image("galleryScanQRIcon")
                            
                            Text("Gallery")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                }
                .padding(.horizontal, 60)
                .padding(.top, 40)
                .padding(.bottom, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16.0)
                        .foregroundStyle(Color(hex: "FFFFFF"))
                        .shadow(color: .gray, radius: 1.0)

                )
                .padding(.top, 60)

                
                Spacer()
            }
        }
        .task {
            await cameraManager.checkAuthorization()
        }
        .onAppear {
            Task {
                await RewardedAdManager.shared.loadAd()
            }
            scannedResult = nil
            isProcessingImage = false
            selectedPhotoItem = nil
            
            cameraManager.scannedCode = nil
            cameraManager.resetScanning()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .onChange(of: cameraManager.scannedCode) { oldValue, newValue in
            if let code = newValue, scannedResult == nil {
                handleScanResult(code)
            }
        }
        .fullScreenCover(isPresented: $showResultSheet) {
            if let result = scannedResult {
                ScanResultSheet(result: result, isPresented: $showResultSheet)
            }
        }
        .onChange(of: showResultSheet) { oldValue, newValue in
            if !newValue {
                scannedResult = nil
                isProcessingImage = false
                selectedPhotoItem = nil
                cameraManager.resetScanning()
            }
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let newValue {
                    isProcessingImage = true
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            processImageForQRCode(image)
                        }
                    } else {
                        await MainActor.run {
                            isProcessingImage = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showMultipleQRSheet) {
            MultipleQRCodesSheet(
                qrCodes: detectedQRCodes,
                isPresented: $showMultipleQRSheet
            ) { selectedCode in
                handleScanResult(selectedCode)
            }
        }
        .alert("No QR Code Found", isPresented: $showNoQRAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The selected image doesn't contain a valid QR code. Please try another image.")
        }
        .overlay {
            if isProcessingImage {
                ProcessingImageOverlay()
            }
        }
    }
    
    private func handleScanResult(_ code: String) {
        guard scannedResult == nil else { return }
        
        isProcessingImage = false
        
        let type = detectQRCodeType(from: code)
        let result = ScannedQRCode(
            content: code,
            type: type,
            scannedDate: Date()
        )
        
        scannedResult = result
        showResultSheet = true
        
        QRHistoryManager.shared.saveToHistory(result)
    }
    
    private func detectQRCodeType(from content: String) -> QRCodeType {
        if content.lowercased().hasPrefix("http://") || content.lowercased().hasPrefix("https://") {
            return .url
        } else if content.lowercased().hasPrefix("mailto:") {
            return .email
        } else if content.lowercased().hasPrefix("tel:") {
            return .phone
        } else {
            return .text
        }
    }
    
    private func processImageForQRCode(_ image: UIImage) {
        isProcessingImage = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let codes = QRCodeDetector.detectAllQRCodes(in: image)
            
            DispatchQueue.main.async {
                isProcessingImage = false
                
                if codes.isEmpty {
                    showNoQRAlert = true
                } else if codes.count == 1 {
                    handleScanResult(codes[0])
                } else {
                    detectedQRCodes = codes
                    showMultipleQRSheet = true
                }
            }
        }
    }
}

#Preview {
    ScanQRScreenNew()
}
