// StateIcon.swift
//
// Small state-tinted glyph used in headers and notifications. Uses SF Symbols
// to stay crisp on Retina + Live Activity contexts. Never use raw hex —
// every color reads from UsageState.

import SwiftUI

public struct StateIcon: View {
    private let state: UsageState
    private let size: CGFloat

    public init(state: UsageState, size: CGFloat = 14) {
        self.state = state
        self.size = size
    }

    public var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(state.color)
            .accessibilityLabel("Status \(state.rawValue)")
    }

    private var symbol: String {
        switch state {
        case .fresh: return "sparkle"
        case .ok:    return "checkmark.circle.fill"
        case .warn:  return "exclamationmark.triangle.fill"
        case .crit:  return "exclamationmark.octagon.fill"
        }
    }
}
