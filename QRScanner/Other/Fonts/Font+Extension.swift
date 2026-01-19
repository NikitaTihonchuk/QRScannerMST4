import SwiftUI

extension Font {
    // MARK: - Inter Font Family
    
    /// Inter Thin
    static func interThin(size: CGFloat) -> Font {
        return .custom(FontEnum.interThin.rawValue, size: size)
    }
    
    /// Inter ExtraLight
    static func interExtraLight(size: CGFloat) -> Font {
        return .custom(FontEnum.interExtraLight.rawValue, size: size)
    }
    
    /// Inter Light
    static func interLight(size: CGFloat) -> Font {
        return .custom(FontEnum.interLight.rawValue, size: size)
    }
    
    /// Inter Regular
    static func interRegular(size: CGFloat) -> Font {
        return .custom(FontEnum.interRegular.rawValue, size: size)
    }
    
    /// Inter Medium
    static func interMedium(size: CGFloat) -> Font {
        return .custom(FontEnum.interMedium.rawValue, size: size)
    }
    
    /// Inter SemiBold
    static func interSemiBold(size: CGFloat) -> Font {
        return .custom(FontEnum.interSemiBold.rawValue, size: size)
    }
    
    /// Inter Bold
    static func interBold(size: CGFloat) -> Font {
        return .custom(FontEnum.interBold.rawValue, size: size)
    }
    
    /// Inter ExtraBold
    static func interExtraBold(size: CGFloat) -> Font {
        return .custom(FontEnum.interExtraBold.rawValue, size: size)
    }
    
    /// Inter Black
    static func interBlack(size: CGFloat) -> Font {
        return .custom(FontEnum.interBlack.rawValue, size: size)
    }
}
