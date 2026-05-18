import Testing
import Foundation
@testable import HowlAlertKit

@Suite("PlanLimitEstimator")
struct PlanLimitEstimatorTests {
    private let now = Date(timeIntervalSince1970: 1_750_000_000)

    @Test("falls back below the minimum sample size")
    func belowMinSamples() {
        let estimator = PlanLimitEstimator(now: { self.now })
        let totals = [100, 120, 140] // 3 samples, min is 7
        let ends = totals.map { _ in self.now.addingTimeInterval(-86_400) }
        #expect(estimator.estimate(completedWindowTotals: totals, completedWindowEnds: ends, fallback: 250) == 250)
    }

    @Test("ignores windows older than 30 days")
    func ignoresOldWindows() {
        let estimator = PlanLimitEstimator(now: { self.now })
        let totals = Array(repeating: 999, count: 10) // would dominate P90 if counted
        let ends = totals.map { _ in self.now.addingTimeInterval(-40 * 86_400) }
        // Plus 7 recent low-value windows.
        let recentTotals = [100, 110, 120, 130, 140, 150, 160]
        let recentEnds = recentTotals.map { _ in self.now.addingTimeInterval(-86_400) }

        let est = estimator.estimate(
            completedWindowTotals: totals + recentTotals,
            completedWindowEnds: ends + recentEnds,
            fallback: 999
        )
        #expect(est < 200) // pulled from the recent low cluster, not the old 999s
    }

    @Test("returns P90 of recent samples")
    func computesP90() {
        let estimator = PlanLimitEstimator(now: { self.now })
        let totals = [100, 110, 120, 130, 140, 150, 160, 170, 180, 190]
        let ends = totals.map { _ in self.now.addingTimeInterval(-86_400) }
        let est = estimator.estimate(completedWindowTotals: totals, completedWindowEnds: ends, fallback: 0)
        // P90 of [100,110,...,190] using Type-7 linear interp:
        //   rank = 0.9 * 9 = 8.1 → between idx 8 (180) and idx 9 (190) → 181.
        #expect(est == 181)
    }
}
