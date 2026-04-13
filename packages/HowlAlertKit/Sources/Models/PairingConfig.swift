// PairingConfig — Device pairing record for CloudKit
// © 2026 MrDemonWolf, Inc.

import Foundation

public struct PairingConfig: Codable, Sendable, Equatable {
    public let deviceID: String
    public let deviceName: String
    public let apnsDeviceToken: String
    public let osVersion: String
    public let lastUpdated: Date

    public init(
        deviceID: String,
        deviceName: String,
        apnsDeviceToken: String,
        osVersion: String,
        lastUpdated: Date = .now
    ) {
        self.deviceID = deviceID
        self.deviceName = deviceName
        self.apnsDeviceToken = apnsDeviceToken
        self.osVersion = osVersion
        self.lastUpdated = lastUpdated
    }
}
