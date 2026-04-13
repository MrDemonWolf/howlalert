import Testing
@testable import ColorState
import Models

@Suite("CritBarColor")
struct CritBarColorTests {

    @Test("calm state returns fraction 0.3")
    func calm_fraction() {
        #expect(CritBarColor.fraction(for: .calm) == 0.3)
    }

    @Test("warn state returns fraction 0.6")
    func warn_fraction() {
        #expect(CritBarColor.fraction(for: .warn) == 0.6)
    }

    @Test("critical state returns fraction 0.9")
    func critical_fraction() {
        #expect(CritBarColor.fraction(for: .critical) == 0.9)
    }

    @Test("all PaceState cases are covered and return valid fractions")
    func allCases_covered() {
        for state in PaceState.allCases {
            let fraction = CritBarColor.fraction(for: state)
            #expect(fraction > 0 && fraction <= 1.0, "State \(state) returned out-of-range fraction \(fraction)")
        }
    }
}
