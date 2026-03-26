import Foundation

public struct UsageSnapshot: Codable, Sendable {
	public let inputTokens: Int
	public let outputTokens: Int
	public let cacheReadTokens: Int
	public let cacheWriteTokens: Int
	public let model: String
	public let timestamp: Date
	public let sessionId: String?

	public var totalTokens: Int { inputTokens + outputTokens }

	public init(
		inputTokens: Int,
		outputTokens: Int,
		cacheReadTokens: Int,
		cacheWriteTokens: Int,
		model: String,
		timestamp: Date,
		sessionId: String?
	) {
		self.inputTokens = inputTokens
		self.outputTokens = outputTokens
		self.cacheReadTokens = cacheReadTokens
		self.cacheWriteTokens = cacheWriteTokens
		self.model = model
		self.timestamp = timestamp
		self.sessionId = sessionId
	}
}
