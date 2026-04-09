import Foundation
import HowlAlertKit

/// Thin wrapper — reads ~/.claude/.credentials.json via HowlAlertKit.
enum CredentialsReader {
	static func readPlan() -> ClaudePlan {
		ClaudePlan.detectFromDisk()
	}
}
