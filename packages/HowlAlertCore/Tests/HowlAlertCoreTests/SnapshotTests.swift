import Foundation
import Testing
@testable import HowlAlertCore

@Suite("UsageState")
struct UsageStateTests {
    @Test func bandsFromRemaining() {
        #expect(UsageState.from(fractionRemaining: 0.90) == .fresh)
        #expect(UsageState.from(fractionRemaining: 0.60) == .ok)
        #expect(UsageState.from(fractionRemaining: 0.16) == .warn)
        #expect(UsageState.from(fractionRemaining: 0.05) == .crit)
    }
}

@Suite("UsageEngine.snapshot")
struct SnapshotTests {
    // Pin the limit at 1000 so fractions are exact.
    let config = LimitsConfig(sessionTokenLimit: 1_000, minSamples: 5, fallbackLimit: 1)

    @Test func computesActiveWindowSnapshot() throws {
        let events = [evt(0, tokens: 840)]
        let snap = try #require(UsageEngine.snapshot(events: events, config: config, now: hours(1)))
        #expect(snap.tokensUsed == 840)
        #expect(snap.limit == 1_000)
        #expect(abs(snap.fractionUsed - 0.84) < 1e-9)
        #expect(abs(snap.fractionRemaining - 0.16) < 1e-9)
        #expect(snap.state == .warn)
        #expect(snap.windowStart == hours(0))
        #expect(snap.resetsAt == hours(5))
        #expect(snap.timeUntilReset == 4 * 3600)
    }

    @Test func projectsRunOutBeforeResetWhenBurningFast() throws {
        let snap = try #require(UsageEngine.snapshot(events: [evt(0, tokens: 840)], config: config, now: hours(1)))
        let runOut = try #require(snap.projectedRunOut)
        #expect(runOut < snap.resetsAt)
        #expect(snap.willLastToReset == false)
    }

    @Test func lastsToResetWhenBurningSlow() throws {
        let snap = try #require(UsageEngine.snapshot(events: [evt(0, tokens: 10)], config: config, now: hours(1)))
        #expect(snap.willLastToReset == true)
    }

    @Test func nilWhenWindowHasReset() {
        // Only activity at hour 0; now is past the 5h window.
        #expect(UsageEngine.snapshot(events: [evt(0, tokens: 100)], config: config, now: hours(6)) == nil)
    }

    @Test func projectRunOutReturnsNilWithoutElapsedTime() {
        #expect(UsageEngine.projectRunOut(used: 100, limit: 1_000, start: hours(0), now: hours(0)) == nil)
    }

    @Test func projectRunOutImmediateWhenAlreadyOverLimit() {
        let now = hours(1)
        #expect(UsageEngine.projectRunOut(used: 1_200, limit: 1_000, start: hours(0), now: now) == now)
    }
}
