import XCTest
@testable import HowlAlertKit

final class PaceCalculatorTests: XCTestCase {

    // 5h window in seconds
    private let windowDuration: TimeInterval = 5 * 3600  // 18000s

    func testOnTrackAtMidpoint() {
        // 50% elapsed, 50% tokens used → on track
        let windowStart = Date(timeIntervalSinceNow: -9000)  // 2.5h ago
        let result = PaceCalculator.calculate(
            tokensUsed: 100_000,
            effectiveLimit: 200_000,
            windowStart: windowStart,
            windowDuration: windowDuration
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .onTrack)
    }

    func testInDebtWhenBurningFast() {
        // 20% elapsed (3600s), 50% tokens used → well in debt
        let now = Date()
        let windowStart = Date(timeIntervalSince1970: now.timeIntervalSince1970 - 3600)
        let result = PaceCalculator.calculate(
            tokensUsed: 100_000,
            effectiveLimit: 200_000,
            windowStart: windowStart,
            windowDuration: windowDuration,
            now: now
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .inDebt)
        XCTAssertGreaterThan(result?.pacePercent ?? 0, 0)
    }

    func testInReserveWhenConservative() {
        // 60% elapsed (10800s), 20% tokens used → in reserve
        let now = Date()
        let windowStart = Date(timeIntervalSince1970: now.timeIntervalSince1970 - 10800)
        let result = PaceCalculator.calculate(
            tokensUsed: 40_000,
            effectiveLimit: 200_000,
            windowStart: windowStart,
            windowDuration: windowDuration,
            now: now
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .inReserve)
        XCTAssertLessThan(result?.pacePercent ?? 0, 0)
    }

    func testInsufficientTimeReturnsNil() {
        // Only 2 minutes elapsed — not enough data
        let windowStart = Date(timeIntervalSinceNow: -120)
        let result = PaceCalculator.calculate(
            tokensUsed: 1_000,
            effectiveLimit: 200_000,
            windowStart: windowStart,
            windowDuration: windowDuration
        )
        XCTAssertNil(result)
    }

    func testRunsOutAtCalculationIsInFuture() {
        // Burning very fast: 50% used in 20% of time → should run out before end
        let now = Date()
        let windowStart = Date(timeIntervalSince1970: now.timeIntervalSince1970 - 3600)
        let result = PaceCalculator.calculate(
            tokensUsed: 100_000,
            effectiveLimit: 200_000,
            windowStart: windowStart,
            windowDuration: windowDuration,
            now: now
        )
        XCTAssertEqual(result?.status, .inDebt)
        XCTAssertNotNil(result?.runsOutAt)
        if let runsOutAt = result?.runsOutAt {
            XCTAssertGreaterThan(runsOutAt, now)
        }
    }
}
