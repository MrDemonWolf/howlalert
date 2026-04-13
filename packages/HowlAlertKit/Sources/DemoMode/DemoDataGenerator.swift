// DemoDataGenerator — 60-second cycle through all crit states
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models
import TokenMath
import ColorState

public struct DemoDataGenerator: Sendable {
    private static let cycleDuration: TimeInterval = 60
    private static let limit = 100_000

    public init() {}

    /// Generate a demo snapshot for the given elapsed time in the cycle.
    /// Cycles: 0–15s OK → 15–30s approaching → 30–45s limit hit → 45–60s reset
    public func snapshot(at elapsed: TimeInterval) -> UsageSnapshot {
        let phase = elapsed.truncatingRemainder(dividingBy: Self.cycleDuration)
        let tokens: Int

        switch phase {
        case 0..<15:
            let progress = phase / 15.0
            tokens = Int(progress * 0.55 * Double(Self.limit))
        case 15..<30:
            let progress = (phase - 15) / 15.0
            tokens = Int((0.55 + progress * 0.25) * Double(Self.limit))
        case 30..<45:
            let progress = (phase - 30) / 15.0
            tokens = Int((0.80 + progress * 0.20) * Double(Self.limit))
        default:
            let progress = (phase - 45) / 15.0
            tokens = Int((1.0 - progress) * 0.1 * Double(Self.limit))
        }

        let now = Date.now
        return UsageSnapshot(
            sourceDeviceID: "demo-device",
            sourceDeviceName: "Demo Mac",
            sourceDeviceType: .macBookPro,
            model: "claude-sonnet-4-1",
            outputTokens: tokens,
            cacheReadInputTokens: tokens / 3,
            cacheCreationInputTokens: tokens / 10,
            windowStart: now.addingTimeInterval(-2 * 3600),
            windowEnd: now.addingTimeInterval(3 * 3600),
            updatedAt: now
        )
    }

    /// Generate a demo PaceState for the given elapsed time.
    public func paceState(at elapsed: TimeInterval) -> PaceState {
        let snap = snapshot(at: elapsed)
        let calculator = PaceCalculator()
        return calculator.calculate(
            totalTokens: snap.totalBillableTokens,
            limit: Self.limit,
            windowStart: snap.windowStart,
            windowEnd: snap.windowEnd
        )
    }

    /// Current crit state name for the demo cycle phase.
    public func critState(at elapsed: TimeInterval) -> CritState {
        let snap = snapshot(at: elapsed)
        let percent = Double(snap.totalBillableTokens) / Double(Self.limit) * 100
        let phase = elapsed.truncatingRemainder(dividingBy: Self.cycleDuration)
        let isReset = phase >= 45
        return ThresholdColor().state(for: percent, isReset: isReset)
    }
}
