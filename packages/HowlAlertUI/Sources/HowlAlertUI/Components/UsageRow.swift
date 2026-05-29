import SwiftUI

/// Dense usage row — title + value, depleting meter with pace marker, dual metadata,
/// optional "in deficit / runs out" subline. The core building block of the popover.
public struct UsageRow: View {
    private let title: String
    private let remaining: Double
    private let pace: Double?
    private let state: HowlState
    private let trailingValue: String
    private let metaLeading: String
    private let deficit: String?

    public init(
        title: String,
        remaining: Double,
        pace: Double? = nil,
        state: HowlState,
        trailingValue: String,
        metaLeading: String,
        deficit: String? = nil
    ) {
        self.title = title
        self.remaining = remaining
        self.pace = pace
        self.state = state
        self.trailingValue = trailingValue
        self.metaLeading = metaLeading
        self.deficit = deficit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: HowlSpacing.s2) {
            HStack {
                Text(title).font(HowlTypography.callout).foregroundStyle(HowlColor.ink100)
                Spacer()
                Text(trailingValue).font(HowlTypography.numeric(size: 13)).foregroundStyle(state.color)
            }
            UsageMeter(remaining: remaining, pace: pace, state: state)
            HStack {
                Text(metaLeading).font(HowlTypography.micro).foregroundStyle(HowlColor.ink500)
                Spacer()
                if let deficit {
                    Text(deficit).font(HowlTypography.micro).foregroundStyle(HowlColor.stateWarn)
                }
            }
        }
    }
}
