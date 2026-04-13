// SnapshotThrottler — Rate-limit CloudKit writes to 1 per 10 seconds per device
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public actor SnapshotThrottler {
    private var lastWrite: Date?
    private let interval: TimeInterval

    public init(interval: TimeInterval = HowlAlertConstants.snapshotThrottleSeconds) {
        self.interval = interval
    }

    /// Returns true if enough time has passed since the last write.
    public func shouldWrite(now: Date = .now) -> Bool {
        guard let last = lastWrite else {
            return true
        }
        return now.timeIntervalSince(last) >= interval
    }

    /// Mark that a write occurred.
    public func didWrite(at date: Date = .now) {
        lastWrite = date
    }

    /// Conditionally write a snapshot if throttle allows.
    public func throttledWrite(
        _ snapshot: Models.UsageSnapshot,
        using syncManager: CloudKitSyncManager
    ) async throws -> Bool {
        guard shouldWrite() else { return false }
        try await syncManager.saveUsageSnapshot(snapshot)
        didWrite()
        return true
    }
}
