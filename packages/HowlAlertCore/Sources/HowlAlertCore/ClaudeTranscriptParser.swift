import Foundation

/// Parses Claude Code transcript JSONL into `UsageEvent`s.
///
/// Patterns studied from CodexBar (MIT) and reimplemented: a cheap substring
/// pre-filter before JSON decode, tolerant optional decoding, dedupe by
/// `messageId:requestId` (last write wins), and dropping all-zero rows.
public enum ClaudeTranscriptParser {

    /// Parse a single JSONL line. Returns `nil` for non-usage lines, malformed
    /// JSON, or rows with zero total tokens.
    /// - Parameter role: `.subagent` when the line came from a `/subagents/` file.
    public static func parseLine(_ line: String, role: TranscriptRole = .parent) -> UsageEvent? {
        // Fast reject before paying for a full JSON parse.
        guard line.contains("\"type\":\"assistant\""), line.contains("\"usage\"") else { return nil }
        guard let data = line.data(using: .utf8),
              let raw = try? JSONDecoder().decode(RawLine.self, from: data),
              raw.type == "assistant",
              let usage = raw.message?.usage,
              let model = raw.message?.model,
              let timestampString = raw.timestamp,
              let timestamp = parseTimestamp(timestampString)
        else { return nil }

        let event = UsageEvent(
            timestamp: timestamp,
            model: model,
            inputTokens: usage.input_tokens ?? 0,
            cacheCreationTokens: usage.cache_creation_input_tokens ?? 0,
            cacheReadTokens: usage.cache_read_input_tokens ?? 0,
            outputTokens: usage.output_tokens ?? 0,
            messageId: raw.message?.id,
            requestId: raw.requestId,
            sessionId: raw.sessionId ?? raw.session_id,
            isSidechain: raw.isSidechain ?? false,
            role: role
        )
        // A turn with no tokens contributes nothing to the window.
        return event.totalTokens > 0 ? event : nil
    }

    /// Parse every line of a transcript file's contents.
    public static func parse(contents: String, role: TranscriptRole = .parent) -> [UsageEvent] {
        contents
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { parseLine(String($0), role: role) }
    }

    /// Collapse duplicate turns. Same `dedupeKey` → last event wins (the final
    /// streaming chunk holds cumulative totals). Rows missing an id are kept.
    /// Cross-source ties (parent vs subagent / sidechain) resolve via `rowWins`.
    /// Output preserves first-seen chronological order of the surviving rows.
    public static func deduped(_ events: [UsageEvent]) -> [UsageEvent] {
        var winners: [String: UsageEvent] = [:]
        var order: [String] = []
        var unkeyed: [UsageEvent] = []

        for event in events {
            guard let key = event.dedupeKey else {
                unkeyed.append(event)
                continue
            }
            if let existing = winners[key] {
                winners[key] = rowWins(event, over: existing) ? event : existing
            } else {
                winners[key] = event
                order.append(key)
            }
        }

        return (order.compactMap { winners[$0] } + unkeyed)
            .sorted { $0.timestamp < $1.timestamp }
    }

    /// Tie-break for the same dedupe key: prefer non-sidechain, then a parent
    /// transcript over a subagent one. Otherwise the candidate (later) wins so
    /// streaming chunks converge on the final cumulative row.
    static func rowWins(_ candidate: UsageEvent, over existing: UsageEvent) -> Bool {
        if candidate.isSidechain != existing.isSidechain { return !candidate.isSidechain }
        if candidate.role != existing.role { return candidate.role == .parent }
        return true
    }

    // MARK: - Timestamp

    // Value-type format styles are Sendable, so they're safe as statics under
    // Swift 6 strict concurrency (unlike ISO8601DateFormatter).
    private static let isoFractional = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let isoPlain = Date.ISO8601FormatStyle(includingFractionalSeconds: false)

    /// ISO-8601 with or without fractional seconds. The string's own timezone
    /// offset is honored when building the instant.
    static func parseTimestamp(_ string: String) -> Date? {
        (try? isoFractional.parse(string)) ?? (try? isoPlain.parse(string))
    }

    // MARK: - Raw line shape

    private struct RawLine: Decodable {
        let type: String?
        let timestamp: String?
        let requestId: String?
        let sessionId: String?
        let session_id: String?
        let isSidechain: Bool?
        let message: RawMessage?

        struct RawMessage: Decodable {
            let model: String?
            let id: String?
            let usage: RawUsage?
        }

        struct RawUsage: Decodable {
            let input_tokens: Int?
            let cache_creation_input_tokens: Int?
            let cache_read_input_tokens: Int?
            let output_tokens: Int?
        }
    }
}
