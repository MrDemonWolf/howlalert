import Foundation

public struct PairingConfig: Sendable, Codable, Equatable {
    public let deviceToken: String
    public let deviceName: String
    public let workerURL: URL

    public init(deviceToken: String, deviceName: String, workerURL: URL) {
        self.deviceToken = deviceToken
        self.deviceName = deviceName
        self.workerURL = workerURL
    }
}
