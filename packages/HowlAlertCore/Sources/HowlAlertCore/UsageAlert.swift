import Foundation

/// A usage-window alert worth surfacing to the user as a local notification.
public enum UsageAlert: Sendable, Equatable {
    case low        // crossed into the warn band
    case almostOut  // crossed into the crit band
}

/// Which crossings the user wants to be notified about (mirrors the Settings
/// toggles `notifyLow` / `notifyAlmostOut`).
public struct AlertPreferences: Sendable, Equatable {
    public var low: Bool
    public var almostOut: Bool

    public init(low: Bool = true, almostOut: Bool = true) {
        self.low = low
        self.almostOut = almostOut
    }
}

public extension UsageState {
    /// Ordering for "did usage get worse?" comparisons. Higher = closer to empty.
    var severity: Int {
        switch self {
        case .fresh: 0
        case .ok: 1
        case .warn: 2
        case .crit: 3
        }
    }
}

/// Pure decision for the menu-bar app's local-notification logic.
///
/// Fires an alert only when usage crosses *up* into a more severe band (so it
/// never repeats while sitting at the same level), gated by `preferences`. When
/// usage eases off it lowers the baseline so the next rise can fire again, and a
/// `nil` `previous` (first observation) seeds silently.
///
/// - Returns: the `alert` to post (if any) and the `baseline` state the caller
///   should remember for the next call. The baseline advances on every rise even
///   if the matching preference is off, so a muted crossing isn't re-evaluated.
public func usageAlert(
    previous: UsageState?,
    current: UsageState,
    preferences: AlertPreferences = .init()
) -> (alert: UsageAlert?, baseline: UsageState) {
    guard let previous else { return (nil, current) }          // seed: no alert on first observation
    if current.severity < previous.severity { return (nil, current) }   // eased off → re-arm
    guard current.severity > previous.severity else { return (nil, previous) }  // no rise

    let alert: UsageAlert?
    switch current {
    case .crit: alert = preferences.almostOut ? .almostOut : nil
    case .warn: alert = preferences.low ? .low : nil
    case .ok, .fresh: alert = nil
    }
    return (alert, current)
}
