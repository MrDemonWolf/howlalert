import Foundation

/// Usage severity, driving state-colored UI. Thresholds are on the fraction of
/// the window *remaining* (16% remaining = `.warn`, matching the design refs).
/// Initial bands — tune as real usage data arrives.
public enum UsageState: Sendable, Equatable {
    case fresh   // barely touched, just reset
    case ok
    case warn
    case crit

    public static func from(fractionRemaining r: Double) -> UsageState {
        switch r {
        case let x where x >= 0.85: .fresh
        case let x where x >= 0.50: .ok
        case let x where x >= 0.10: .warn
        default: .crit
        }
    }
}

/// A computed view of the current 5-hour window: how much is used, when it
/// resets, and when usage is projected to run out at the current burn rate.
public struct UsageSnapshot: Sendable, Equatable {
    public let windowStart: Date
    public let resetsAt: Date
    public let lastActivity: Date
    public let now: Date
    public let tokensUsed: Int
    public let limit: Int
    /// Linear burn-rate projection of when usage hits the limit. `nil` when there
    /// isn't enough elapsed time to project.
    public let projectedRunOut: Date?

    public init(
        windowStart: Date,
        resetsAt: Date,
        lastActivity: Date,
        now: Date,
        tokensUsed: Int,
        limit: Int,
        projectedRunOut: Date?
    ) {
        self.windowStart = windowStart
        self.resetsAt = resetsAt
        self.lastActivity = lastActivity
        self.now = now
        self.tokensUsed = tokensUsed
        self.limit = limit
        self.projectedRunOut = projectedRunOut
    }

    public var fractionUsed: Double {
        guard limit > 0 else { return 0 }
        return min(1, Double(tokensUsed) / Double(limit))
    }

    public var fractionRemaining: Double { max(0, 1 - fractionUsed) }

    public var state: UsageState { .from(fractionRemaining: fractionRemaining) }

    /// Seconds until the window resets (never negative).
    public var timeUntilReset: TimeInterval { max(0, resetsAt.timeIntervalSince(now)) }

    /// Whether the current pace lasts until the reset (vs running out first).
    public var willLastToReset: Bool {
        guard let runOut = projectedRunOut else { return true }
        return runOut >= resetsAt
    }
}

/// Top-level entry point: events in, snapshot out.
public enum UsageEngine {
    /// Compute the current-window snapshot.
    ///
    /// - Returns: `nil` when there's no active window (the latest window has
    ///   already reset) — the caller treats that as a fresh, full window.
    public static func snapshot(
        events: [UsageEvent],
        config: LimitsConfig,
        now: Date
    ) -> UsageSnapshot? {
        let deduped = ClaudeTranscriptParser.deduped(events)
        let limit = PlanLimitEstimator.estimateSessionLimit(
            completedBlockTotals: FiveHourWindow.completedBlockTotals(from: deduped, now: now),
            config: config
        )
        guard let block = FiveHourWindow.currentBlock(from: deduped, now: now) else { return nil }

        return UsageSnapshot(
            windowStart: block.start,
            resetsAt: block.end,
            lastActivity: block.lastActivity,
            now: now,
            tokensUsed: block.totalTokens,
            limit: limit,
            projectedRunOut: projectRunOut(used: block.totalTokens, limit: limit, start: block.start, now: now)
        )
    }

    /// Linear extrapolation: `rate = used / elapsed`, run-out when the remaining
    /// budget is consumed at that rate. `nil` if no time has elapsed or no usage.
    static func projectRunOut(used: Int, limit: Int, start: Date, now: Date) -> Date? {
        let elapsed = now.timeIntervalSince(start)
        guard elapsed > 0, used > 0 else { return nil }
        let remaining = Double(limit - used)
        if remaining <= 0 { return now }
        let rate = Double(used) / elapsed // tokens per second
        guard rate > 0 else { return nil }
        return now.addingTimeInterval(remaining / rate)
    }
}
