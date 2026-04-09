import XCTest
@testable import HowlAlertKit

final class LimitMultiplierTests: XCTestCase {

    func testNoPromoMultiplierOne() {
        // No promo, multiplier 1.0 → effectiveLimit == basePlanLimit
        let config = RemoteConfig(
            multiplier: 1.0,
            activePromo: nil,
            planLimits: RemoteConfig.PlanLimits(free: 40_000, pro: 200_000, max5: 1_000_000, max20: 4_000_000),
            updatedAt: nil
        )
        let result = LimitMultiplier.effectiveLimit(basePlanLimit: 200_000, config: config)
        XCTAssertEqual(result, 200_000)
    }

    func testActivePromoDoubles() {
        // Active promo with 2x multiplier, not yet ended → effectiveLimit = base * 2
        let futureDate = Date(timeIntervalSinceNow: 86400)  // tomorrow
        let config = RemoteConfig(
            multiplier: 2.0,
            activePromo: RemoteConfig.PromoConfig(name: "Double Weekend", endsAt: futureDate),
            planLimits: RemoteConfig.PlanLimits(free: 40_000, pro: 200_000, max5: 1_000_000, max20: 4_000_000),
            updatedAt: nil
        )
        let result = LimitMultiplier.effectiveLimit(basePlanLimit: 200_000, config: config)
        XCTAssertEqual(result, 400_000)
    }

    func testExpiredPromoFallsBackToBase() {
        // Promo has ended → back to 1x (multiplier not applied when promo is present but expired)
        let pastDate = Date(timeIntervalSinceNow: -86400)  // yesterday
        let config = RemoteConfig(
            multiplier: 2.0,
            activePromo: RemoteConfig.PromoConfig(name: "Expired Promo", endsAt: pastDate),
            planLimits: RemoteConfig.PlanLimits(free: 40_000, pro: 200_000, max5: 1_000_000, max20: 4_000_000),
            updatedAt: nil
        )
        let result = LimitMultiplier.effectiveLimit(basePlanLimit: 200_000, config: config)
        XCTAssertEqual(result, 200_000)
    }

    func testNoPromoCustomMultiplier() {
        // No promo, but multiplier set to 1.5 → effectiveLimit = base * 1.5
        let config = RemoteConfig(
            multiplier: 1.5,
            activePromo: nil,
            planLimits: RemoteConfig.PlanLimits(free: 40_000, pro: 200_000, max5: 1_000_000, max20: 4_000_000),
            updatedAt: nil
        )
        let result = LimitMultiplier.effectiveLimit(basePlanLimit: 200_000, config: config)
        XCTAssertEqual(result, 300_000)
    }
}
