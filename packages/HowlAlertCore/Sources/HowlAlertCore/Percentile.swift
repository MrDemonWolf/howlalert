import Foundation

/// Percentile via linear interpolation between order statistics (the "type 7"
/// method — NumPy / Excel `PERCENTILE.INC` default).
public enum Percentile {
    /// - Parameters:
    ///   - values: unsorted samples.
    ///   - p: quantile in `0...1` (clamped).
    /// - Returns: the interpolated percentile, or 0 for an empty input.
    public static func value(_ values: [Double], _ p: Double) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        if sorted.count == 1 { return sorted[0] }
        let clamped = min(max(p, 0), 1)
        let rank = clamped * Double(sorted.count - 1)
        let lower = Int(rank.rounded(.down))
        let upper = Int(rank.rounded(.up))
        let fraction = rank - Double(lower)
        return sorted[lower] + (sorted[upper] - sorted[lower]) * fraction
    }
}
