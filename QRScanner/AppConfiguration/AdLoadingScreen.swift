import SwiftUI

struct AdLoadingScreen: View {

    @ObservedObject var adManager: FullScreenAdManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
        }
        .onAppear {
            // реклама уже загружена, просто показываем
            dismiss()
            DispatchQueue.main.async {
                adManager.show()
            }
        }
    }
}


