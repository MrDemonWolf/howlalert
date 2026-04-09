import Foundation

// Aggregated usage state at a point in time
public struct UsageSnapshot: Sendable, Codable {
    public let sessionTokens: Int        // tokens used in current 5h session
    public let weeklyTokens: Int         // tokens used this week
    public let sessionWindowStart: Date  // when current 5h session started
    public let weeklyWindowStart: Date   // when current week started
    public let model: String             // last active model
    public let capturedAt: Date

    public init(
        sessionTokens: Int,
        weeklyTokens: Int,
        sessionWindowStart: Date,
        weeklyWindowStart: Date,
        model: String,
        capturedAt: Date = .now
    ) {
        self.sessionTokens = sessionTokens
        self.weeklyTokens = weeklyTokens
        self.sessionWindowStart = sessionWindowStart
        self.weeklyWindowStart = weeklyWindowStart
        self.model = model
        self.capturedAt = capturedAt
    }
}
