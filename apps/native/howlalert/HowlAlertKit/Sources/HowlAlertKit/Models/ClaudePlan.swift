import Foundation

public enum ClaudePlan: String, Codable, CaseIterable, Identifiable {
	case free = "free"
	case pro = "pro"
	case max5 = "max5"
	case max20 = "max20"

	public var id: String { rawValue }

	public var displayName: String {
		switch self {
		case .free: return "Free"
		case .pro: return "Pro"
		case .max5: return "Max (5x)"
		case .max20: return "Max (20x)"
		}
	}

	public var monthlyPrice: Double {
		switch self {
		case .free: return 0
		case .pro: return 20
		case .max5: return 100
		case .max20: return 200
		}
	}
}
