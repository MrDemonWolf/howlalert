// ClaudeCodeProvider — Parses Claude Code JSONL session files
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public struct ClaudeCodeProvider: UsageProvider {
    public let id = "claude-code"
    public let displayName = "Claude Code"

    public var sessionPath: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/projects", isDirectory: true)
    }

    public init() {}

    public func parseSnapshot(from fileURL: URL) throws -> UsageSnapshot {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw ProviderError.fileNotFound(fileURL)
        }

        let data = try Data(contentsOf: fileURL)
        let lines = data.split(separator: UInt8(ascii: "\n"))

        var outputTokens = 0
        var cacheReadInputTokens = 0
        var cacheCreationInputTokens = 0
        var model = "unknown"
        var lastTimestamp: Date?

        for line in lines {
            guard let entry = try? JSONDecoder.jsonlDecoder.decode(JSONLEntry.self, from: Data(line)) else {
                continue
            }

            if let usage = entry.usage {
                outputTokens += usage.output_tokens ?? 0
                cacheReadInputTokens += usage.cache_read_input_tokens ?? 0
                cacheCreationInputTokens += usage.cache_creation_input_tokens ?? 0
            }

            if let m = entry.model, !m.isEmpty {
                model = m
            }

            if let ts = entry.timestamp {
                lastTimestamp = ts
            }
        }

        let now = Date.now
        return UsageSnapshot(
            sourceDeviceID: "",
            sourceDeviceName: "",
            sourceDeviceType: .unknown,
            model: model,
            outputTokens: outputTokens,
            cacheReadInputTokens: cacheReadInputTokens,
            cacheCreationInputTokens: cacheCreationInputTokens,
            windowStart: now.addingTimeInterval(-5 * 3600),
            windowEnd: now,
            updatedAt: lastTimestamp ?? now
        )
    }

    public func detectDoneEvent(in snapshot: UsageSnapshot) -> Bool {
        let idleThreshold: TimeInterval = 30
        return Date.now.timeIntervalSince(snapshot.updatedAt) > idleThreshold
    }
}

// MARK: - JSONL Parsing Types

struct JSONLEntry: Decodable {
    let type: String?
    let model: String?
    let timestamp: Date?
    let usage: JSONLUsage?
}

struct JSONLUsage: Decodable {
    let output_tokens: Int?
    let cache_read_input_tokens: Int?
    let cache_creation_input_tokens: Int?
}

extension JSONDecoder {
    static let jsonlDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
