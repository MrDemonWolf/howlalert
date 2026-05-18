import Testing
import Foundation
@testable import HowlAlertKit

@Suite("UsageWindow")
struct UsageWindowTests {
    /// Helper: build a UTC date from components.
    private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0, _ second: Int = 0) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        c.hour = hour; c.minute = minute; c.second = second
        return cal.date(from: c)!
    }

    @Test("floors the first request to its UTC hour")
    func floorsToUTCHour() {
        let first = utc(2026, 5, 18, 14, 37, 22) // 14:37:22 UTC
        let win = UsageWindow(firstRequestTime: first)
        let expectedStart = utc(2026, 5, 18, 14, 0, 0)
        let expectedEnd   = utc(2026, 5, 18, 19, 0, 0)
        #expect(win.windowStart == expectedStart)
        #expect(win.windowEnd == expectedEnd)
        #expect(win.windowEnd.timeIntervalSince(win.windowStart) == 5 * 3600)
    }

    @Test("window crosses midnight UTC")
    func crossesMidnight() {
        let first = utc(2026, 5, 18, 22, 10) // 22:10 UTC
        let win = UsageWindow(firstRequestTime: first)
        #expect(win.windowStart == utc(2026, 5, 18, 22, 0))
        #expect(win.windowEnd   == utc(2026, 5, 19, 3, 0))
        #expect(win.contains(utc(2026, 5, 19, 1, 0)))
        #expect(!win.contains(utc(2026, 5, 19, 4, 0)))
    }

    @Test("resume returns the previous window when request still inside it")
    func resumeKeepsExistingWindow() {
        let first = utc(2026, 5, 18, 9, 5)
        let win = UsageWindow(firstRequestTime: first)
        let resumed = UsageWindow.resume(previous: win, requestTime: utc(2026, 5, 18, 13, 30))
        #expect(resumed == win)
    }

    @Test("resume creates a fresh window when request lands outside the previous one")
    func resumeStartsNewWindow() {
        let first = utc(2026, 5, 18, 9, 5)
        let win = UsageWindow(firstRequestTime: first)
        let resumed = UsageWindow.resume(previous: win, requestTime: utc(2026, 5, 18, 15, 12))
        #expect(resumed != win)
        #expect(resumed.windowStart == utc(2026, 5, 18, 15, 0))
    }

    @Test("DST spring-forward day still uses UTC math (no jump)")
    func dstSpringForward() {
        // 09 March 2026, 02:30 America/Los_Angeles == 10:30 UTC.
        // DST jump in LA at 02:00→03:00 local; UTC unaffected.
        let first = utc(2026, 3, 9, 10, 30)
        let win = UsageWindow(firstRequestTime: first)
        #expect(win.windowStart == utc(2026, 3, 9, 10, 0))
        #expect(win.windowEnd   == utc(2026, 3, 9, 15, 0))
        #expect(win.windowEnd.timeIntervalSince(win.windowStart) == 5 * 3600)
    }

    @Test("elapsed and remaining clamp at window boundaries")
    func clampsElapsedAndRemaining() {
        let first = utc(2026, 5, 18, 14, 0)
        let win = UsageWindow(firstRequestTime: first)
        #expect(win.elapsed(at: utc(2026, 5, 18, 12, 0)) == 0)             // before start
        #expect(win.elapsed(at: utc(2026, 5, 18, 16, 30)) == 2.5 * 3600)   // midway
        #expect(win.elapsed(at: utc(2026, 5, 19, 0, 0))  == 5 * 3600)      // past end
        #expect(win.remaining(at: utc(2026, 5, 18, 16, 0)) == 3 * 3600)
    }
}
