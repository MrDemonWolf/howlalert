import Foundation

public enum LimitMultiplier {

    /// Compute effective token limit given base limit and remote config
    public static func effectiveLimit(
        basePlanLimit: Int,
        config: RemoteConfig,
        at date: Date = .now
    ) -> Int {
        let multiplier = config.multiplier
        // If there's an active promo and it hasn't ended, use it
        if let promo = config.activePromo, date < promo.endsAt {
            return Int(Double(basePlanLimit) * multiplier)
        }
        // No active promo — use base multiplier (usually 1.0)
        return Int(Double(basePlanLimit) * (config.activePromo == nil ? multiplier : 1.0))
    }
}
