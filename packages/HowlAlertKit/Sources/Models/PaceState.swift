// PaceState — Current pace analysis result
// © 2026 MrDemonWolf, Inc.

import Foundation

public enum PaceStatus: String, Codable, Sendable {
    case onTrack
    case inDebt
    case inReserve
    case limitHit
    case freshReset
}

public struct PaceState: Codable, Sendable, Equatable {
    public let status: PaceStatus
    public let usagePercent: Double
    public let debtPercent: Double
    public let estimatedRunoutMinutes: Int?
    public let windowEnd: Date

    public init(
        status: PaceStatus,
        usagePercent: Double,
        debtPercent: Double = 0,
        estimatedRunoutMinutes: Int? = nil,
        windowEnd: Date
    ) {
        self.status = status
        self.usagePercent = usagePercent
        self.debtPercent = debtPercent
        self.estimatedRunoutMinutes = estimatedRunoutMinutes
        self.windowEnd = windowEnd
    }

    public var displayRunout: String? {
        guard let minutes = estimatedRunoutMinutes else { return nil }
        if minutes < 60 {
            return "~\(minutes)m"
        }
        let hours = minutes / 60
        let remaining = minutes % 60
        if remaining == 0 {
            return "~\(hours)h"
        }
        return "~\(hours)h \(remaining)m"
    }
}
