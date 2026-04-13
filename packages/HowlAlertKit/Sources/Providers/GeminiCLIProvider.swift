// GeminiCLIProvider — Stub for Gemini CLI support
// TODO: v2.0 — Implement full Gemini CLI JSONL parsing
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public struct GeminiCLIProvider: UsageProvider {
    public let id = "gemini-cli"
    public let displayName = "Gemini CLI"

    public var sessionPath: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".gemini/tmp", isDirectory: true)
    }

    public init() {}

    public func parseSnapshot(from fileURL: URL) throws -> UsageSnapshot {
        throw ProviderError.notImplemented
    }

    public func detectDoneEvent(in snapshot: UsageSnapshot) -> Bool {
        false
    }
}
