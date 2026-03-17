import Foundation

public struct UsageEvent: Codable, Identifiable, Equatable {
    public let id: String
    public let sessionId: String
    public let timestamp: Date
    public let model: String
    public let inputTokens: Int
    public let outputTokens: Int
    public let cacheReadTokens: Int
    public let cacheWriteTokens: Int
    public let costUSD: Double

    public init(
        id: String = UUID().uuidString,
        sessionId: String,
        timestamp: Date = .now,
        model: String,
        inputTokens: Int,
        outputTokens: Int,
        cacheReadTokens: Int = 0,
        cacheWriteTokens: Int = 0,
        costUSD: Double
    ) {
        self.id = id
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.model = model
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheReadTokens = cacheReadTokens
        self.cacheWriteTokens = cacheWriteTokens
        self.costUSD = costUSD
    }
}
