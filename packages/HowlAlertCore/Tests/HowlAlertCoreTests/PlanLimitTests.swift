import Foundation
import Testing
@testable import HowlAlertCore

@Suite("Percentile")
struct PercentileTests {
    @Test func type7InterpolationMatchesNumPy() {
        // p90 of 1...10 is 9.1 under linear (type-7) interpolation.
        let xs = (1...10).map(Double.init)
        #expect(abs(Percentile.value(xs, 0.90) - 9.1) < 1e-9)
    }

    @Test func boundsReturnMinAndMax() {
        let xs = [5.0, 1.0, 9.0, 3.0]
        #expect(Percentile.value(xs, 0) == 1.0)
        #expect(Percentile.value(xs, 1) == 9.0)
    }

    @Test func singleAndEmpty() {
        #expect(Percentile.value([42], 0.9) == 42)
        #expect(Percentile.value([], 0.9) == 0)
    }

    @Test func clampsOutOfRangeQuantile() {
        let xs = [1.0, 2.0, 3.0]
        #expect(Percentile.value(xs, 2.0) == 3.0)
        #expect(Percentile.value(xs, -1.0) == 1.0)
    }
}

@Suite("PlanLimitEstimator")
struct PlanLimitTests {
    let config = LimitsConfig(minSamples: 5, fallbackLimit: 1_000)

    @Test func pinnedOverrideWins() {
        let c = LimitsConfig(sessionTokenLimit: 7_777, minSamples: 5, fallbackLimit: 1_000)
        #expect(PlanLimitEstimator.estimateSessionLimit(completedBlockTotals: [], config: c) == 7_777)
    }

    @Test func fallbackWhenTooFewSamples() {
        let totals = [5_000, 6_000, 7_000] // only 3 < minSamples 5
        #expect(PlanLimitEstimator.estimateSessionLimit(completedBlockTotals: totals, config: config) == 1_000)
    }

    @Test func usesP90WhenEnoughSamples() {
        let totals = [1_000, 2_000, 3_000, 4_000, 5_000, 6_000, 7_000, 8_000, 9_000, 10_000]
        // p90 = 9100
        #expect(PlanLimitEstimator.estimateSessionLimit(completedBlockTotals: totals, config: config) == 9_100)
    }

    @Test func floorsEstimateAtFallback() {
        let totals = [100, 100, 100, 100, 100, 100] // p90 = 100 < fallback 1000
        #expect(PlanLimitEstimator.estimateSessionLimit(completedBlockTotals: totals, config: config) == 1_000)
    }
}
