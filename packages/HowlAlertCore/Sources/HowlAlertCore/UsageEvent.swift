import Foundation

/// Which transcript a usage row came from. A turn can appear in both a parent
/// transcript and a `/subagents/` transcript; `.parent` wins during dedupe so
/// the same turn isn't counted twice.
public enum TranscriptRole: Sendable, Equatable {
    case parent
    case subagent
}

/// One assistant turn's token usage, parsed from a `~/.claude` JSONL line.
///
/// Token categories are kept separate (Anthropic prices them differently) but
/// `totalTokens` sums all four — cache tokens count toward the 5-hour window.
public struct UsageEvent: Sendable, Equatable {
    public let timestamp: Date
    public let model: String
    public let inputTokens: Int
    public let cacheCreationTokens: Int
    public let cacheReadTokens: Int
    public let outputTokens: Int
    public let messageId: String?
    public let requestId: String?
    public let sessionId: String?
    public let isSidechain: Bool
    public let role: TranscriptRole

    public init(
        timestamp: Date,
        model: String,
        inputTokens: Int,
        cacheCreationTokens: Int,
        cacheReadTokens: Int,
        outputTokens: Int,
        messageId: String? = nil,
        requestId: String? = nil,
        sessionId: String? = nil,
        isSidechain: Bool = false,
        role: TranscriptRole = .parent
    ) {
        self.timestamp = timestamp
        self.model = model
        self.inputTokens = max(0, inputTokens)
        self.cacheCreationTokens = max(0, cacheCreationTokens)
        self.cacheReadTokens = max(0, cacheReadTokens)
        self.outputTokens = max(0, outputTokens)
        self.messageId = messageId
        self.requestId = requestId
        self.sessionId = sessionId
        self.isSidechain = isSidechain
        self.role = role
    }

    /// All token categories summed. Cache reads/creations are included — they
    /// consume the rolling-window budget just like input/output.
    public var totalTokens: Int {
        inputTokens + cacheCreationTokens + cacheReadTokens + outputTokens
    }

    /// Dedupe key. Streaming chunks of one turn share `messageId:requestId`, so
    /// the final cumulative chunk wins. Returns `nil` when either id is missing
    /// (such rows are kept as distinct so usage is never silently dropped).
    public var dedupeKey: String? {
        guard let messageId, let requestId else { return nil }
        return "\(messageId):\(requestId)"
    }
}
