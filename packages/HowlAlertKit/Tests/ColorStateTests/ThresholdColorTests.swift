import XCTest
@testable import HowlAlertKit

final class ThresholdColorTests: XCTestCase {
	func testBelowSixtyPercent_isOk() {
		XCTAssertEqual(ThresholdColor.state(for: 0), .ok)
		XCTAssertEqual(ThresholdColor.state(for: 30), .ok)
		XCTAssertEqual(ThresholdColor.state(for: 59.9), .ok)
	}

	func testSixtyToEightyFourPercent_isApproaching() {
		XCTAssertEqual(ThresholdColor.state(for: 60), .approaching)
		XCTAssertEqual(ThresholdColor.state(for: 75), .approaching)
		XCTAssertEqual(ThresholdColor.state(for: 84.9), .approaching)
	}

	func testEightyFiveAndAbove_isLimitHit() {
		XCTAssertEqual(ThresholdColor.state(for: 85), .limitHit)
		XCTAssertEqual(ThresholdColor.state(for: 95), .limitHit)
		XCTAssertEqual(ThresholdColor.state(for: 100), .limitHit)
	}
}
