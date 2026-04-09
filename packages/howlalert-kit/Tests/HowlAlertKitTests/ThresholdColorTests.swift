import XCTest
@testable import HowlAlertKit

final class ThresholdColorTests: XCTestCase {

    func testZeroIsNormal() {
        XCTAssertEqual(ThresholdColor.color(for: 0.0), .normal)
    }

    func testJustBelowApproachingIsNormal() {
        XCTAssertEqual(ThresholdColor.color(for: 0.59), .normal)
    }

    func testAtApproachingThreshold() {
        XCTAssertEqual(ThresholdColor.color(for: 0.60), .approaching)
    }

    func testJustBelowCriticalIsApproaching() {
        XCTAssertEqual(ThresholdColor.color(for: 0.84), .approaching)
    }

    func testAtCriticalThreshold() {
        XCTAssertEqual(ThresholdColor.color(for: 0.85), .critical)
    }

    func testAboveCriticalIsCritical() {
        XCTAssertEqual(ThresholdColor.color(for: 1.0), .critical)
    }

    func testJustResetReturnsReset() {
        XCTAssertEqual(ThresholdColor.color(for: 0.0, justReset: true), .reset)
    }

    func testJustResetOverridesCritical() {
        // Even if usage is critical, justReset takes precedence
        XCTAssertEqual(ThresholdColor.color(for: 0.95, justReset: true), .reset)
    }
}
