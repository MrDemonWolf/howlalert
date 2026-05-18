// CritBar.swift
//
// Single pill-shaped progress bar. Matches `.critbar` in
// docs/design/HowlAlert.html section A6 (lines 280–310). Width animates
// linearly over 250ms (HowlMotion.progressFill).

import SwiftUI

public struct CritBar: View {
    public enum Size: Sendable {
        case compact   // 6pt
        case `default` // 14pt
        case large     // 22pt

        var height: CGFloat {
            switch self {
            case .compact: return 6
            case .default: return 14
            case .large:   return 22
            }
        }
    }

    private let percentUsed: Double
    private let state: UsageState
    private let size: Size

    public init(percentUsed: Double, state: UsageState, size: Size = .default) {
        self.percentUsed = max(0, min(1, percentUsed))
        self.state = state
        self.size = size
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.06))
                Capsule()
                    .fill(state.color)
                    .frame(width: geo.size.width * percentUsed)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                            .blendMode(.plusLighter)
                            .opacity(0.5)
                    )
                    .animation(HowlMotion.progressFill, value: percentUsed)
                    .animation(HowlMotion.stateChange, value: state)
            }
        }
        .frame(height: size.height)
        .accessibilityElement()
        .accessibilityLabel("Usage")
        .accessibilityValue("\(Int(percentUsed * 100)) percent")
    }
}
