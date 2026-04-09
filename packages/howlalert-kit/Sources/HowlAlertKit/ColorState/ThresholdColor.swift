import SwiftUI

public enum CritBarColor: Sendable {
    case normal      // cyan  #0FACED
    case approaching // amber #F5A623
    case critical    // red   #FF3B30
    case reset       // green #34C759

    public var color: Color {
        switch self {
        case .normal:      return Color(hex: "0FACED")
        case .approaching: return Color(hex: "F5A623")
        case .critical:    return Color(hex: "FF3B30")
        case .reset:       return Color(hex: "34C759")
        }
    }
}

public enum ThresholdColor {
    public static func color(for usagePercent: Double, justReset: Bool = false) -> CritBarColor {
        if justReset { return .reset }
        switch usagePercent {
        case ..<0.60:       return .normal
        case 0.60..<0.85:   return .approaching
        default:            return .critical
        }
    }
}

// MARK: - Color+Hex helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
