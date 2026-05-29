import SwiftUI

/// Small state-tinted capsule for pace / status text ("On pace", "Runs out in 47m").
public struct PaceChip: View {
    private let text: String
    private let state: HowlState

    public init(_ text: String, state: HowlState) {
        self.text = text
        self.state = state
    }

    public var body: some View {
        Text(text)
            .font(HowlTypography.callout)
            .foregroundStyle(state.color)
            .padding(.horizontal, HowlSpacing.s3)
            .padding(.vertical, HowlSpacing.s1)
            .background(Capsule().fill(state.color.opacity(0.16)))
            .overlay(Capsule().strokeBorder(state.color.opacity(0.35), lineWidth: 1))
    }
}
