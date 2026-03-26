import Foundation
import WatchConnectivity

/// Receives usage data from the iOS companion app via WatchConnectivity
final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
	static let shared = WatchSessionManager()

	@Published var usagePercent: Double = 0
	@Published var paceStatus: String = "onTrack"
	@Published var pacePercent: Double = 0
	@Published var model: String = ""
	@Published var multiplier: Double = 1.0
	@Published var isConnected = false

	private override init() {
		super.init()
	}

	func activate() {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		session.delegate = self
		session.activate()
	}

	// MARK: - WCSessionDelegate

	func session(
		_ session: WCSession,
		activationDidCompleteWith activationState: WCSessionActivationState,
		error: Error?
	) {
		DispatchQueue.main.async {
			self.isConnected = activationState == .activated
		}
	}

	func session(
		_ session: WCSession,
		didReceiveApplicationContext applicationContext: [String: Any]
	) {
		DispatchQueue.main.async {
			self.updateFromContext(applicationContext)
		}
	}

	func session(
		_ session: WCSession,
		didReceiveUserInfo userInfo: [String: Any]
	) {
		DispatchQueue.main.async {
			self.updateFromContext(userInfo)
		}
	}

	private func updateFromContext(_ context: [String: Any]) {
		if let percent = context["usagePercent"] as? Double {
			usagePercent = percent
		}
		if let status = context["paceStatus"] as? String {
			paceStatus = status
		}
		if let percent = context["pacePercent"] as? Double {
			pacePercent = percent
		}
		if let m = context["model"] as? String {
			model = m
		}
		if let mult = context["multiplier"] as? Double {
			multiplier = mult
		}
	}
}
