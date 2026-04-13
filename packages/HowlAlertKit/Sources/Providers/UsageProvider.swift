// UsageProvider — Protocol for AI CLI usage data sources
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public enum ProviderError: Error, Sendable {
    case notImplemented
    case parseError(String)
    case fileNotFound(URL)
}

public protocol UsageProvider: Sendable {
    var id: String { get }
    var displayName: String { get }
    var sessionPath: URL { get }
    func parseSnapshot(from fileURL: URL) throws -> UsageSnapshot
    func detectDoneEvent(in snapshot: UsageSnapshot) -> Bool
}
