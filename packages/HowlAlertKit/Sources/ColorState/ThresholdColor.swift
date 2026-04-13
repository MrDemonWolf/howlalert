import Models

#if canImport(SwiftUI)
import SwiftUI

public enum ThresholdColor: Sendable {
    public static func color(for state: PaceState) -> Color {
        switch state {
        case .calm:     return Color(hex: "#0FACED")
        case .warn:     return .yellow
        case .critical: return .red
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
#endif

public enum CritBarColor: Sendable {
    public static func fraction(for state: PaceState) -> Double {
        switch state {
        case .calm:     return 0.3
        case .warn:     return 0.6
        case .critical: return 0.9
        }
    }
}
