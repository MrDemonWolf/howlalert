import Foundation

public enum ClaudePlan: String, Codable, CaseIterable, Identifiable {
	case free = "free"
	case pro = "pro"
	case maxScale5 = "max_scale_5"
	case maxScale20 = "max_scale_20"
	case team = "team"
	case enterprise = "enterprise"

	public var id: String { rawValue }

	public var displayName: String {
		switch self {
		case .free: return "Free"
		case .pro: return "Pro"
		case .maxScale5: return "Max (5x)"
		case .maxScale20: return "Max (20x)"
		case .team: return "Team"
		case .enterprise: return "Enterprise"
		}
	}

	public var monthlyPrice: Double {
		switch self {
		case .free: return 0.0
		case .pro: return 20.0
		case .maxScale5: return 100.0
		case .maxScale20: return 200.0
		case .team: return 30.0
		case .enterprise: return 0.0 // Custom pricing
		}
	}
}
