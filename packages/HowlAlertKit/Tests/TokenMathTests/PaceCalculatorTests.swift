import XCTest
@testable import HowlAlertKit

final class PaceCalculatorTests: XCTestCase {
	private let windowStart = Date(timeIntervalSince1970: 0)
	private let windowEnd = Date(timeIntervalSince1970: 86400) // 24 hours
	private let limit = 10000

	func testInDebt_whenConsumingFasterThanEvenRate() {
		// At 50% of window, consumed 80% of limit
		let now = Date(timeIntervalSince1970: 43200) // 12 hours in
		let result = calculatePace(
			consumed: 8000,
			limit: limit,
			windowStart: windowStart,
			windowEnd: windowEnd,
			now: now
		)
		XCTAssertEqual(result.status, .inDebt)
		XCTAssertLessThan(result.percentDelta, -5.0)
		XCTAssertNotNil(result.estimatedRunout)
		XCTAssertEqual(result.windowResetDate, windowEnd)
	}

	func testOnTrack_whenWithinFivePercentDelta() {
		// At 50% of window, consumed 50% of limit
		let now = Date(timeIntervalSince1970: 43200)
		let result = calculatePace(
			consumed: 5000,
			limit: limit,
			windowStart: windowStart,
			windowEnd: windowEnd,
			now: now
		)
		XCTAssertEqual(result.status, .onTrack)
		XCTAssertTrue(abs(result.percentDelta) <= 5.0)
		XCTAssertNil(result.estimatedRunout)
	}

	func testInReserve_whenConsumingSlower() {
		// At 50% of window, consumed only 20% of limit
		let now = Date(timeIntervalSince1970: 43200)
		let result = calculatePace(
			consumed: 2000,
			limit: limit,
			windowStart: windowStart,
			windowEnd: windowEnd,
			now: now
		)
		XCTAssertEqual(result.status, .inReserve)
		XCTAssertGreaterThan(result.percentDelta, 5.0)
		XCTAssertNil(result.estimatedRunout)
	}

	func testEarlyWindow_returnOnTrack() {
		// Less than 3% into the window
		let now = Date(timeIntervalSince1970: 2000) // ~2.3% of 86400
		let result = calculatePace(
			consumed: 5000,
			limit: limit,
			windowStart: windowStart,
			windowEnd: windowEnd,
			now: now
		)
		XCTAssertEqual(result.status, .onTrack)
		XCTAssertEqual(result.percentDelta, 0.0)
		XCTAssertNil(result.estimatedRunout)
	}

	func testWithMultiplier() {
		// At 50% of window, consumed 80% of base limit
		// But with 2x multiplier, effective limit is 20000, so 8000/20000 = 40% consumed
		let now = Date(timeIntervalSince1970: 43200)
		let result = calculatePace(
			consumed: 8000,
			limit: limit,
			windowStart: windowStart,
			windowEnd: windowEnd,
			now: now,
			multiplier: 2.0
		)
		XCTAssertEqual(result.status, .inReserve)
		XCTAssertGreaterThan(result.percentDelta, 5.0)
		XCTAssertNil(result.estimatedRunout)
	}
}
