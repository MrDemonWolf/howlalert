import Foundation

/// Describes usage pace relative to the expected burn rate within a rate window.
public struct UsagePace: Equatable, Sendable {
	public enum Stage: String, Equatable, Sendable {
		case comfortable  // well under expected pace
		case onTrack      // close to expected
		case moderate     // slightly ahead of expected
		case concerning   // notably ahead
		case critical     // will run out before reset
	}

	public let stage: Stage
	public let deficitPercent: Double?
	public let etaDescription: String?

	public init(
		stage: Stage,
		deficitPercent: Double? = nil,
		etaDescription: String? = nil
	) {
		self.stage = stage
		self.deficitPercent = deficitPercent
		self.etaDescription = etaDescription
	}

	/// Human-readable pace text, e.g. "3% in deficit"
	public var paceText: String? {
		guard let deficit = deficitPercent else { return nil }
		let absDeficit = abs(deficit)
		switch stage {
		case .comfortable:
			return String(format: "%.0f%% surplus", absDeficit)
		case .onTrack:
			return "On track"
		case .moderate:
			return String(format: "%.0f%% ahead", absDeficit)
		case .concerning, .critical:
			return String(format: "%.0f%% in deficit", absDeficit)
		}
	}

	/// Human-readable ETA text, e.g. "Runs out in 4d 5h"
	public var etaText: String? {
		etaDescription
	}
}
