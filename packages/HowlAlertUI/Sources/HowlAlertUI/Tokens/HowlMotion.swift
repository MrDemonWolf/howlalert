import SwiftUI

/// Motion tokens — design-system.html spring / linear / pulse.
public enum HowlMotion {
    /// State transitions (meters, chips re-tinting).
    public static let spring = Animation.spring(response: 0.4, dampingFraction: 0.82)
    /// Bar fills / value tweens.
    public static let bar = Animation.easeInOut(duration: 0.25)
    /// Critical / last-minute pulse — apply to crit icons and final-minute countdowns.
    public static let pulse = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
}
