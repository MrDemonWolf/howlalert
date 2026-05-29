import SwiftUI

/// Type scale (SF Pro / system). 7-step ramp from design-system.html.
/// Usage numbers use `numeric(...)` for tabular digits so countdowns don't jitter.
public enum HowlTypography {
    public static let display = Font.system(size: 34, weight: .bold)
    public static let title = Font.system(size: 28, weight: .semibold)
    public static let headline = Font.system(size: 20, weight: .semibold)
    public static let body = Font.system(size: 16, weight: .regular)
    public static let callout = Font.system(size: 14, weight: .medium)
    public static let caption = Font.system(size: 12, weight: .regular)
    public static let micro = Font.system(size: 10, weight: .medium)

    /// Tabular-figure font for percentages and reset countdowns.
    public static func numeric(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight).monospacedDigit()
    }
}
