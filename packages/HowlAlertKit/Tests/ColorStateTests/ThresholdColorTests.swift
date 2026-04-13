// ThresholdColorTests
// © 2026 MrDemonWolf, Inc.

import Testing
@testable import ColorState

@Suite("ThresholdColor")
struct ThresholdColorTests {
    let tc = ThresholdColor()

    @Test("Under 60% is OK / cyan")
    func okState() {
        #expect(tc.state(for: 42) == .ok)
        #expect(tc.color(for: .ok) == ThresholdColor.cyan)
    }

    @Test("60-85% is approaching / amber")
    func approachingState() {
        #expect(tc.state(for: 60) == .approaching)
        #expect(tc.state(for: 84.9) == .approaching)
        #expect(tc.color(for: .approaching) == ThresholdColor.amber)
    }

    @Test("85%+ is limit hit / red")
    func limitHitState() {
        #expect(tc.state(for: 85) == .limitHit)
        #expect(tc.state(for: 100) == .limitHit)
        #expect(tc.color(for: .limitHit) == ThresholdColor.red)
    }

    @Test("Reset overrides percentage")
    func resetState() {
        #expect(tc.state(for: 95, isReset: true) == .reset)
        #expect(tc.color(for: .reset) == ThresholdColor.green)
    }
}
