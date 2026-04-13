import Models
import TokenMath
import Foundation

public actor PaceEngine {
    private var snapshots: [UsageSnapshot] = []
    private let plan: ClaudePlan
    private let windowDuration: TimeInterval
    private let windowStart: Date

    public init(plan: ClaudePlan, windowStart: Date = .now, windowDuration: TimeInterval = 5 * 3600) {
        self.plan = plan
        self.windowStart = windowStart
        self.windowDuration = windowDuration
    }

    public func add(snapshot: UsageSnapshot) {
        snapshots.append(snapshot)
    }

    public func currentState() -> PaceState {
        let used = snapshots.reduce(0) { $0 + $1.totalTokens }
        let elapsed = Date.now.timeIntervalSince(windowStart)
        _ = min(elapsed / windowDuration, 1.0)
        let ratio = PaceCalculator.usageRatio(usedTokens: used, limit: plan.tokenLimit)
        return PaceCalculator.paceState(ratio: ratio)
    }

    public func totalTokensUsed() -> Int {
        snapshots.reduce(0) { $0 + $1.totalTokens }
    }
}
