import Foundation

/// Claude Code subscription plan, detected from ~/.claude/.credentials.json
public enum ClaudePlan: String, CaseIterable {
	case free
	case pro
	case max5
	case max20

	/// Approximate 5-hour session token limit for this plan.
	public var sessionTokenLimit: Int {
		switch self {
		case .free:  return 40_000
		case .pro:   return 200_000
		case .max5:  return 1_000_000
		case .max20: return 4_000_000
		}
	}

	/// Human-readable label shown in the menu bar.
	public var label: String {
		switch self {
		case .free:  return "Free"
		case .pro:   return "Pro"
		case .max5:  return "Max 5×"
		case .max20: return "Max 20×"
		}
	}

	/// Detects the plan from a decoded credentials file.
	public static func detect(from credentials: ClaudeCredentials) -> ClaudePlan {
		switch credentials.claudeAiOauth?.subscriptionType?.lowercased() {
		case "max", "max20": return .max20
		case "max5":         return .max5
		case "pro":          return .pro
		default:             return .free
		}
	}

	/// Reads ~/.claude/.credentials.json and returns the detected plan.
	/// Returns `.free` on any read/decode failure.
	public static func detectFromDisk() -> ClaudePlan {
		let path = (NSHomeDirectory() as NSString)
			.appendingPathComponent(".claude/.credentials.json")
		guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
			  let creds = try? JSONDecoder().decode(ClaudeCredentials.self, from: data)
		else { return .free }
		return detect(from: creds)
	}
}
