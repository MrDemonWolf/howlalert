// JSONLEventParser.swift
//
// Streaming parser for Claude Code's transcript JSONL files. Each line is one
// JSON record; we extract the timestamp + (when present) the model identifier
// and treat every assistant turn as one billable request.
//
// We intentionally tolerate unknown record shapes — Claude Code's schema
// drifts, and we don't want a single bad line to break the watcher.

import Foundation

public struct ClaudeEvent: Sendable, Equatable {
    public let timestamp: Date
    public let model: String?

    public init(timestamp: Date, model: String? = nil) {
        self.timestamp = timestamp
        self.model = model
    }
}

public enum JSONLEventParser {
    // ISO8601DateFormatter isn't Sendable; the modern FormatStyle API is.
    // The two parse styles cover both fractional and plain ISO-8601 timestamps
    // that Claude Code emits.
    private static let isoFractional = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let isoPlain = Date.ISO8601FormatStyle(includingFractionalSeconds: false)

    /// Parse a chunk of newline-delimited JSON. Bad lines are skipped silently.
    public static func parse(chunk: String) -> [ClaudeEvent] {
        var events: [ClaudeEvent] = []
        for raw in chunk.split(whereSeparator: { $0 == "\n" || $0 == "\r" }) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty, let event = parseLine(line) else { continue }
            events.append(event)
        }
        return events
    }

    public static func parseLine(_ line: String) -> ClaudeEvent? {
        guard
            let data = line.data(using: .utf8),
            let obj = try? JSONSerialization.jsonObject(with: data),
            let dict = obj as? [String: Any]
        else { return nil }

        // Only assistant turns count toward usage.
        if let type = dict["type"] as? String, type != "assistant" {
            return nil
        }

        guard let ts = dict["timestamp"] as? String, let date = parseDate(ts) else {
            return nil
        }

        let model = (dict["message"] as? [String: Any])?["model"] as? String
                 ?? dict["model"] as? String
        return ClaudeEvent(timestamp: date, model: model)
    }

    private static func parseDate(_ s: String) -> Date? {
        if let d = try? isoFractional.parse(s) { return d }
        return try? isoPlain.parse(s)
    }
}
