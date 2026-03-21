import Foundation

public struct UsagePace {
	public enum Stage: String, Codable {
		case comfortable
		case onTrack
		case moderate
		case concerning
		case critical
	}

	public let stage: Stage
	public let deficitPercent: Double?
	public let etaDescription: String?

	public init(stage: Stage, deficitPercent: Double? = nil, etaDescription: String? = nil) {
		self.stage = stage
		self.deficitPercent = deficitPercent
		self.etaDescription = etaDescription
	}

	public var paceText: String? {
		guard let deficit = deficitPercent else { return nil }
		if deficit > 0 {
			return String(format: "%.0f%% in deficit", deficit)
		} else if deficit < 0 {
			return String(format: "%.0f%% ahead", abs(deficit))
		}
		return "On track"
	}
}
