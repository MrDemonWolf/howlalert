// UsageState.swift
//
// Shared state machine for usage thresholds. Drives state colors on bars,
// chips, icons, and notifications. Derived from `percentUsed` once — never
// recomputed per component.

import SwiftUI

public enum UsageState: String, Sendable, CaseIterable, Codable {
    /// Just-reset window. Plenty of room.
    case fresh
    /// Normal operating range (under 80%).
    case ok
    /// 80% threshold crossed.
    case warn
    /// 95% threshold crossed.
    case crit

    /// Map a 0…1 percent-used value to a state.
    /// - Note: `fresh` is reserved for the first ~5 minutes of a window — derive
    ///   it elsewhere (`UsageWindow.elapsed`), not from percent alone.
    public static func from(percentUsed: Double) -> UsageState {
        let p = max(0, min(1, percentUsed))
        switch p {
        case ..<0.80: return .ok
        case ..<0.95: return .warn
        default:      return .crit
        }
    }

    /// Foreground color for state-tinted glyphs and text.
    public var color: Color {
        switch self {
        case .fresh: return .howlStateFresh
        case .ok:    return .howlStateOK
        case .warn:  return .howlStateWarn
        case .crit:  return .howlStateCrit
        }
    }
}
