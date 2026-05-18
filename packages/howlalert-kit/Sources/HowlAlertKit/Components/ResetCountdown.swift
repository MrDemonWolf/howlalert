// ResetCountdown.swift
//
// Natural-language ticker — "Runs out in 47m". Updates once per minute
// while > 1m remaining, then once per second in the final 60s with a pulse.
// Matches `.countdown` in docs/design/HowlAlert.html section A6 (lines 319–327).

import SwiftUI

public struct ResetCountdown: View {
    private let windowEnd: Date
    @State private var now: Date = .init()

    public init(windowEnd: Date) {
        self.windowEnd = windowEnd
    }

    public var body: some View {
        let remaining = max(0, windowEnd.timeIntervalSince(now))
        let pulse = remaining > 0 && remaining <= 60
        let celebrate = remaining <= 0

        VStack(alignment: .leading, spacing: 0) {
            Text("RUNS OUT IN")
                .font(.howlMicro)
                .tracking(1.4)
                .foregroundStyle(Color.howlInk500)
            Text(Self.format(remaining: remaining))
                .font(.system(size: 22, weight: .semibold).monospacedDigit())
                .foregroundStyle(
                    celebrate ? Color.howlCyan300 :
                    pulse    ? Color.howlStateWarn :
                    Color.howlInk100
                )
                .shadow(color: celebrate ? Color.howlCyan500.opacity(0.55) : .clear, radius: 18)
                .opacity(pulse ? pulsedOpacity : 1.0)
                .animation(pulse ? HowlMotion.resetPulse : .default, value: pulse)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            now = date
        }
        .accessibilityElement(children: .combine)
    }

    private var pulsedOpacity: Double { 0.55 }

    public static func format(remaining: TimeInterval) -> String {
        if remaining <= 0 { return "Reset!" }
        let total = Int(remaining.rounded(.up))
        if total < 60 { return "\(total)s" }
        let minutes = total / 60
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}
