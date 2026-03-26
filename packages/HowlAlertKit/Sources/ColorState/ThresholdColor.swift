import SwiftUI

public enum CritBarState: String, Codable, Sendable {
	case ok
	case approaching
	case limitHit
	case reset
}

public struct ThresholdColor {
	public static let ok = Color(hex: 0x0FACED)
	public static let approaching = Color(hex: 0xF5A623)
	public static let limitHit = Color(hex: 0xFF3B30)
	public static let reset = Color(hex: 0x34C759)
	public static let background = Color(hex: 0x091533)

	public static func state(for usagePercent: Double) -> CritBarState {
		if usagePercent < 60 { return .ok }
		if usagePercent < 85 { return .approaching }
		return .limitHit
	}

	public static func color(for state: CritBarState) -> Color {
		switch state {
		case .ok: return ok
		case .approaching: return approaching
		case .limitHit: return limitHit
		case .reset: return reset
		}
	}
}

extension Color {
	public init(hex: UInt32, opacity: Double = 1.0) {
		let red = Double((hex >> 16) & 0xFF) / 255.0
		let green = Double((hex >> 8) & 0xFF) / 255.0
		let blue = Double(hex & 0xFF) / 255.0
		self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
	}
}
