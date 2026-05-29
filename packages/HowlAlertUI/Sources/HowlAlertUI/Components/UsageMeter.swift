import SwiftUI

/// Depleting usage bar with an optional white pace marker (the "racing the limit" line).
/// `remaining` is the fraction of budget left (1 = full, 0 = empty); the fill shrinks as it depletes.
public struct UsageMeter: View {
    private let remaining: Double
    private let pace: Double?
    private let state: HowlState

    public init(remaining: Double, pace: Double? = nil, state: HowlState) {
        self.remaining = min(max(remaining, 0), 1)
        self.pace = pace.map { min(max($0, 0), 1) }
        self.state = state
    }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(HowlColor.navy700)
                Capsule()
                    .fill(state.color)
                    .frame(width: w * remaining)
                    .animation(HowlMotion.bar, value: remaining)
                if let pace {
                    Rectangle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 2)
                        .offset(x: (w * pace) - 1)
                }
            }
        }
        .frame(height: 8)
        .accessibilityElement()
        .accessibilityLabel("Usage remaining")
        .accessibilityValue("\(Int(remaining * 100)) percent")
    }
}
