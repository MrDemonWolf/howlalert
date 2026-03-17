import Foundation

public struct UsageState: Equatable {
    public var dailyCost: Double
    public var totalInputTokens: Int
    public var totalOutputTokens: Int
    public var activeSessions: Int
    public var lastUpdated: Date
    public var recentEvents: [UsageEvent]

    public static let empty = UsageState(
        dailyCost: 0,
        totalInputTokens: 0,
        totalOutputTokens: 0,
        activeSessions: 0,
        lastUpdated: .distantPast,
        recentEvents: []
    )

    public var totalTokens: Int { totalInputTokens + totalOutputTokens }

    public init(
        dailyCost: Double,
        totalInputTokens: Int,
        totalOutputTokens: Int,
        activeSessions: Int,
        lastUpdated: Date,
        recentEvents: [UsageEvent]
    ) {
        self.dailyCost = dailyCost
        self.totalInputTokens = totalInputTokens
        self.totalOutputTokens = totalOutputTokens
        self.activeSessions = activeSessions
        self.lastUpdated = lastUpdated
        self.recentEvents = recentEvents
    }
}
