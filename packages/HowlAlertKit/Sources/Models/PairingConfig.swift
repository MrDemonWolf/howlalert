import Foundation

public struct PairingConfig: Codable, Sendable {
	public let secret: String
	public let apnsDeviceToken: String
	public let deviceName: String
	public let osVersion: String
	public let createdAt: Date

	public init(
		secret: String,
		apnsDeviceToken: String,
		deviceName: String,
		osVersion: String,
		createdAt: Date
	) {
		self.secret = secret
		self.apnsDeviceToken = apnsDeviceToken
		self.deviceName = deviceName
		self.osVersion = osVersion
		self.createdAt = createdAt
	}
}
