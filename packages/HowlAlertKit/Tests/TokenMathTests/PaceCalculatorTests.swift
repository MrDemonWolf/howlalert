import Testing
@testable import TokenMath
import Models

@Suite("PaceCalculator")
struct PaceCalculatorTests {

    // MARK: projectedTotal

    @Test("projectedTotal at 25% elapsed")
    func projectedTotal_quarter() {
        let result = PaceCalculator.projectedTotal(usedTokens: 8_000, elapsedFraction: 0.25)
        #expect(result == 32_000)
    }

    @Test("projectedTotal at 50% elapsed")
    func projectedTotal_half() {
        let result = PaceCalculator.projectedTotal(usedTokens: 16_000, elapsedFraction: 0.5)
        #expect(result == 32_000)
    }

    @Test("projectedTotal at 75% elapsed")
    func projectedTotal_threeQuarters() {
        let result = PaceCalculator.projectedTotal(usedTokens: 24_000, elapsedFraction: 0.75)
        #expect(result == 32_000)
    }

    @Test("projectedTotal with zero elapsed returns 0")
    func projectedTotal_zeroElapsed() {
        let result = PaceCalculator.projectedTotal(usedTokens: 10_000, elapsedFraction: 0)
        #expect(result == 0)
    }

    // MARK: usageRatio

    @Test("usageRatio at half usage")
    func usageRatio_half() {
        let ratio = PaceCalculator.usageRatio(usedTokens: 16_000, limit: 32_000)
        #expect(ratio == 0.5)
    }

    @Test("usageRatio above limit returns > 1.0")
    func usageRatio_overLimit() {
        let ratio = PaceCalculator.usageRatio(usedTokens: 40_000, limit: 32_000)
        #expect(ratio > 1.0)
    }

    @Test("usageRatio with zero limit returns 0")
    func usageRatio_zeroLimit() {
        let ratio = PaceCalculator.usageRatio(usedTokens: 5_000, limit: 0)
        #expect(ratio == 0)
    }

    // MARK: paceState

    @Test("paceState returns calm below warn threshold")
    func paceState_calm() {
        let state = PaceCalculator.paceState(ratio: 0.5)
        #expect(state == .calm)
    }

    @Test("paceState returns warn between thresholds")
    func paceState_warn() {
        let state = PaceCalculator.paceState(ratio: 0.80)
        #expect(state == .warn)
    }

    @Test("paceState returns critical at or above critical threshold")
    func paceState_critical() {
        let state = PaceCalculator.paceState(ratio: 0.95)
        #expect(state == .critical)
    }

    @Test("paceState respects custom thresholds")
    func paceState_customThresholds() {
        let calm = PaceCalculator.paceState(ratio: 0.4, warnThreshold: 0.5, criticalThreshold: 0.8)
        let warn = PaceCalculator.paceState(ratio: 0.6, warnThreshold: 0.5, criticalThreshold: 0.8)
        let critical = PaceCalculator.paceState(ratio: 0.9, warnThreshold: 0.5, criticalThreshold: 0.8)
        #expect(calm == .calm)
        #expect(warn == .warn)
        #expect(critical == .critical)
    }
}
