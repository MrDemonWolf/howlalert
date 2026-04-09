import Foundation

// Shape matches Worker KV config JSON
public struct RemoteConfig: Sendable, Codable {
    public struct PromoConfig: Sendable, Codable {
        public let name: String
        public let endsAt: Date

        public init(name: String, endsAt: Date) {
            self.name = name
            self.endsAt = endsAt
        }
    }

    public struct PlanLimits: Sendable, Codable {
        public let free: Int
        public let pro: Int
        public let max5: Int
        public let max20: Int

        public init(free: Int, pro: Int, max5: Int, max20: Int) {
            self.free = free
            self.pro = pro
            self.max5 = max5
            self.max20 = max20
        }
    }

    public let multiplier: Double
    public let activePromo: PromoConfig?
    public let planLimits: PlanLimits
    public let updatedAt: Date?

    public init(multiplier: Double, activePromo: PromoConfig?, planLimits: PlanLimits, updatedAt: Date?) {
        self.multiplier = multiplier
        self.activePromo = activePromo
        self.planLimits = planLimits
        self.updatedAt = updatedAt
    }

    public static let `default` = RemoteConfig(
        multiplier: 1.0,
        activePromo: nil,
        planLimits: PlanLimits(free: 40_000, pro: 200_000, max5: 1_000_000, max20: 4_000_000),
        updatedAt: nil
    )
}
