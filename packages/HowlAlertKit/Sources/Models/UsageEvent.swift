import Foundation

public struct UsageEvent: Codable, Identifiable, Sendable {
	public let id: UUID
	public let model: String
	public let inputTokens: Int
	public let outputTokens: Int
	public let cacheReadTokens: Int
	public let cacheWriteTokens: Int
	public let timestamp: Date
	public let sessionId: String?

	public var totalTokens: Int { inputTokens + outputTokens + cacheReadTokens + cacheWriteTokens }

	public init(
		id: UUID = UUID(),
		model: String,
		inputTokens: Int,
		outputTokens: Int,
		cacheReadTokens: Int,
		cacheWriteTokens: Int,
		timestamp: Date,
		sessionId: String? = nil
	) {
		self.id = id
		self.model = model
		self.inputTokens = inputTokens
		self.outputTokens = outputTokens
		self.cacheReadTokens = cacheReadTokens
		self.cacheWriteTokens = cacheWriteTokens
		self.timestamp = timestamp
		self.sessionId = sessionId
	}
}
