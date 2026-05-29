import CoreGraphics

/// Spacing scale (pt) — design-system.html --space-1 ... --space-10.
public enum HowlSpacing {
    public static let s1: CGFloat = 4
    public static let s2: CGFloat = 8
    public static let s3: CGFloat = 12
    public static let s4: CGFloat = 16
    public static let s5: CGFloat = 20
    public static let s6: CGFloat = 24
    public static let s7: CGFloat = 28
    public static let s8: CGFloat = 32
    public static let s9: CGFloat = 36
    public static let s10: CGFloat = 40
}

/// Corner radii (pt) — design-system.html --radius-*.
public enum HowlRadius {
    public static let sm: CGFloat = 6
    public static let md: CGFloat = 10
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    /// Fully rounded (capsule).
    public static let pill: CGFloat = 9999
}
