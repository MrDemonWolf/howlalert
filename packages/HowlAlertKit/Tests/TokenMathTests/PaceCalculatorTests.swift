// PaceCalculatorTests
// © 2026 MrDemonWolf, Inc.

import Testing
import Foundation
@testable import TokenMath
@testable import Models

@Suite("PaceCalculator")
struct PaceCalculatorTests {
    let calc = PaceCalculator()
    let windowStart = Date(timeIntervalSince1970: 0)
    let windowEnd = Date(timeIntervalSince1970: 5 * 3600) // 5h window

    @Test("Zero usage early in window is on track")
    func zeroUsage() {
        let justStarted = Date(timeIntervalSince1970: 60) // 1 min in
        let state = calc.calculate(
            totalTokens: 0, limit: 100_000,
            windowStart: windowStart, windowEnd: windowEnd,
            now: justStarted
        )
        #expect(state.status == .onTrack)
        #expect(state.usagePercent == 0)
    }

    @Test("50% usage at 50% time is on track")
    func onTrack() {
        let midpoint = Date(timeIntervalSince1970: 2.5 * 3600)
        let state = calc.calculate(
            totalTokens: 50_000, limit: 100_000,
            windowStart: windowStart, windowEnd: windowEnd,
            now: midpoint
        )
        #expect(state.status == .onTrack)
        #expect(abs(state.debtPercent) < 5)
    }

    @Test("80% usage at 20% time is in debt")
    func inDebt() {
        let earlyPoint = Date(timeIntervalSince1970: 3600)
        let state = calc.calculate(
            totalTokens: 80_000, limit: 100_000,
            windowStart: windowStart, windowEnd: windowEnd,
            now: earlyPoint
        )
        #expect(state.status == .inDebt)
        #expect(state.debtPercent > 5)
    }

    @Test("10% usage at 80% time is in reserve")
    func inReserve() {
        let latePoint = Date(timeIntervalSince1970: 4 * 3600)
        let state = calc.calculate(
            totalTokens: 10_000, limit: 100_000,
            windowStart: windowStart, windowEnd: windowEnd,
            now: latePoint
        )
        #expect(state.status == .inReserve)
        #expect(state.debtPercent < -10)
    }

    @Test("100% usage hits limit")
    func limitHit() {
        let state = calc.calculate(
            totalTokens: 100_000, limit: 100_000,
            windowStart: windowStart, windowEnd: windowEnd,
            now: Date(timeIntervalSince1970: 3600)
        )
        #expect(state.status == .limitHit)
        #expect(state.usagePercent >= 100)
    }

    @Test("Over 100% still reports limit hit")
    func overLimit() {
        let state = calc.calculate(
            totalTokens: 120_000, limit: 100_000,
            windowStart: windowStart, windowEnd: windowEnd,
            now: Date(timeIntervalSince1970: 3600)
        )
        #expect(state.status == .limitHit)
    }

    @Test("Zero limit returns limit hit")
    func zeroLimit() {
        let state = calc.calculate(
            totalTokens: 1000, limit: 0,
            windowStart: windowStart, windowEnd: windowEnd,
            now: Date(timeIntervalSince1970: 3600)
        )
        #expect(state.status == .limitHit)
    }

    @Test("Runout estimate is positive when in debt")
    func runoutEstimate() {
        let earlyPoint = Date(timeIntervalSince1970: 3600)
        let state = calc.calculate(
            totalTokens: 80_000, limit: 100_000,
            windowStart: windowStart, windowEnd: windowEnd,
            now: earlyPoint
        )
        #expect(state.estimatedRunoutMinutes != nil)
        #expect(state.estimatedRunoutMinutes! > 0)
    }

    @Test("Display runout formats correctly")
    func displayRunout() {
        let state = PaceState(
            status: .inDebt, usagePercent: 80,
            debtPercent: 20, estimatedRunoutMinutes: 135,
            windowEnd: windowEnd
        )
        #expect(state.displayRunout == "~2h 15m")

        let shortState = PaceState(
            status: .inDebt, usagePercent: 90,
            debtPercent: 40, estimatedRunoutMinutes: 45,
            windowEnd: windowEnd
        )
        #expect(shortState.displayRunout == "~45m")
    }
}
