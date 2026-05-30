import Foundation

/// Plan-limit configuration. Anthropic doesn't publish per-tier token limits and
/// doubled them in May 2026, so HowlAlert never hard-codes a limit: it auto-
/// detects from the user's own history (P90) and accepts a remote `limits.json`
/// override. The values here come from the caller (a bundled default merged with
/// the remote file) — the estimator itself contains no magic numbers.
public struct LimitsConfig: Sendable, Codable, Equatable {
    /// Explicit session token limit. When set (e.g. from remote `limits.json`),
    /// it wins outright and no estimation happens.
    public var sessionTokenLimit: Int?
    /// Minimum completed windows before the P90 estimate is trusted.
    public var minSamples: Int
    /// Used until enough history exists, or as a floor under a low estimate.
    public var fallbackLimit: Int

    public init(sessionTokenLimit: Int? = nil, minSamples: Int = 5, fallbackLimit: Int) {
        self.sessionTokenLimit = sessionTokenLimit
        self.minSamples = max(1, minSamples)
        self.fallbackLimit = max(1, fallbackLimit)
    }
}

/// Estimates the session token limit from observed usage.
public enum PlanLimitEstimator {
    /// Resolve the effective session limit.
    ///
    /// Precedence: an explicit `sessionTokenLimit` override → otherwise the P90
    /// of completed-window totals once `minSamples` exist → otherwise the
    /// `fallbackLimit`. The P90 is floored at `fallbackLimit` so a quiet stretch
    /// of light windows can't drag the limit below the known baseline.
    public static func estimateSessionLimit(
        completedBlockTotals totals: [Int],
        config: LimitsConfig
    ) -> Int {
        if let pinned = config.sessionTokenLimit { return pinned }
        guard totals.count >= config.minSamples else { return config.fallbackLimit }
        let p90 = Percentile.value(totals.map(Double.init), 0.90)
        return max(Int(p90.rounded()), config.fallbackLimit)
    }
}
