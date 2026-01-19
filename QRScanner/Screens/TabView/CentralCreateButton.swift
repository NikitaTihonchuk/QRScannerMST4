import SwiftUI

struct CentralCreateButton: View {
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "77C97E"))
                .frame(width: 64, height: 64)
                .shadow(color: Color(hex: "77C97E"), radius: 12, x: 0, y: 4)
            
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color(hex: "FFFFFF"))
                .fontWeight(.semibold)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        
    }
}
