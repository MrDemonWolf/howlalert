import Testing
@testable import HowlAlertKit

@Suite("UsageState")
struct UsageStateTests {
    @Test("clamps percent below 0 to .ok")
    func clampsLowerBound() {
        #expect(UsageState.from(percentUsed: -0.5) == .ok)
        #expect(UsageState.from(percentUsed: 0) == .ok)
    }

    @Test("returns .ok under 80%")
    func underWarn() {
        #expect(UsageState.from(percentUsed: 0.50) == .ok)
        #expect(UsageState.from(percentUsed: 0.799) == .ok)
    }

    @Test("returns .warn at 80%–94%")
    func warnBand() {
        #expect(UsageState.from(percentUsed: 0.80) == .warn)
        #expect(UsageState.from(percentUsed: 0.949) == .warn)
    }

    @Test("returns .crit at 95% and above")
    func critBand() {
        #expect(UsageState.from(percentUsed: 0.95) == .crit)
        #expect(UsageState.from(percentUsed: 1.0) == .crit)
        #expect(UsageState.from(percentUsed: 2.0) == .crit)
    }
}
