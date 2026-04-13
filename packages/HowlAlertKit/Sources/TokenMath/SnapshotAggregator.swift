// SnapshotAggregator — Merge multi-Mac UsageSnapshot records
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public struct AggregatedUsage: Sendable, Equatable {
    public let totalOutputTokens: Int
    public let totalCacheReadInputTokens: Int
    public let totalCacheCreationInputTokens: Int
    public let totalBillableTokens: Int
    public let activeMacs: [MacSummary]
    public let latestUpdate: Date
    public let latestDeviceName: String

    public struct MacSummary: Sendable, Equatable {
        public let deviceID: String
        public let deviceName: String
        public let deviceType: DeviceType
        public let contributionPercent: Double
        public let lastSeen: Date
        public let isActive: Bool
    }
}

public struct SnapshotAggregator: Sendable {
    private static let staleThreshold: TimeInterval = 30 * 60 // 30 min

    public init() {}

    public func aggregate(_ snapshots: [UsageSnapshot], now: Date = .now) -> AggregatedUsage {
        guard !snapshots.isEmpty else {
            return AggregatedUsage(
                totalOutputTokens: 0,
                totalCacheReadInputTokens: 0,
                totalCacheCreationInputTokens: 0,
                totalBillableTokens: 0,
                activeMacs: [],
                latestUpdate: now,
                latestDeviceName: ""
            )
        }

        let totalOutput = snapshots.reduce(0) { $0 + $1.outputTokens }
        let totalCacheRead = snapshots.reduce(0) { $0 + $1.cacheReadInputTokens }
        let totalCacheCreate = snapshots.reduce(0) { $0 + $1.cacheCreationInputTokens }
        let totalBillable = totalOutput + totalCacheRead + totalCacheCreate

        let latest = snapshots.max(by: { $0.updatedAt < $1.updatedAt })!

        let macs = snapshots.map { snapshot -> AggregatedUsage.MacSummary in
            let contribution = totalBillable > 0
                ? Double(snapshot.totalBillableTokens) / Double(totalBillable) * 100
                : 0
            let isActive = now.timeIntervalSince(snapshot.updatedAt) < Self.staleThreshold

            return AggregatedUsage.MacSummary(
                deviceID: snapshot.sourceDeviceID,
                deviceName: snapshot.sourceDeviceName,
                deviceType: snapshot.sourceDeviceType,
                contributionPercent: contribution,
                lastSeen: snapshot.updatedAt,
                isActive: isActive
            )
        }.sorted { $0.lastSeen > $1.lastSeen }

        return AggregatedUsage(
            totalOutputTokens: totalOutput,
            totalCacheReadInputTokens: totalCacheRead,
            totalCacheCreationInputTokens: totalCacheCreate,
            totalBillableTokens: totalBillable,
            activeMacs: macs,
            latestUpdate: latest.updatedAt,
            latestDeviceName: latest.sourceDeviceName
        )
    }
}
