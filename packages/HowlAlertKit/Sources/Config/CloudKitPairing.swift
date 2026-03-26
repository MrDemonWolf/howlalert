import Foundation
import CloudKit

/// Manages device pairing via CloudKit private database
public actor CloudKitPairing {
	public static let shared = CloudKitPairing()

	private let container: CKContainer
	private let database: CKDatabase
	private let recordType = "PairingConfig"

	public init(containerIdentifier: String = "iCloud.com.mrdemonwolf.howlalert") {
		self.container = CKContainer(identifier: containerIdentifier)
		self.database = container.privateCloudDatabase
	}

	// MARK: - iOS: Write pairing config

	/// Save or update the pairing config (called from iOS after push registration)
	public func savePairingConfig(_ config: PairingConfig) async throws {
		let record = configToRecord(config)
		let operation = CKModifyRecordsOperation(
			recordsToSave: [record],
			recordIDsToDelete: nil
		)
		operation.savePolicy = .changedKeys
		operation.qualityOfService = .userInitiated

		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			operation.modifyRecordsResultBlock = { result in
				switch result {
				case .success:
					continuation.resume()
				case .failure(let error):
					continuation.resume(throwing: error)
				}
			}
			database.add(operation)
		}
	}

	// MARK: - macOS: Read pairing configs

	/// Fetch all pairing configs from CloudKit (called from macOS on launch)
	public func fetchPairingConfigs() async throws -> [PairingConfig] {
		let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
		query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

		let (results, _) = try await database.records(matching: query)

		var configs: [PairingConfig] = []
		for (_, result) in results {
			switch result {
			case .success(let record):
				if let config = recordToConfig(record) {
					configs.append(config)
				}
			case .failure:
				continue
			}
		}
		return configs
	}

	// MARK: - Shared

	/// Check if CloudKit is available
	public func checkAccountStatus() async throws -> CKAccountStatus {
		return try await container.accountStatus()
	}

	// MARK: - Private helpers

	private func configToRecord(_ config: PairingConfig) -> CKRecord {
		let recordID = CKRecord.ID(
			recordName: "pairing-\(config.apnsDeviceToken.prefix(32))"
		)
		let record = CKRecord(recordType: recordType, recordID: recordID)
		record["secret"] = config.secret as CKRecordValue
		record["apnsDeviceToken"] = config.apnsDeviceToken as CKRecordValue
		record["deviceName"] = config.deviceName as CKRecordValue
		record["osVersion"] = config.osVersion as CKRecordValue
		record["createdAt"] = config.createdAt as CKRecordValue
		return record
	}

	private func recordToConfig(_ record: CKRecord) -> PairingConfig? {
		guard
			let secret = record["secret"] as? String,
			let apnsDeviceToken = record["apnsDeviceToken"] as? String,
			let deviceName = record["deviceName"] as? String,
			let osVersion = record["osVersion"] as? String,
			let createdAt = record["createdAt"] as? Date
		else {
			return nil
		}

		return PairingConfig(
			secret: secret,
			apnsDeviceToken: apnsDeviceToken,
			deviceName: deviceName,
			osVersion: osVersion,
			createdAt: createdAt
		)
	}
}
