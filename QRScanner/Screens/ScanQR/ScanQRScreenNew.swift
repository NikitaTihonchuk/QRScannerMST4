import SwiftUI
import AVFoundation
import PhotosUI

struct ScanQRScreenNew: View {
    @ObservedObject private var apphudManager = ApphudManager.shared
    @ObservedObject private var scanLimitManager = ScanLimitManager.shared
    @StateObject private var cameraManager = CameraManager()
    @State private var showResultSheet = false
    @State private var scannedResult: ScannedQRCode?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showNoQRAlert = false
    @State private var showMultipleQRSheet = false
    @State private var detectedQRCodes: [String] = []
    @State private var isProcessingImage = false
    @State var isFreeScanEnable: Bool = false
    @State private var showPaywall = false
    @State private var showLastScanWarning = false
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "F6F7FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                VStack(spacing: 0) {
                    HStack {
                        Text("Scan QR Code")
                            .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                            .foregroundColor(.black)
                        Spacer()
                        
                        // Показываем счетчик только для бесплатных пользователей
                        if !apphudManager.hasPremium {
                            VStack(spacing: 2) {
                                Text("\(scanLimitManager.remainingScans)/5")
                                    .font(.custom(FontEnum.interBold.rawValue, size: 16))
                                    .foregroundColor(scanLimitManager.remainingScans > 0 ? Color(hex: "5AC8FA") : .red)
                                
                                Text("Free scans")
                                    .font(.custom(FontEnum.interRegular.rawValue, size: 10))
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                }
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
                        // Для бесплатных пользователей
                        if scanLimitManager.hasReachedLimit && !isFreeScanEnable {
                            // Показываем кнопку для открытия paywall
                            Button(action: {
                                showPaywall = true
                                
                                // Логируем показ paywall из-за достижения лимита
                                AppMetricaManager.shared.logPaywallShownFromScanLimit()
                            }) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.black.opacity(0.8))
                                    .frame(width: 260, height: 260)
                                    .overlay {
                                        VStack(spacing: 12) {
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                            
                                            Text("Free scan limit reached")
                                                .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                            
                                            Text("Tap to unlock unlimited scans")
                                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                                .foregroundColor(Color(hex: "5AC8FA"))
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding()
                                    }
                            }
                        } else if isFreeScanEnable {
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
                                    // Логируем просмотр рекламы для получения бесплатного скана
                                    AppMetricaManager.shared.logAdWatched(
                                        adType: "rewarded",
                                        reward: "free_scan"
                                    )
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
                        
                        // Логируем использование вспышки
                        AppMetricaManager.shared.logFlashToggled(
                            enabled: cameraManager.isFlashOn,
                            isPremium: apphudManager.hasPremium
                        )
                    }) {
                        VStack(spacing: 8) {
                            Image("flashScanQRIcon")
                            
                            Text("Flash")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                    .disabled(cameraManager.currentCameraPosition == .front || (!apphudManager.hasPremium && scanLimitManager.hasReachedLimit && !isFreeScanEnable))
                    .opacity((cameraManager.currentCameraPosition == .front || (!apphudManager.hasPremium && scanLimitManager.hasReachedLimit && !isFreeScanEnable)) ? 0.5 : 1.0)
                    
                    // Switch Camera
                    Button(action: {
                        cameraManager.switchCamera()
                        
                        // Логируем переключение камеры
                        let position = cameraManager.currentCameraPosition == .front ? "back" : "front"
                        AppMetricaManager.shared.logCameraSwitched(
                            position: position,
                            isPremium: apphudManager.hasPremium
                        )
                    }) {
                        VStack(spacing: 8) {
                            Image("switchScanQRIcon")
                            
                            Text("Switch")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                    .disabled(!apphudManager.hasPremium && scanLimitManager.hasReachedLimit && !isFreeScanEnable)
                    .opacity((!apphudManager.hasPremium && scanLimitManager.hasReachedLimit && !isFreeScanEnable) ? 0.5 : 1.0)
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 8) {
                            Image("galleryScanQRIcon")
                            
                            Text("Gallery")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "5A5A5A"))
                        }
                    }
                    .disabled(!apphudManager.hasPremium && scanLimitManager.hasReachedLimit && !isFreeScanEnable)
                    .opacity((!apphudManager.hasPremium && scanLimitManager.hasReachedLimit && !isFreeScanEnable) ? 0.5 : 1.0)
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
            
            // Сбрасываем счетчик, если у пользователя есть премиум
            if apphudManager.hasPremium {
                scanLimitManager.resetScanCount()
            }
            
            // Логируем открытие экрана сканирования
            let remainingScans = apphudManager.hasPremium ? nil : scanLimitManager.remainingScans
            AppMetricaManager.shared.logScanScreenOpened(
                isPremium: apphudManager.hasPremium,
                remainingScans: remainingScans
            )
        }
        .onDisappear {
            cameraManager.stopSession()
            
            // Сбрасываем флаг бесплатного скана при выходе с экрана
            if !apphudManager.hasPremium && scanLimitManager.hasReachedLimit {
                isFreeScanEnable = false
            }
        }
        .onChange(of: cameraManager.scannedCode) { oldValue, newValue in
            if let code = newValue, scannedResult == nil {
                handleScanResult(code)
            }
        }
        .fullScreenCover(isPresented: $showResultSheet) {
            if let result = scannedResult {
                ScanResultSheet(result: result, isPresented: $showResultSheet)
                    .onDisappear() {
                        Task {
                            await RewardedAdManager.shared.loadAd()
                        }
                    }
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
                    
                    // Логируем открытие галереи
                    AppMetricaManager.shared.logGalleryOpened(
                        isPremium: apphudManager.hasPremium
                    )
                    
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
                handleScanResult(selectedCode, source: "gallery")
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
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(isOnbording: false, onboardingAction: {
                showPaywall = false
            })
        }
        .onChange(of: apphudManager.hasPremium) { oldValue, newValue in
            if newValue {
                // Пользователь купил премиум - сбрасываем счетчик
                scanLimitManager.resetScanCount()
            }
        }
        .onChange(of: scanLimitManager.hasReachedLimit) { oldValue, newValue in
            if newValue && !apphudManager.hasPremium {
                // Лимиты закончились - сбрасываем флаг бесплатного скана
                isFreeScanEnable = false
                cameraManager.stopSession()
                
                // Логируем достижение лимита сканирований
                AppMetricaManager.shared.logScanLimitReached()
            }
        }
        .alert("Last Free Scan!", isPresented: $showLastScanWarning) {
            Button("Continue", role: .cancel) { }
            Button("Get Unlimited") {
                showPaywall = true
                
                // Логируем клик на "Get Unlimited"
                AppMetricaManager.shared.logLastScanWarningUpgradeClicked()
            }
        } message: {
            Text("This is your last free scan. Upgrade to Premium for unlimited QR code scanning!")
        }
        .onChange(of: showLastScanWarning) { oldValue, newValue in
            if newValue {
                // Логируем показ предупреждения о последнем скане
                AppMetricaManager.shared.logLastScanWarningShown(
                    isPremium: apphudManager.hasPremium
                )
            }
        }
    }
    
    private func handleScanResult(_ code: String, source: String = "camera") {
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
        
        // Логируем успешное сканирование QR-кода с детальной информацией
        let remainingScans = apphudManager.hasPremium ? nil : scanLimitManager.remainingScans - 1
        
        AppMetricaManager.shared.logQRScanSuccess(
            type: type.rawValue,
            source: source,
            isPremium: apphudManager.hasPremium,
            remainingScans: remainingScans
        )
        
        // Логируем старое событие для совместимости
        AppMetricaManager.shared.logQRCodeScanned(
            type: type.rawValue,
            isPremium: apphudManager.hasPremium
        )
        
        // Логируем в зависимости от источника
        if source == "camera" {
            AppMetricaManager.shared.logQRScanFromCamera(
                type: type.rawValue,
                isPremium: apphudManager.hasPremium
            )
        }
        
        // Увеличиваем счетчик сканирований только для бесплатных пользователей
        if !apphudManager.hasPremium {
            scanLimitManager.incrementScanCount()
            
            // Показываем предупреждение, если остался 1 бесплатный скан
            if scanLimitManager.remainingScans == 1 {
                // Небольшая задержка, чтобы не конфликтовать с showResultSheet
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showLastScanWarning = true
                }
            }
        }
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
                    // Логируем неудачное сканирование
                    AppMetricaManager.shared.logQRScanFailed(
                        source: "gallery",
                        isPremium: apphudManager.hasPremium
                    )
                    showNoQRAlert = true
                } else if codes.count == 1 {
                    // Логируем сканирование из галереи с одним QR-кодом
                    let type = detectQRCodeType(from: codes[0])
                    AppMetricaManager.shared.logQRScanFromGallery(
                        type: type.rawValue,
                        isPremium: apphudManager.hasPremium,
                        multipleDetected: false
                    )
                    handleScanResult(codes[0], source: "gallery")
                } else {
                    // Логируем обнаружение нескольких QR-кодов
                    AppMetricaManager.shared.logMultipleQRCodesDetected(
                        count: codes.count,
                        isPremium: apphudManager.hasPremium
                    )
                    
                    // Логируем сканирование из галереи с несколькими QR-кодами
                    let type = detectQRCodeType(from: codes[0])
                    AppMetricaManager.shared.logQRScanFromGallery(
                        type: type.rawValue,
                        isPremium: apphudManager.hasPremium,
                        multipleDetected: true
                    )
                    
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
