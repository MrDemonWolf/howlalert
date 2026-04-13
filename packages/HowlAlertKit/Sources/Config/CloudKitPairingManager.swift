import Foundation
import Models

/// Stub — full implementation in HAA-69
public actor CloudKitPairingManager: Sendable {
    public static let shared = CloudKitPairingManager()
    private init() {}

    public func savePairing(_ config: PairingConfig) async throws {
        // TODO: HAA-69 — write DevicePairing CKRecord to private database
    }

    public func fetchPairings() async throws -> [PairingConfig] {
        // TODO: HAA-69 — query DevicePairing CKRecords
        return []
    }
}
