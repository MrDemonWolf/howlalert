import SwiftUI

/// Reset countdown label. Pulses in the last minute; glows fresh just after a reset.
public struct ResetCountdown: View {
    private let text: String
    private let state: HowlState
    private let lastMinute: Bool

    @State private var pulsing = false

    public init(_ text: String, state: HowlState, lastMinute: Bool = false) {
        self.text = text
        self.state = state
        self.lastMinute = lastMinute
    }

    public var body: some View {
        Text(text)
            .font(HowlTypography.numeric(size: 18, weight: .semibold))
            .foregroundStyle(state.color)
            .opacity(lastMinute && pulsing ? 0.5 : 1)
            .shadow(color: state == .fresh ? HowlColor.stateFresh.opacity(0.6) : .clear, radius: 6)
            .onAppear {
                guard lastMinute else { return }
                withAnimation(HowlMotion.pulse) { pulsing = true }
            }
    }
}
