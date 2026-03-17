import Foundation

public struct HookEvent: Codable {
    public let sessionId: String?
    public let toolName: String?
    public let model: String?
    public let inputTokens: Int?
    public let outputTokens: Int?
    public let cacheReadTokens: Int?
    public let cacheWriteTokens: Int?
    public let costUSD: Double?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case toolName = "tool_name"
        case model
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case cacheReadTokens = "cache_read_tokens"
        case cacheWriteTokens = "cache_write_tokens"
        case costUSD = "cost_usd"
    }

    public func toUsageEvent() -> UsageEvent? {
        guard let costUSD else { return nil }
        return UsageEvent(
            sessionId: sessionId ?? "unknown",
            model: model ?? "unknown",
            inputTokens: inputTokens ?? 0,
            outputTokens: outputTokens ?? 0,
            cacheReadTokens: cacheReadTokens ?? 0,
            cacheWriteTokens: cacheWriteTokens ?? 0,
            costUSD: costUSD
        )
    }
}

public struct HookEventParser {
    public static func parse(from data: Data) throws -> HookEvent {
        try JSONDecoder().decode(HookEvent.self, from: data)
    }

    public static func parseFromStdin() throws -> HookEvent {
        var inputData = Data()
        while let line = readLine(strippingNewline: false) {
            inputData.append(contentsOf: line.utf8)
        }
        return try parse(from: inputData)
    }
}
