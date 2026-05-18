// HowlMotion.swift
//
// Motion tokens from the Claude Design bundle (HowlAlert.html section A4 — Motion).
//
//   State change   spring(response: 0.4, damping: 0.8)
//   Progress fill  linear · 250ms
//   Reset pulse    pulse 1s, last 60s of window
//   Celebrate      cyan glow 4s on reset

import SwiftUI

public enum HowlMotion {
    /// Spring used for any state transition (idle → warn → crit, popover open).
    public static let stateChange: Animation = .spring(response: 0.4, dampingFraction: 0.8)

    /// Linear fill used for progress bar growth.
    public static let progressFill: Animation = .linear(duration: 0.25)

    /// Pulse used in the last 60 seconds of a window.
    public static let resetPulse: Animation = .easeInOut(duration: 1.0).repeatForever(autoreverses: true)

    /// Cyan glow that flashes briefly when a window resets.
    public static let celebrateDuration: Double = 4.0
}
