// TwoBarMeter.swift
//
// Two stacked CritBars used in the macOS popover:
//   - "Window"  — current usage of the 5h Claude Code window.
//   - "Pace"    — projected end-of-window usage at current rate.
// Pace bar is rendered slightly muted to read as "forecast".

import SwiftUI

public struct TwoBarMeter: View {
    public struct Reading: Sendable, Equatable {
        public let percentUsed: Double
        public let percentProjected: Double
        public let state: UsageState
        public let projectedState: UsageState

        public init(percentUsed: Double, percentProjected: Double, state: UsageState, projectedState: UsageState) {
            self.percentUsed = percentUsed
            self.percentProjected = percentProjected
            self.state = state
            self.projectedState = projectedState
        }
    }

    private let reading: Reading

    public init(reading: Reading) {
        self.reading = reading
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: HowlSpacing.s2) {
            row(label: "Window", percent: reading.percentUsed, state: reading.state, prominent: true)
            row(label: "Pace",   percent: reading.percentProjected, state: reading.projectedState, prominent: false)
        }
    }

    @ViewBuilder
    private func row(label: String, percent: Double, state: UsageState, prominent: Bool) -> some View {
        HStack(spacing: HowlSpacing.s3) {
            Text(label.uppercased())
                .font(.howlMicro)
                .foregroundStyle(Color.howlInk500)
                .frame(width: 48, alignment: .leading)
            CritBar(percentUsed: percent, state: state, size: prominent ? .default : .compact)
            Text("\(Int((max(0, min(1, percent))) * 100))%")
                .font(.howlCaption)
                .monospacedDigit()
                .foregroundStyle(prominent ? Color.howlInk100 : Color.howlInk300)
                .frame(width: 44, alignment: .trailing)
        }
    }
}
