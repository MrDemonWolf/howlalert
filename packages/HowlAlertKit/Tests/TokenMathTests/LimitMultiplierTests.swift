import XCTest
@testable import HowlAlertKit

final class LimitMultiplierTests: XCTestCase {
	private func makeConfig(
		multiplier: Double = 2.0,
		activeFrom: Date? = nil,
		activeUntil: Date? = nil,
		offPeakOnly: Bool = false,
		offPeakWindows: RemoteConfig.OffPeakWindows? = nil
	) -> RemoteConfig {
		RemoteConfig(
			multiplier: multiplier,
			activeFrom: activeFrom,
			activeUntil: activeUntil,
			offPeakOnly: offPeakOnly,
			offPeakWindows: offPeakWindows,
			reason: "test",
			updatedAt: Date(),
			plans: nil
		)
	}

	func testNoActivePromotion_returnsOne() {
		let config = makeConfig(multiplier: 1.0)
		let result = effectiveMultiplier(at: Date(), config: config)
		XCTAssertEqual(result, 1.0)
	}

	func testActivePromotionInRange_returnsMultiplier() {
		let now = Date()
		let config = makeConfig(
			activeFrom: now.addingTimeInterval(-3600),
			activeUntil: now.addingTimeInterval(3600)
		)
		let result = effectiveMultiplier(at: now, config: config)
		XCTAssertEqual(result, 2.0)
	}

	func testActivePromotionOutOfRange_returnsOne() {
		let now = Date()
		let config = makeConfig(
			activeFrom: now.addingTimeInterval(3600),
			activeUntil: now.addingTimeInterval(7200)
		)
		let result = effectiveMultiplier(at: now, config: config)
		XCTAssertEqual(result, 1.0)
	}

	func testOffPeakOnly_weekdayPeakHours_returnsOne() {
		// Create a date that is a known weekday during peak hours (UTC)
		// 2024-01-08 is a Monday, 14:00 UTC
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "UTC")!
		let components = DateComponents(
			timeZone: TimeZone(identifier: "UTC"),
			year: 2024, month: 1, day: 8, hour: 14
		)
		let date = calendar.date(from: components)!

		let config = makeConfig(
			offPeakOnly: true,
			offPeakWindows: RemoteConfig.OffPeakWindows(
				weekday: [
					RemoteConfig.TimeWindow(startUTC: 0, endUTC: 8),
					RemoteConfig.TimeWindow(startUTC: 22, endUTC: 24),
				],
				weekend: "all"
			)
		)
		let result = effectiveMultiplier(at: date, config: config)
		XCTAssertEqual(result, 1.0)
	}

	func testOffPeakOnly_weekdayOffPeakHours_returnsMultiplier() {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "UTC")!
		let components = DateComponents(
			timeZone: TimeZone(identifier: "UTC"),
			year: 2024, month: 1, day: 8, hour: 3
		)
		let date = calendar.date(from: components)!

		let config = makeConfig(
			offPeakOnly: true,
			offPeakWindows: RemoteConfig.OffPeakWindows(
				weekday: [
					RemoteConfig.TimeWindow(startUTC: 0, endUTC: 8),
					RemoteConfig.TimeWindow(startUTC: 22, endUTC: 24),
				],
				weekend: "all"
			)
		)
		let result = effectiveMultiplier(at: date, config: config)
		XCTAssertEqual(result, 2.0)
	}

	func testOffPeakOnly_weekend_returnsAllDayMultiplier() {
		// 2024-01-07 is a Sunday
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "UTC")!
		let components = DateComponents(
			timeZone: TimeZone(identifier: "UTC"),
			year: 2024, month: 1, day: 7, hour: 14
		)
		let date = calendar.date(from: components)!

		let config = makeConfig(
			offPeakOnly: true,
			offPeakWindows: RemoteConfig.OffPeakWindows(
				weekday: [
					RemoteConfig.TimeWindow(startUTC: 0, endUTC: 8)
				],
				weekend: "all"
			)
		)
		let result = effectiveMultiplier(at: date, config: config)
		XCTAssertEqual(result, 2.0)
	}
}
