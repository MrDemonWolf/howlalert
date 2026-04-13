// PaceCalculator — Pure debt/on-track/reserve math
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public struct PaceCalculator: Sendable {
    public init() {}

    /// Calculate pace state from aggregated usage.
    /// - Parameters:
    ///   - totalTokens: Combined billable tokens across all Macs
    ///   - limit: Token limit for the window
    ///   - windowStart: When the current window started
    ///   - windowEnd: When the current window ends
    ///   - now: Current time (injectable for testing)
    public func calculate(
        totalTokens: Int,
        limit: Int,
        windowStart: Date,
        windowEnd: Date,
        now: Date = .now
    ) -> PaceState {
        guard limit > 0 else {
            return PaceState(status: .limitHit, usagePercent: 100, windowEnd: windowEnd)
        }

        let usagePercent = Double(totalTokens) / Double(limit) * 100.0
        let windowDuration = windowEnd.timeIntervalSince(windowStart)
        let elapsed = now.timeIntervalSince(windowStart)

        guard windowDuration > 0, elapsed > 0 else {
            return PaceState(status: .freshReset, usagePercent: usagePercent, windowEnd: windowEnd)
        }

        let expectedPercent = (elapsed / windowDuration) * 100.0
        let debtPercent = usagePercent - expectedPercent

        if usagePercent >= 100 {
            return PaceState(
                status: .limitHit,
                usagePercent: min(usagePercent, 100),
                debtPercent: debtPercent,
                windowEnd: windowEnd
            )
        }

        let runoutMinutes = estimateRunout(
            totalTokens: totalTokens,
            limit: limit,
            elapsed: elapsed,
            windowDuration: windowDuration
        )

        if debtPercent > 5 {
            return PaceState(
                status: .inDebt,
                usagePercent: usagePercent,
                debtPercent: debtPercent,
                estimatedRunoutMinutes: runoutMinutes,
                windowEnd: windowEnd
            )
        } else if debtPercent < -10 {
            return PaceState(
                status: .inReserve,
                usagePercent: usagePercent,
                debtPercent: debtPercent,
                estimatedRunoutMinutes: runoutMinutes,
                windowEnd: windowEnd
            )
        } else {
            return PaceState(
                status: .onTrack,
                usagePercent: usagePercent,
                debtPercent: debtPercent,
                estimatedRunoutMinutes: runoutMinutes,
                windowEnd: windowEnd
            )
        }
    }

    private func estimateRunout(
        totalTokens: Int,
        limit: Int,
        elapsed: TimeInterval,
        windowDuration: TimeInterval
    ) -> Int? {
        guard totalTokens > 0, elapsed > 0 else { return nil }

        let rate = Double(totalTokens) / elapsed
        let remaining = Double(limit - totalTokens)

        guard rate > 0, remaining > 0 else {
            return remaining <= 0 ? 0 : nil
        }

        let secondsUntilLimit = remaining / rate
        return max(0, Int(secondsUntilLimit / 60))
    }
}
