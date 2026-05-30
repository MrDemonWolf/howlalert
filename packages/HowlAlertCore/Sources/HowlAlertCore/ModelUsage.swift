import Foundation

/// Per-model usage over a recent span, with a small sparkline of token volume.
public struct ModelUsage: Sendable, Equatable {
    public let model: String
    public let totalTokens: Int
    /// Token totals bucketed across the span, oldest → newest (for a sparkline).
    public let sparkline: [Double]

    public init(model: String, totalTokens: Int, sparkline: [Double]) {
        self.model = model
        self.totalTokens = totalTokens
        self.sparkline = sparkline
    }
}

public extension UsageEngine {
    /// Top models by token volume within `span` of `now`, each with a bucketed
    /// sparkline. Events are deduped first. Ties break by model name for stable
    /// ordering.
    static func recentModels(
        events: [UsageEvent],
        now: Date,
        span: TimeInterval = FiveHourWindow.duration,
        buckets: Int = 7,
        top: Int = 3
    ) -> [ModelUsage] {
        let buckets = max(1, buckets)
        let start = now.addingTimeInterval(-span)
        let recent = ClaudeTranscriptParser.deduped(events).filter { $0.timestamp >= start && $0.timestamp <= now }
        guard !recent.isEmpty else { return [] }

        var totals: [String: Int] = [:]
        var bins: [String: [Double]] = [:]
        for event in recent {
            totals[event.model, default: 0] += event.totalTokens
            var line = bins[event.model] ?? Array(repeating: 0, count: buckets)
            let offset = event.timestamp.timeIntervalSince(start)
            let index = min(buckets - 1, max(0, Int(offset / span * Double(buckets))))
            line[index] += Double(event.totalTokens)
            bins[event.model] = line
        }

        return totals
            .map { ModelUsage(model: $0.key, totalTokens: $0.value, sparkline: bins[$0.key] ?? []) }
            .sorted { $0.totalTokens != $1.totalTokens ? $0.totalTokens > $1.totalTokens : $0.model < $1.model }
            .prefix(top)
            .map { $0 }
    }
}
