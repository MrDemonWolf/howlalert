import Foundation

public enum PaceStatus: String, Sendable, Codable {
    case onTrack
    case inDebt      // burning too fast
    case inReserve   // ahead of pace
}

public struct PaceState: Sendable {
    public let status: PaceStatus
    public let pacePercent: Double  // positive = in debt %, negative = reserve %
    public let runsOutAt: Date?     // nil if on track or in reserve

    public init(status: PaceStatus, pacePercent: Double, runsOutAt: Date?) {
        self.status = status
        self.pacePercent = pacePercent
        self.runsOutAt = runsOutAt
    }

    public var runsOutInSeconds: TimeInterval? {
        runsOutAt.map { $0.timeIntervalSinceNow }
    }
}
