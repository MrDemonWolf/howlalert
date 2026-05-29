import SwiftUI

/// Two stacked usage meters — e.g. 5-hour session window over weekly budget.
public struct TwoBarMeter: View {
    private let session: Double
    private let sessionState: HowlState
    private let week: Double
    private let weekState: HowlState

    public init(session: Double, sessionState: HowlState, week: Double, weekState: HowlState) {
        self.session = session
        self.sessionState = sessionState
        self.week = week
        self.weekState = weekState
    }

    public var body: some View {
        VStack(spacing: HowlSpacing.s2) {
            UsageMeter(remaining: session, state: sessionState)
            UsageMeter(remaining: week, state: weekState)
        }
    }
}
