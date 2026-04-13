// CloudKitSyncManager — Handles all CloudKit read/write for HowlAlert
// © 2026 MrDemonWolf, Inc.

import Foundation
import CloudKit
import Models

public final class CloudKitSyncManager: Sendable {
    private let container: CKContainer
    private let privateDB: CKDatabase

    public init() {
        self.container = CKContainer(identifier: HowlAlertConstants.cloudKitContainer)
        self.privateDB = container.privateCloudDatabase
    }

    // MARK: - Device Pairing

    public func saveDevicePairing(_ config: PairingConfig) async throws {
        let record = CKRecord(recordType: HowlAlertConstants.devicePairingRecordType,
                              recordID: CKRecord.ID(recordName: config.deviceID))
        record["apnsDeviceToken"] = config.apnsDeviceToken
        record["deviceName"] = config.deviceName
        record["osVersion"] = config.osVersion
        record["lastUpdated"] = config.lastUpdated

        try await privateDB.save(record)
    }

    public func fetchAllDevicePairings() async throws -> [PairingConfig] {
        let query = CKQuery(recordType: HowlAlertConstants.devicePairingRecordType,
                            predicate: NSPredicate(value: true))
        let (results, _) = try await privateDB.records(matching: query)

        return results.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return PairingConfig(
                deviceID: record.recordID.recordName,
                deviceName: record["deviceName"] as? String ?? "Unknown",
                apnsDeviceToken: record["apnsDeviceToken"] as? String ?? "",
                osVersion: record["osVersion"] as? String ?? "",
                lastUpdated: record["lastUpdated"] as? Date ?? .now
            )
        }
    }

    public func removeDevicePairing(deviceID: String) async throws {
        let recordID = CKRecord.ID(recordName: deviceID)
        try await privateDB.deleteRecord(withID: recordID)
    }

    // MARK: - Entitlement

    public func saveEntitlement(_ state: EntitlementState) async throws {
        let recordID = CKRecord.ID(recordName: "entitlement")
        let record = CKRecord(recordType: HowlAlertConstants.entitlementRecordType,
                              recordID: recordID)
        record["entitlementActive"] = state.entitlementActive ? 1 : 0
        record["expiresAt"] = state.expiresAt
        record["productID"] = state.productID
        record["updatedAt"] = state.updatedAt

        try await privateDB.save(record)
    }

    public func fetchEntitlement() async throws -> EntitlementState? {
        let recordID = CKRecord.ID(recordName: "entitlement")
        do {
            let record = try await privateDB.record(for: recordID)
            return EntitlementState(
                entitlementActive: (record["entitlementActive"] as? Int ?? 0) == 1,
                expiresAt: record["expiresAt"] as? Date,
                productID: record["productID"] as? String,
                updatedAt: record["updatedAt"] as? Date ?? .now
            )
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        }
    }

    // MARK: - Usage Snapshots (Multi-Mac)

    public func saveUsageSnapshot(_ snapshot: UsageSnapshot) async throws {
        let recordID = CKRecord.ID(recordName: "snapshot-\(snapshot.sourceDeviceID)")
        let record = CKRecord(recordType: HowlAlertConstants.usageSnapshotRecordType,
                              recordID: recordID)
        record["sourceDeviceID"] = snapshot.sourceDeviceID
        record["sourceDeviceName"] = snapshot.sourceDeviceName
        record["sourceDeviceType"] = snapshot.sourceDeviceType.rawValue
        record["model"] = snapshot.model
        record["outputTokens"] = snapshot.outputTokens
        record["cacheReadInputTokens"] = snapshot.cacheReadInputTokens
        record["cacheCreationInputTokens"] = snapshot.cacheCreationInputTokens
        record["windowStart"] = snapshot.windowStart
        record["windowEnd"] = snapshot.windowEnd
        record["updatedAt"] = snapshot.updatedAt

        try await privateDB.save(record)
    }

    public func fetchAllUsageSnapshots() async throws -> [UsageSnapshot] {
        let query = CKQuery(recordType: HowlAlertConstants.usageSnapshotRecordType,
                            predicate: NSPredicate(value: true))
        let (results, _) = try await privateDB.records(matching: query)

        return results.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return UsageSnapshot(
                sourceDeviceID: record["sourceDeviceID"] as? String ?? "",
                sourceDeviceName: record["sourceDeviceName"] as? String ?? "Unknown",
                sourceDeviceType: DeviceType(rawValue: record["sourceDeviceType"] as? String ?? "") ?? .unknown,
                model: record["model"] as? String ?? "unknown",
                outputTokens: record["outputTokens"] as? Int ?? 0,
                cacheReadInputTokens: record["cacheReadInputTokens"] as? Int ?? 0,
                cacheCreationInputTokens: record["cacheCreationInputTokens"] as? Int ?? 0,
                windowStart: record["windowStart"] as? Date ?? .now,
                windowEnd: record["windowEnd"] as? Date ?? .now,
                updatedAt: record["updatedAt"] as? Date ?? .now
            )
        }
    }

    // MARK: - Subscriptions

    public func setupSubscriptions() async throws {
        let recordTypes = [
            HowlAlertConstants.usageSnapshotRecordType,
            HowlAlertConstants.entitlementRecordType,
            HowlAlertConstants.devicePairingRecordType,
        ]

        for recordType in recordTypes {
            let subscriptionID = "howlalert-\(recordType)"
            let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)

            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo

            try await privateDB.save(subscription)
        }
    }

    // MARK: - Cleanup

    public func removeUsageSnapshot(deviceID: String) async throws {
        let recordID = CKRecord.ID(recordName: "snapshot-\(deviceID)")
        try await privateDB.deleteRecord(withID: recordID)
    }
}
