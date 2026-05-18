// PaceChip.swift
//
// Small pill indicating projected pace vs. window budget. Matches `.pace`
// styling in docs/design/HowlAlert.html section A6 (lines 328–340).

import SwiftUI

public struct PaceChip: View {
    public enum Pace: String, Sendable, CaseIterable {
        case fresh   // window just reset
        case onPace  // projection lands ≤ 100%
        case ahead   // projection ≤ 80% — comfortable
        case behind  // projection > 100% — will blow the window

        public var label: String {
            switch self {
            case .fresh:  return "Fresh window"
            case .onPace: return "On pace"
            case .ahead:  return "Ahead of pace"
            case .behind: return "Behind pace"
            }
        }

        public var tint: Color {
            switch self {
            case .fresh:  return .howlStateFresh
            case .onPace: return .howlStateOK
            case .ahead:  return .howlCyan300
            case .behind: return .howlStateWarn
            }
        }
    }

    private let pace: Pace

    public init(_ pace: Pace) {
        self.pace = pace
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s2) {
            Circle()
                .fill(pace.tint)
                .frame(width: 6, height: 6)
            Text(pace.label)
                .font(.howlCaption)
                .foregroundStyle(pace.tint)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            Capsule().fill(pace.tint.opacity(0.10))
        )
        .overlay(
            Capsule().stroke(pace.tint.opacity(0.28), lineWidth: 1)
        )
        .accessibilityElement()
        .accessibilityLabel(pace.label)
    }
}
