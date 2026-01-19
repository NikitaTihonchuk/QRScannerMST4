import SwiftUI

struct MultipleQRCodesSheet: View {
    let qrCodes: [String]
    @Binding var isPresented: Bool
    var onQRCodeSelected: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F5F5F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Multiple QR Codes Found")
                            .font(.custom(FontEnum.interSemiBold.rawValue, size: 22))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button {
                            isPresented = false
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(Color(hex: "E5E7EB"))
                                
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color(hex: "000000"))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    
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
                            Text("Found \(qrCodes.count) QR codes")
                                .font(.custom(FontEnum.interSemiBold.rawValue, size: 15))
                                .foregroundColor(Color(hex: "5A5A5A"))
                            
                            Text("Select one to view details")
                                .font(.custom(FontEnum.interRegular.rawValue, size: 13))
                                .foregroundColor(Color(hex: "B0B0B0"))
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // QR codes list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(qrCodes.enumerated()), id: \.offset) { index, code in
                                QRCodeListItem(
                                    qrCode: code,
                                    index: index + 1
                                )
                                .onTapGesture {
                                    onQRCodeSelected(code)
                                    isPresented = false
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
    }
}

#Preview {
    MultipleQRCodesSheet(
        qrCodes: [
            "https://www.example.com",
            "mailto:test@example.com",
            "tel:+1234567890"
        ],
        isPresented: .constant(true)
    ) { _ in }
}
