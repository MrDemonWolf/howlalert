// UsageSnapshot — Token usage at a point in time, per-device
// © 2026 MrDemonWolf, Inc.

import Foundation

public struct UsageSnapshot: Codable, Sendable, Equatable {
    public let sourceDeviceID: String
    public let sourceDeviceName: String
    public let sourceDeviceType: DeviceType
    public let model: String
    public let outputTokens: Int
    public let cacheReadInputTokens: Int
    public let cacheCreationInputTokens: Int
    public let windowStart: Date
    public let windowEnd: Date
    public let updatedAt: Date

    public var totalBillableTokens: Int {
        outputTokens + cacheReadInputTokens + cacheCreationInputTokens
    }

    public init(
        sourceDeviceID: String,
        sourceDeviceName: String,
        sourceDeviceType: DeviceType,
        model: String,
        outputTokens: Int,
        cacheReadInputTokens: Int,
        cacheCreationInputTokens: Int,
        windowStart: Date,
        windowEnd: Date,
        updatedAt: Date = .now
    ) {
        self.sourceDeviceID = sourceDeviceID
        self.sourceDeviceName = sourceDeviceName
        self.sourceDeviceType = sourceDeviceType
        self.model = model
        self.outputTokens = outputTokens
        self.cacheReadInputTokens = cacheReadInputTokens
        self.cacheCreationInputTokens = cacheCreationInputTokens
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.updatedAt = updatedAt
    }
}

public enum DeviceType: String, Codable, Sendable {
    case macBookPro = "mbp"
    case macBookAir = "mba"
    case macMini = "mini"
    case macStudio = "studio"
    case iMac = "imac"
    case macPro = "pro"
    case unknown = "unknown"

    public var emoji: String {
        switch self {
        case .macBookPro, .macBookAir: return "💻"
        case .macMini, .macStudio, .macPro: return "🖥️"
        case .iMac: return "🖥️"
        case .unknown: return "🖥️"
        }
    }
}
