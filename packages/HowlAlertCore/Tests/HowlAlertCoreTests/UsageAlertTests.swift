import Testing
@testable import HowlAlertCore

@Suite("UsageAlert")
struct UsageAlertTests {
    @Test func firstObservationSeedsSilently() {
        let r = usageAlert(previous: nil, current: .crit)
        #expect(r.alert == nil)
        #expect(r.baseline == .crit)
    }

    @Test func risingIntoWarnFiresLow() {
        let r = usageAlert(previous: .ok, current: .warn)
        #expect(r.alert == .low)
        #expect(r.baseline == .warn)
    }

    @Test func risingIntoCritFiresAlmostOut() {
        let r = usageAlert(previous: .warn, current: .crit)
        #expect(r.alert == .almostOut)
        #expect(r.baseline == .crit)
    }

    @Test func jumpingOkToCritFiresAlmostOut() {
        let r = usageAlert(previous: .ok, current: .crit)
        #expect(r.alert == .almostOut)
        #expect(r.baseline == .crit)
    }

    @Test func staySameLevelDoesNotRefire() {
        let r = usageAlert(previous: .warn, current: .warn)
        #expect(r.alert == nil)
        #expect(r.baseline == .warn)
    }

    @Test func easingOffReArmsWithoutAlert() {
        let r = usageAlert(previous: .crit, current: .ok)
        #expect(r.alert == nil)
        #expect(r.baseline == .ok)   // lowered, so a later rise fires again
    }

    @Test func mutedLowStillAdvancesBaseline() {
        let prefs = AlertPreferences(low: false, almostOut: true)
        let r = usageAlert(previous: .ok, current: .warn, preferences: prefs)
        #expect(r.alert == nil)       // gated off
        #expect(r.baseline == .warn)  // but baseline advances so it isn't re-evaluated
    }

    @Test func mutedCritDoesNotFire() {
        let prefs = AlertPreferences(low: true, almostOut: false)
        let r = usageAlert(previous: .warn, current: .crit, preferences: prefs)
        #expect(r.alert == nil)
        #expect(r.baseline == .crit)
    }

    @Test func reArmThenRiseFiresAgain() {
        // crit (alerted) -> ok (re-arm) -> crit (fires again)
        var baseline: UsageState? = .crit
        var r = usageAlert(previous: baseline, current: .ok)
        baseline = r.baseline
        #expect(r.alert == nil)

        r = usageAlert(previous: baseline, current: .crit)
        #expect(r.alert == .almostOut)
        #expect(r.baseline == .crit)
    }

    @Test func risingIntoOkNeverAlerts() {
        let r = usageAlert(previous: .fresh, current: .ok)
        #expect(r.alert == nil)
        #expect(r.baseline == .ok)
    }
}
