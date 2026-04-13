// ThresholdColor — Crit bar color from usage percentage
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public enum CritState: String, Codable, Sendable {
    case ok         // < 60%
    case approaching // 60–85%
    case limitHit   // 85%+
    case reset      // fresh window
}

public struct ThresholdColor: Sendable {
    public static let cyan   = HexColor(hex: "#0FACED")
    public static let amber  = HexColor(hex: "#F5A623")
    public static let red    = HexColor(hex: "#FF3B30")
    public static let green  = HexColor(hex: "#34C759")
    public static let navy   = HexColor(hex: "#091533")

    public init() {}

    public func state(for usagePercent: Double, isReset: Bool = false) -> CritState {
        if isReset { return .reset }
        if usagePercent >= 85 { return .limitHit }
        if usagePercent >= 60 { return .approaching }
        return .ok
    }

    public func color(for state: CritState) -> HexColor {
        switch state {
        case .ok: return Self.cyan
        case .approaching: return Self.amber
        case .limitHit: return Self.red
        case .reset: return Self.green
        }
    }

    public func colorForPercent(_ percent: Double, isReset: Bool = false) -> HexColor {
        color(for: state(for: percent, isReset: isReset))
    }
}

public struct HexColor: Sendable, Equatable, Codable {
    public let hex: String

    public init(hex: String) {
        self.hex = hex
    }
}
