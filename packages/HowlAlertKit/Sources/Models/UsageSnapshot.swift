import Foundation

public struct UsageSnapshot: Sendable, Codable, Equatable {
    public let inputTokens: Int
    public let outputTokens: Int
    public let cacheCreationTokens: Int
    public let cacheReadTokens: Int
    public let timestamp: Date

    public var totalTokens: Int {
        inputTokens + outputTokens + cacheCreationTokens + cacheReadTokens
    }

    public init(inputTokens: Int, outputTokens: Int, cacheCreationTokens: Int, cacheReadTokens: Int, timestamp: Date = .now) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheCreationTokens = cacheCreationTokens
        self.cacheReadTokens = cacheReadTokens
        self.timestamp = timestamp
    }
}
