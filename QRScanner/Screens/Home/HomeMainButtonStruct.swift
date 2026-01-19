import SwiftUI

struct HomeMainButtonStruct: Identifiable {
    var id: Int
    var title: String
    var subtitle: String
    var mainImage: String
    
    
    static var homeMainButton: [HomeMainButtonStruct] = [
        HomeMainButtonStruct(
            id: 1,
            title: Localization.Home.scanQR,
            subtitle: Localization.Home.scanQRSubtitle,
            mainImage: "scanQRImage"
        ),
        HomeMainButtonStruct(
            id: 4, title: Localization.Home.createQR,
            subtitle: Localization.Home.createQRSubtitle,
            mainImage: "createQRImage"
        ),
        HomeMainButtonStruct(
            id: 2, title: Localization.Home.myQRCodes,
            subtitle: Localization.Home.myQRCodesSubtitle,
            mainImage: "myQRCodes"
        ),
        HomeMainButtonStruct(
            id: 3, title: Localization.Home.history,
            subtitle: Localization.Home.historySubtitle,
            mainImage: "historyImage"
        )
    ]
}
