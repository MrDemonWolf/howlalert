import Testing
import Foundation
@testable import HowlAlertKit

@Suite("PaceProjector")
struct PaceProjectorTests {
    private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day; c.hour = hour; c.minute = minute
        return cal.date(from: c)!
    }

    @Test("returns .fresh inside the grace window regardless of usage")
    func freshGrace() {
        let win = UsageWindow(firstRequestTime: utc(2026, 5, 18, 14, 0))
        let reading = PaceProjector().project(
            window: win,
            requestsSoFar: 5,
            planLimit: 100,
            now: utc(2026, 5, 18, 14, 1)
        )
        #expect(reading.usageState == .fresh)
        #expect(reading.pace == .fresh)
    }

    @Test("on-pace classification: projected lands between 80% and 100%")
    func onPace() {
        let win = UsageWindow(firstRequestTime: utc(2026, 5, 18, 14, 0))
        // 90 minutes in, 30 requests used, plan limit 100 → projected ~100 = on-pace.
        let reading = PaceProjector().project(
            window: win,
            requestsSoFar: 30,
            planLimit: 100,
            now: utc(2026, 5, 18, 15, 30)
        )
        #expect(reading.pace == .onPace)
        #expect(reading.percentUsed == 0.30)
    }

    @Test("behind pace when projection blows the window")
    func behindPace() {
        let win = UsageWindow(firstRequestTime: utc(2026, 5, 18, 14, 0))
        // 30 minutes in, 30 requests — extrapolates to ~300 requests over 5h.
        let reading = PaceProjector().project(
            window: win,
            requestsSoFar: 30,
            planLimit: 100,
            now: utc(2026, 5, 18, 14, 30)
        )
        #expect(reading.pace == .behind)
        #expect(reading.percentProjected > 1.0)
    }

    @Test("ahead of pace when projection stays under 80%")
    func aheadOfPace() {
        let win = UsageWindow(firstRequestTime: utc(2026, 5, 18, 14, 0))
        // 4 hours in, only 50 used out of 100 → projects to ~62.5 → ahead.
        let reading = PaceProjector().project(
            window: win,
            requestsSoFar: 50,
            planLimit: 100,
            now: utc(2026, 5, 18, 18, 0)
        )
        #expect(reading.pace == .ahead)
    }
}
