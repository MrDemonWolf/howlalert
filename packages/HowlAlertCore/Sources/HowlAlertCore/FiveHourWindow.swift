import Foundation

/// A 5-hour usage block — Claude Code's rolling session window.
public struct UsageBlock: Sendable, Equatable {
    /// First activity in the block (the window anchor).
    public let start: Date
    /// `start + 5h` — when this window resets.
    public let end: Date
    /// Last activity seen in the block.
    public let lastActivity: Date
    public let totalTokens: Int
    public let eventCount: Int

    public init(start: Date, end: Date, lastActivity: Date, totalTokens: Int, eventCount: Int) {
        self.start = start
        self.end = end
        self.lastActivity = lastActivity
        self.totalTokens = totalTokens
        self.eventCount = eventCount
    }

    /// True while `now` is inside `[start, end)`.
    public func isActive(at now: Date) -> Bool {
        now >= start && now < end
    }
}

/// Groups usage events into Claude's 5-hour rolling windows.
///
/// Anchored on first activity (not clock-aligned): a block opens at the first
/// event and runs 5 hours. A new block opens when an event lands past the
/// current block's end, or after a gap longer than the window from the previous
/// event (an idle stretch that long means the prior window has reset).
public enum FiveHourWindow {
    /// 5 hours, in seconds.
    public static let duration: TimeInterval = 5 * 60 * 60

    public static func blocks(from events: [UsageEvent]) -> [UsageBlock] {
        let sorted = events.sorted { $0.timestamp < $1.timestamp }
        guard !sorted.isEmpty else { return [] }

        var blocks: [UsageBlock] = []
        var start = sorted[0].timestamp
        var last = start
        var tokens = 0
        var count = 0

        func close() {
            blocks.append(UsageBlock(
                start: start,
                end: start.addingTimeInterval(duration),
                lastActivity: last,
                totalTokens: tokens,
                eventCount: count
            ))
        }

        for event in sorted {
            let t = event.timestamp
            let pastWindow = t >= start.addingTimeInterval(duration)
            let longGap = t.timeIntervalSince(last) > duration
            if count > 0 && (pastWindow || longGap) {
                close()
                start = t
                tokens = 0
                count = 0
            }
            last = t
            tokens += event.totalTokens
            count += 1
        }
        close()
        return blocks
    }

    /// The block whose window currently contains `now`, if any. Returns `nil`
    /// when the latest window has already reset (no active session).
    public static func currentBlock(from events: [UsageEvent], now: Date) -> UsageBlock? {
        blocks(from: events).last { $0.isActive(at: now) }
    }

    /// Token totals of blocks that have fully elapsed before `now` — the sample
    /// population for P90 plan-limit estimation. The active (incomplete) block
    /// is excluded so a partial window doesn't deflate the estimate.
    public static func completedBlockTotals(from events: [UsageEvent], now: Date) -> [Int] {
        blocks(from: events)
            .filter { $0.end <= now }
            .map(\.totalTokens)
    }
}
