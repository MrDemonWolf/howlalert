import Models
import Foundation

public enum PaceCalculator: Sendable {
    /// Returns projected tokens at window end given current usage and elapsed fraction.
    public static func projectedTotal(usedTokens: Int, elapsedFraction: Double) -> Int {
        guard elapsedFraction > 0 else { return 0 }
        return Int(Double(usedTokens) / elapsedFraction)
    }

    /// Returns usage percentage (0.0–1.0+).
    public static func usageRatio(usedTokens: Int, limit: Int) -> Double {
        guard limit > 0 else { return 0 }
        return Double(usedTokens) / Double(limit)
    }

    /// Returns the appropriate PaceState for a given ratio.
    public static func paceState(ratio: Double, warnThreshold: Double = 0.75, criticalThreshold: Double = 0.90) -> PaceState {
        if ratio >= criticalThreshold { return .critical }
        if ratio >= warnThreshold { return .warn }
        return .calm
    }
}
