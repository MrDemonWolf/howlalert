import SwiftUI

public extension Color {
    /// Build a Color from a 0xRRGGBB hex literal in the sRGB space.
    init(howlHex hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

/// HowlAlert color tokens. Source of truth: design-system.html (Claude Design bundle).
/// Dark surfaces are navy; all text tokens are >= AA on navy-900.
public enum HowlColor {
    // Navy (surfaces)
    public static let navy900 = Color(howlHex: 0x091533)
    public static let navy800 = Color(howlHex: 0x0E1B42)
    public static let navy700 = Color(howlHex: 0x15275A)
    public static let navy600 = Color(howlHex: 0x1E3475)

    // Cyan (brand)
    public static let cyan500 = Color(howlHex: 0x0FACED)
    public static let cyan400 = Color(howlHex: 0x3DBEF1)
    public static let cyan300 = Color(howlHex: 0x7BD3F6)
    public static let cyan100 = Color(howlHex: 0xD5F0FB)

    // State
    public static let stateFresh = Color(howlHex: 0x3DDC97)
    public static let stateOk = Color(howlHex: 0x0FACED)
    public static let stateWarn = Color(howlHex: 0xFFA533)
    public static let stateCrit = Color(howlHex: 0xFF4D4D)

    // Ink on navy
    public static let ink100 = Color(howlHex: 0xF4F7FB)
    public static let ink300 = Color(howlHex: 0xA8B5CF)
    /// 7.5:1 AAA on navy-900. Do NOT change to 0x6A7A99 — that fails AA on dark.
    public static let ink500 = Color(howlHex: 0x9AA9C5)
    public static let ink700 = Color(howlHex: 0x3A4666)

    // Light mode mirror
    public static let lightSurface = Color(howlHex: 0xF8FAFE)
    public static let lightSurface2 = Color(howlHex: 0xECF1F8)
    public static let lightInk900 = Color(howlHex: 0x091533)
    public static let lightInk700 = Color(howlHex: 0x3A4666)
    public static let lightInk500 = Color(howlHex: 0x6A7A99)
    public static let lightDivider = Color(howlHex: 0xD6DEEB)
}

/// Usage state, drives state-colored UI (meters, chips, icons).
public enum HowlState: Sendable {
    case fresh, ok, warn, crit

    public var color: Color {
        switch self {
        case .fresh: HowlColor.stateFresh
        case .ok: HowlColor.stateOk
        case .warn: HowlColor.stateWarn
        case .crit: HowlColor.stateCrit
        }
    }
}
