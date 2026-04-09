import Foundation
#if canImport(CloudKit)
import CloudKit
#endif

public struct PairingConfig: Sendable, Codable {
    public let pairingSecret: String   // UUID string
    public let deviceToken: String     // APNs device token hex string
    public let createdAt: Date
    public let platform: String        // "ios"

    public init(
        pairingSecret: String,
        deviceToken: String,
        createdAt: Date = .now,
        platform: String = "ios"
    ) {
        self.pairingSecret = pairingSecret
        self.deviceToken = deviceToken
        self.createdAt = createdAt
        self.platform = platform
    }

#if canImport(CloudKit)
    public init?(record: CKRecord) {
        guard let secret = record["pairingSecret"] as? String,
              let token = record["deviceToken"] as? String,
              let platform = record["platform"] as? String else { return nil }
        self.pairingSecret = secret
        self.deviceToken = token
        self.createdAt = record.creationDate ?? .now
        self.platform = platform
    }

    public func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "PairingConfig")
        record["pairingSecret"] = pairingSecret
        record["deviceToken"] = deviceToken
        record["platform"] = platform
        return record
    }
#endif
}
