import Foundation

// Pure pace math — no side effects, easily testable
public enum PaceCalculator {

    /// Calculate pace state for a usage window
    /// - Parameters:
    ///   - tokensUsed: tokens consumed so far
    ///   - effectiveLimit: total limit (base limit * multiplier)
    ///   - windowStart: when the billing window started
    ///   - windowDuration: total window duration (5h session or 7d weekly)
    ///   - now: current time (injectable for testing)
    /// - Returns: PaceState, or nil if insufficient time has elapsed (< 5 min)
    public static func calculate(
        tokensUsed: Int,
        effectiveLimit: Int,
        windowStart: Date,
        windowDuration: TimeInterval,
        now: Date = .now
    ) -> PaceState? {
        let elapsed = now.timeIntervalSince(windowStart)
        guard elapsed >= 300 else { return nil }  // need 5 min of data

        let progress = elapsed / windowDuration  // 0.0 to 1.0
        let expectedTokens = Double(effectiveLimit) * progress

        // Pace percent: positive = in debt (burning faster than expected)
        let pacePercent = (Double(tokensUsed) - expectedTokens) / Double(effectiveLimit) * 100

        if abs(pacePercent) < 2.0 {
            return PaceState(status: .onTrack, pacePercent: pacePercent, runsOutAt: nil)
        } else if pacePercent > 0 {
            // Burning faster than budget — project when tokens run out
            let burnRate = Double(tokensUsed) / elapsed  // tokens per second
            let remainingTokens = Double(effectiveLimit - tokensUsed)
            let secondsUntilEmpty = remainingTokens / burnRate
            let runsOutAt = now.addingTimeInterval(secondsUntilEmpty)
            return PaceState(status: .inDebt, pacePercent: pacePercent, runsOutAt: runsOutAt)
        } else {
            return PaceState(status: .inReserve, pacePercent: pacePercent, runsOutAt: nil)
        }
    }
}
