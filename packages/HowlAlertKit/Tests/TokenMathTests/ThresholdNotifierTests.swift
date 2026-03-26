import XCTest
@testable import HowlAlertKit

final class ThresholdNotifierTests: XCTestCase {

	func testCrossing60FiresOnce() {
		var notifier = ThresholdNotifier()
		let config = ThresholdNotifier.ThresholdConfig()

		let event = notifier.check(usagePercent: 62.0, paceStatus: .onTrack, config: config)
		XCTAssertNotNil(event)
		XCTAssertEqual(event?.threshold, 60.0)
		XCTAssertEqual(event?.urgency, .info)
		XCTAssertEqual(event?.title, "Approaching Limit")

		// Second check at same level should not fire again
		let event2 = notifier.check(usagePercent: 65.0, paceStatus: .onTrack, config: config)
		XCTAssertNil(event2)
	}

	func testCrossing85FiresOnce() {
		var notifier = ThresholdNotifier()
		let config = ThresholdNotifier.ThresholdConfig()

		// Fire 60 first
		_ = notifier.check(usagePercent: 62.0, paceStatus: .onTrack, config: config)

		let event = notifier.check(usagePercent: 87.0, paceStatus: .inDebt, config: config)
		XCTAssertNotNil(event)
		XCTAssertEqual(event?.threshold, 85.0)
		XCTAssertEqual(event?.urgency, .warning)
		XCTAssertEqual(event?.title, "Close to Limit")

		// Second check should not fire again
		let event2 = notifier.check(usagePercent: 90.0, paceStatus: .inDebt, config: config)
		XCTAssertNil(event2)
	}

	func testCrossing100FiresOnce() {
		var notifier = ThresholdNotifier()
		let config = ThresholdNotifier.ThresholdConfig()

		// Fire 60 and 85 first
		_ = notifier.check(usagePercent: 62.0, paceStatus: .onTrack, config: config)
		_ = notifier.check(usagePercent: 87.0, paceStatus: .inDebt, config: config)

		let event = notifier.check(usagePercent: 100.0, paceStatus: .inDebt, config: config)
		XCTAssertNotNil(event)
		XCTAssertEqual(event?.threshold, 100.0)
		XCTAssertEqual(event?.urgency, .critical)
		XCTAssertEqual(event?.title, "Limit Hit")

		// Second check should not fire again
		let event2 = notifier.check(usagePercent: 105.0, paceStatus: .inDebt, config: config)
		XCTAssertNil(event2)
	}

	func testDisabledThresholdsDontFire() {
		var notifier = ThresholdNotifier()
		let config = ThresholdNotifier.ThresholdConfig(
			alertAt60: false,
			alertAt85: false,
			alertAt100: false
		)

		let event60 = notifier.check(usagePercent: 62.0, paceStatus: .onTrack, config: config)
		XCTAssertNil(event60)

		let event85 = notifier.check(usagePercent: 87.0, paceStatus: .inDebt, config: config)
		XCTAssertNil(event85)

		let event100 = notifier.check(usagePercent: 100.0, paceStatus: .inDebt, config: config)
		XCTAssertNil(event100)
	}

	func testResetAllowsRefiring() {
		var notifier = ThresholdNotifier()
		let config = ThresholdNotifier.ThresholdConfig()

		let event1 = notifier.check(usagePercent: 62.0, paceStatus: .onTrack, config: config)
		XCTAssertNotNil(event1)

		notifier.reset()

		let event2 = notifier.check(usagePercent: 62.0, paceStatus: .onTrack, config: config)
		XCTAssertNotNil(event2)
		XCTAssertEqual(event2?.threshold, 60.0)
	}

	func testRateLimitEventAlwaysFires() {
		let notifier = ThresholdNotifier()

		let event = notifier.rateLimitEvent(usagePercent: 75.0)
		XCTAssertTrue(event.isRateLimit)
		XCTAssertEqual(event.urgency, .critical)
		XCTAssertEqual(event.title, "Rate Limited")
		XCTAssertTrue(event.body.contains("rate limit"))

		// Can fire again without reset
		let event2 = notifier.rateLimitEvent(usagePercent: 80.0)
		XCTAssertTrue(event2.isRateLimit)
		XCTAssertEqual(event2.currentPercent, 80.0)
	}

	func testSkippingDirectlyTo100FiresHighest() {
		var notifier = ThresholdNotifier()
		let config = ThresholdNotifier.ThresholdConfig()

		// Jump straight to 100% — should fire 100 (highest matched)
		let event = notifier.check(usagePercent: 100.0, paceStatus: .inDebt, config: config)
		XCTAssertNotNil(event)
		XCTAssertEqual(event?.threshold, 100.0)
	}
}
