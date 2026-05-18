// PlanLimitEstimator.swift
//
// P90 plan-limit auto-detection. Per PLAN.md §4 + CLAUDE.md §8.9:
//   - planLimit = P90 over the last 30 days of completed windows.
//   - Fallback to bundled `limits.json` when local history has <7 windows.
//   - Never hard-code plan limits — Claude doubled in May 2026 and may move again.

import Foundation

public struct PlanLimitEstimator: Sendable {
    /// Minimum sample size before P90 is trustworthy.
    public static let minSamples = 7

    /// Lookback window in days.
    public static let lookbackDays = 30

    public let now: @Sendable () -> Date

    public init(now: @escaping @Sendable () -> Date = { Date() }) {
        self.now = now
    }

    /// Estimate the current plan limit.
    /// - Parameters:
    ///   - completedWindowTotals: each completed window's *total request count*.
    ///   - completedWindowEnds:   end-date for each window, paired by index.
    ///   - fallback: limit pulled from remote `limits.json` (always defined).
    /// - Returns: P90 of in-window totals, or `fallback` when sample is too small.
    public func estimate(
        completedWindowTotals: [Int],
        completedWindowEnds: [Date],
        fallback: Int
    ) -> Int {
        precondition(
            completedWindowTotals.count == completedWindowEnds.count,
            "totals and ends must align"
        )
        let cutoff = now().addingTimeInterval(-Double(Self.lookbackDays) * 86_400)
        var recent: [Int] = []
        recent.reserveCapacity(completedWindowTotals.count)
        for (total, end) in zip(completedWindowTotals, completedWindowEnds) where end >= cutoff {
            recent.append(total)
        }
        guard recent.count >= Self.minSamples else { return fallback }
        return Self.percentile(recent, p: 0.90)
    }

    /// Linear-interpolated percentile (Type 7 — Excel / numpy default).
    static func percentile(_ values: [Int], p: Double) -> Int {
        let sorted = values.sorted()
        guard !sorted.isEmpty else { return 0 }
        if sorted.count == 1 { return sorted[0] }
        let rank = p * Double(sorted.count - 1)
        let lower = Int(rank.rounded(.down))
        let upper = Int(rank.rounded(.up))
        if lower == upper { return sorted[lower] }
        let weight = rank - Double(lower)
        let interp = Double(sorted[lower]) * (1 - weight) + Double(sorted[upper]) * weight
        return Int(interp.rounded())
    }
}
