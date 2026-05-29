import SwiftUI

/// Hero depleting bar — large state-tinted percentage + glowing fill that shrinks as budget drains.
public struct CritBar: View {
    private let remaining: Double
    private let state: HowlState
    private let label: String?

    public init(remaining: Double, state: HowlState, label: String? = nil) {
        self.remaining = min(max(remaining, 0), 1)
        self.state = state
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: HowlSpacing.s2) {
            HStack(alignment: .firstTextBaseline, spacing: HowlSpacing.s2) {
                Text("\(Int(remaining * 100))%")
                    .font(HowlTypography.numeric(size: 40, weight: .bold))
                    .foregroundStyle(state.color)
                if let label {
                    Text(label)
                        .font(HowlTypography.caption)
                        .foregroundStyle(HowlColor.ink500)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(HowlColor.navy700)
                    Capsule()
                        .fill(state.color)
                        .frame(width: geo.size.width * remaining)
                        .shadow(color: state.color.opacity(0.6), radius: 8)
                        .animation(HowlMotion.bar, value: remaining)
                }
            }
            .frame(height: 12)
        }
    }
}
