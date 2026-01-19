import Foundation

struct TabViewStruct: Identifiable {
    var id = UUID()
    var text: String
    var iconOff: String
    var iconOn: String
    
    static var tabs: [TabViewStruct] = [
        TabViewStruct(
            text: Localization.TabView.home,
            iconOff: "homeIconOff",
            iconOn: "homeIconOn"
        ),
        TabViewStruct(
            text: Localization.TabView.scanQR,
            iconOff: "scanIconOff",
            iconOn: "scanIconOn"
        ),
        TabViewStruct(
            text: Localization.TabView.myQRCodes,
            iconOff: "myQRCodesOff",
            iconOn: "myQRCodesOn"
        ),
        TabViewStruct(
            text: Localization.TabView.history,
            iconOff: "historyOff",
            iconOn: "historyOn"
        )
    ]
}
