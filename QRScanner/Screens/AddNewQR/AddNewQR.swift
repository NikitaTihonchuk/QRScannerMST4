import SwiftUI
import CoreImage.CIFilterBuiltins

struct AddNewQR: View {
    @ObservedObject private var apphudManager = ApphudManager.shared
    @StateObject var adManager: FullScreenAdManager = FullScreenAdManager()
    @State private var selectedContentType: QRContentType = .url
    @State private var qrName: String = ""
    @State private var urlText: String = ""
    @State private var plainText: String = ""
    @State private var contactName: String = ""
    @State private var contactPhone: String = ""
    @State private var wifiSSID: String = ""
    @State private var wifiPassword: String = ""
    @State private var wifiSecurity: WifiSecurityType = .wpa
    
    @State private var selectedColor: QRColor = .black
    @State private var qrCodeImage: UIImage?
    @State private var showSuccess: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var logoImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var isSaved: Bool = false
    @State private var savedQRCodeID: UUID?
    @FocusState private var focusedField: FocusedField?
    @State var isAdvertisment: Bool = false
    @State var showPaywall: Bool = false
    var onClose: (() -> Void)? = nil
    
    enum FocusedField: Hashable {
        case qrName
        case urlText
        case plainText
        case contactName
        case contactPhone
        case wifiSSID
        case wifiPassword
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F6F7FA")
                .ignoresSafeArea()
            
            if showSuccess {
                successView
            } else {
                createView
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(isOnbording: false, onboardingAction: {})
        }
    }
    
    // MARK: - Create View
    private var createView: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 24) {
                    // Content Type Selection
                    contentTypeSection
                    
                    // Input fields based on type
                    inputSection
                    
                    // Design Options
                    designSection
                    
                    // Generate Button
                    generateButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 140)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { _ in
                // Hide keyboard on scroll
                focusedField = nil
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in
                        focusedField = nil
                    }
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Hide keyboard on tap outside
            focusedField = nil
        }
    }
    
    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(Localization.CreateQR.title)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button {
                    onClose?()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "E5E7EB"))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(Color(hex: "FFFFFF"))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Success Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: "7ED957"))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(Color(hex: "FFFFFF"))
                    }
                    .padding(.top, 40)
                    .shadow(color:Color(hex: "7ED957"), radius: 10.0)
                    
                    Text(Localization.CreateQR.qrCodeReady)
                        .font(.custom(FontEnum.interSemiBold.rawValue, size: 17))
                        .foregroundColor(Color(hex: "000000"))
                    
                    // QR Code Preview
                    if let image = qrCodeImage {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(hex: "5AC8FA"), lineWidth: 3)
                                .frame(width: 280, height: 280)
                            
                            Image(uiImage: image)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 240)
                        }
                        .padding(.vertical, 20)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        ActionButton(
                            icon: "square.and.arrow.up",
                            title: Localization.CreateQR.shareButton,
                            color: Color(hex: "E5E7EB")
                        ) {
                            showShareSheet = true
                        }
                        
                        ActionButton(
                            icon: isSaved ? "bookmark.fill" : "bookmark",
                            title: isSaved ? Localization.CreateQR.savedButton : Localization.CreateQR.saveButton,
                            color: isSaved ? Color(hex: "5AC8FA").opacity(0.15) : Color(hex: "E5E7EB")
                        ) {
                            toggleSaveQRCode()
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSaved)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
        }
        .onAppear() {
            if !apphudManager.hasPremium {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isAdvertisment = true
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = qrCodeImage {
                ShareSheet(items: [image])
            }
        }
        .fullScreenCover(isPresented: $isAdvertisment) {
            AdLoadingScreen(adManager: adManager)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Text(Localization.CreateQR.title)
                .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                .foregroundColor(Color(hex: "000000"))
            
            Spacer()
            
            Button {
                onClose?()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E5E7EB"))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .foregroundStyle(Color(hex: "FFFFFF"))
                .ignoresSafeArea()
        )
    }
    
    // MARK: - Content Type Section
    private var contentTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Localization.CreateQR.contentType)
                .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                .foregroundColor(.black)
            
            // First row
            HStack(spacing: 12) {
                ContentTypeButton(
                    icon: "link",
                    title: Localization.CreateQR.url,
                    isSelected: selectedContentType == .url
                ) {
                    selectedContentType = .url
                }
                
                ContentTypeButton(
                    icon: "textformat",
                    title: Localization.CreateQR.text,
                    isSelected: selectedContentType == .text
                ) {
                    selectedContentType = .text
                }
                
                ContentTypeButton(
                    icon: "person.fill",
                    title: Localization.CreateQR.contact,
                    isSelected: selectedContentType == .contact
                ) {
                    selectedContentType = .contact
                }
            }
            

                ContentTypeButton(
                    icon: "wifi",
                    title: Localization.CreateQR.wifi,
                    isSelected: selectedContentType == .wifi
                ) {
                    selectedContentType = .wifi
                }
                
            
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // QR Code Name Field (common for all types)
            VStack(alignment: .leading, spacing: 8) {
                Text(Localization.CreateQR.qrCodeName)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(.black)
                
                TextField(Localization.CreateQR.qrCodeNamePlaceholder, text: $qrName)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .qrName)
            }
            
            switch selectedContentType {
            case .url:
                urlInputView
            case .text:
                textInputView
            case .contact:
                contactInputView
            case .wifi:
                wifiInputView
            }
        }
    }
    
    private var urlInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Localization.CreateQR.websiteURL)
                .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                .foregroundColor(.black)
            
            HStack {
                TextField(Localization.CreateQR.websiteURLPlaceholder, text: $urlText)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                    .foregroundColor(.black)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                    .focused($focusedField, equals: .urlText)
                
                Image(systemName: "link")
                    .foregroundColor(Color(hex: "B0B0B0"))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Localization.CreateQR.textContent)
                .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                .foregroundColor(.black)
            
            ZStack(alignment: .topLeading) {
                if plainText.isEmpty {
                    Text(Localization.CreateQR.textContentPlaceholder)
                        .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                        .foregroundColor(Color(hex: "B0B0B0"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $plainText)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                    .foregroundColor(.black)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .plainText)
                    .scrollContentBackground(.hidden)
            }
        }
    }
    
    private var contactInputView: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(Localization.CreateQR.name)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(.black)
                
                TextField(Localization.CreateQR.namePlaceholder, text: $contactName)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .contactName)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(Localization.CreateQR.phone)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(.black)
                
                TextField(Localization.CreateQR.phonePlaceholder, text: $contactPhone)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                    .foregroundColor(.black)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .contactPhone)
            }
        }
    }
    
    private var wifiInputView: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(Localization.CreateQR.networkName)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(.black)
                
                TextField(Localization.CreateQR.networkNamePlaceholder, text: $wifiSSID)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .wifiSSID)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(Localization.CreateQR.password)
                    .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                    .foregroundColor(.black)
                
                TextField(Localization.CreateQR.passwordPlaceholder, text: $wifiPassword)
                    .font(.custom(FontEnum.interRegular.rawValue, size: 15))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .wifiPassword)
            }
        }
    }
    
    // MARK: - Design Section
    private var designSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Localization.CreateQR.designOptions)
                .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                .foregroundColor(.black)
            
            VStack(spacing: 12) {
                HStack {
                    Text(Localization.CreateQR.color)
                        .font(.custom(FontEnum.interMedium.rawValue, size: 15))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        ColorButton(color: .black, isSelected: selectedColor == .black) {
                            selectedColor = .black
                        }
                        ColorButton(color: .blue, isSelected: selectedColor == .blue) {
                            selectedColor = .blue
                        }
                        ColorButton(color: .green, isSelected: selectedColor == .green) {
                            selectedColor = .green
                        }
                        ColorButton(color: .orange, isSelected: selectedColor == .orange) {
                            selectedColor = .orange
                        }
                    }
                }
                
                Divider()
                
                Button {
                    if apphudManager.hasPremium {
                        showImagePicker = true
                    } else {
                        showPaywall = true
                    }
                    
                } label: {
                    HStack {
                        Text(Localization.CreateQR.addLogo)
                            .font(.custom(FontEnum.interMedium.rawValue, size: 15))
                            .foregroundColor(.black)
                        
                        Spacer()
                        if apphudManager.hasPremium {
                            if let logo = logoImage {
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "F2F2F7"))
                                            .frame(width: 36, height: 36)
                                        
                                        Image(uiImage: logo)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                    }
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            logoImage = nil
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color(hex: "8E8E93"))
                                            .font(.system(size: 20))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(Color(hex: "5AC8FA"))
                                    .font(.system(size: 16))
                            }
                        } else {
                            Text("Pro Feature")
                                .foregroundStyle(Color(hex: "5A5A5A"))
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13.0))
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoLibraryPicker(isPresented: $showImagePicker) { selectedImage in
                // Optimize logo quality before storing
                logoImage = optimizeLogoImage(selectedImage)
            }
        }
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        Button {
            generateQRCode()
        } label: {
            Text(Localization.CreateQR.generateButton)
                .font(.custom(FontEnum.interSemiBold.rawValue, size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "5AC8FA"), Color(hex: "4A9FE8")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Functions
    private func generateQRCode() {
        let content = getContentString()
        guard !content.isEmpty else { return }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(content.utf8)
        // Use high error correction if logo is present
        filter.correctionLevel = logoImage != nil ? "H" : "M"
        
        if let outputImage = filter.outputImage {
            // Increase scale for higher quality (20x instead of 10x)
            let transform = CGAffineTransform(scaleX: 20, y: 20)
            let scaledImage = outputImage.transformed(by: transform)
            
            // Apply color
            if let colorFilter = CIFilter(name: "CIFalseColor") {
                colorFilter.setValue(scaledImage, forKey: "inputImage")
                colorFilter.setValue(CIColor(color: selectedColor.uiColor), forKey: "inputColor0")
                colorFilter.setValue(CIColor(color: .white), forKey: "inputColor1")
                
                if let coloredImage = colorFilter.outputImage,
                   let cgImage = context.createCGImage(coloredImage, from: coloredImage.extent) {
                    var finalImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
                    
                    // Add logo if available
                    if let logo = logoImage {
                        finalImage = addLogoToQRCode(qrImage: finalImage, logo: logo)
                    }
                    
                    qrCodeImage = finalImage
                    
                    // Reset saved state for new QR code
                    isSaved = false
                    savedQRCodeID = nil
                    
                    withAnimation(.spring()) {
                        showSuccess = true
                    }
                }
            }
        }
    }
    
    private func addLogoToQRCode(qrImage: UIImage, logo: UIImage) -> UIImage {
        let qrSize = qrImage.size
        // Logo will be 25% of QR code size
        let logoSize = CGSize(width: qrSize.width * 0.25, height: qrSize.height * 0.25)
        let logoX = (qrSize.width - logoSize.width) / 2
        let logoY = (qrSize.height - logoSize.height) / 2
        
        // Use higher scale for better quality
        let scale = max(qrImage.scale, UIScreen.main.scale)
        UIGraphicsBeginImageContextWithOptions(qrSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return qrImage
        }
        
        // Enable high quality rendering
        context.interpolationQuality = .high
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        // Draw QR code
        qrImage.draw(in: CGRect(origin: .zero, size: qrSize))
        
        // Calculate background dimensions
        let backgroundPadding: CGFloat = 12
        let backgroundSize = logoSize.width + backgroundPadding * 2
        let backgroundRect = CGRect(
            x: logoX - backgroundPadding,
            y: logoY - backgroundPadding,
            width: backgroundSize,
            height: backgroundSize
        )
        
        // Draw shadow
        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: 3),
            blur: 8,
            color: UIColor.black.withAlphaComponent(0.3).cgColor
        )
        
        // Draw white circular background
        UIColor.white.setFill()
        let backgroundPath = UIBezierPath(ovalIn: backgroundRect)
        backgroundPath.fill()
        context.restoreGState()
        
        // Draw subtle border around white circle
        context.saveGState()
        UIColor(white: 0.9, alpha: 1.0).setStroke()
        let borderPath = UIBezierPath(ovalIn: backgroundRect)
        borderPath.lineWidth = 1.5
        borderPath.stroke()
        context.restoreGState()
        
        // Prepare high-quality logo
        let resizedLogo = resizeImageHighQuality(logo, targetSize: logoSize)
        
        // Clip logo to circle and draw with high quality
        let logoRect = CGRect(x: logoX, y: logoY, width: logoSize.width, height: logoSize.height)
        
        context.saveGState()
        UIBezierPath(ovalIn: logoRect).addClip()
        
        // Draw with high quality interpolation
        context.interpolationQuality = .high
        resizedLogo.draw(in: logoRect)
        
        context.restoreGState()
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? qrImage
    }
    
    private func resizeImageHighQuality(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine what our final size will be
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Use higher scale for better quality
        let scale = max(UIScreen.main.scale, 3.0)
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }
        
        // Set high quality rendering
        context.interpolationQuality = .high
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        image.draw(in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func optimizeLogoImage(_ image: UIImage) -> UIImage {
        // Set optimal size for logo (512x512 is good for QR codes)
        let optimalSize: CGFloat = 512
        
        // If image is already small, return as is
        guard max(image.size.width, image.size.height) > optimalSize else {
            return applySharpenFilter(to: image)
        }
        
        // Resize to optimal size maintaining aspect ratio
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = optimalSize / image.size.width
        } else {
            scale = optimalSize / image.size.height
        }
        
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        // Use high quality rendering
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let optimizedImage = renderer.image { context in
            context.cgContext.interpolationQuality = .high
            context.cgContext.setShouldAntialias(true)
            context.cgContext.setAllowsAntialiasing(true)
            
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        // Apply sharpening filter
        return applySharpenFilter(to: optimizedImage)
    }
    
    private func applySharpenFilter(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // Apply sharpness filter
        let sharpenFilter = CIFilter(name: "CISharpenLuminance")
        sharpenFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        sharpenFilter?.setValue(0.5, forKey: kCIInputSharpnessKey) // Moderate sharpening
        
        guard let outputImage = sharpenFilter?.outputImage else { return image }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    private func getContentString() -> String {
        switch selectedContentType {
        case .url:
            return urlText
        case .text:
            return plainText
        case .contact:
            return "BEGIN:VCARD\nVERSION:3.0\nFN:\(contactName)\nTEL:\(contactPhone)\nEND:VCARD"
        case .wifi:
            return "WIFI:T:\(wifiSecurity.rawValue);S:\(wifiSSID);P:\(wifiPassword);;"
        }
    }
    
    private func toggleSaveQRCode() {
        guard let image = qrCodeImage else { return }
        
        if isSaved, let id = savedQRCodeID {
            // Delete from saved QR codes
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                MyQRCodesManager.shared.deleteQRCode(id: id)
                isSaved = false
                savedQRCodeID = nil
            }
            
            // Show haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        } else {
            // Save to My QR Codes
            let qrType: MyQRCodeItem.QRCodeContentType
            switch selectedContentType {
            case .url:
                qrType = .url
            case .text:
                qrType = .text
            case .contact:
                qrType = .contact
            case .wifi:
                qrType = .wifi
            }
            
            // Generate default name if not provided
            let name = qrName.isEmpty ? "QR Code \(Date().formatted(date: .abbreviated, time: .shortened))" : qrName
            let content = getContentString()
            
            // Convert image to data
            guard let imageData = image.pngData() else { return }
            
            // Create QR code item to get its ID
            let newQRCode = MyQRCodeItem(
                id: UUID(),
                name: name,
                content: content,
                qrImageData: imageData,
                createdDate: Date(),
                type: qrType
            )
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                // Save the QR code
                MyQRCodesManager.shared.myQRCodes.insert(newQRCode, at: 0)
                MyQRCodesManager.shared.saveToUserDefaults()
                
                isSaved = true
                savedQRCodeID = newQRCode.id
            }
            
            // Show success feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}





// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    AddNewQR()
}
