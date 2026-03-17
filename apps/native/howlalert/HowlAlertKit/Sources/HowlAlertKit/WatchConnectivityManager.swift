import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity

public final class WatchConnectivityManager: NSObject, WCSessionDelegate {
	public static let shared = WatchConnectivityManager()

	// Keys for the shared App Group UserDefaults
	public static let tokensUsedKey = "howlalert.tokensUsed"
	public static let tokenLimitKey = "howlalert.tokenLimit"
	public static let sessionCountKey = "howlalert.sessionCount"
	public static let sessionLimitKey = "howlalert.sessionLimit"

	private let appGroupID = "group.com.mrdemonwolf.howlalert"

	private override init() {
		super.init()
	}

	// MARK: - Activation

	public func activate() {
		guard WCSession.isSupported() else { return }
		WCSession.default.delegate = self
		WCSession.default.activate()
	}

	// MARK: - Send (iPhone → Watch)

	/// Call from iPhone side when stats update — sends to watch via applicationContext.
	public func sendStats(
		tokensUsed: Int,
		tokenLimit: Int,
		sessionCount: Int,
		sessionLimit: Int
	) {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		guard session.activationState == .activated else { return }

		#if os(iOS)
		guard session.isPaired && session.isWatchAppInstalled else { return }
		#endif

		let context: [String: Any] = [
			WatchConnectivityManager.tokensUsedKey: tokensUsed,
			WatchConnectivityManager.tokenLimitKey: tokenLimit,
			WatchConnectivityManager.sessionCountKey: sessionCount,
			WatchConnectivityManager.sessionLimitKey: sessionLimit,
		]

		do {
			try session.updateApplicationContext(context)
		} catch {
			// Non-fatal — watch will use last known values
		}
	}

	// MARK: - WCSessionDelegate (shared)

	public func session(
		_ session: WCSession,
		activationDidCompleteWith activationState: WCSessionActivationState,
		error: Error?
	) {
		// Activation complete — no action needed
	}

	/// On watch side: receive stats from iPhone and persist to App Group UserDefaults.
	public func session(
		_ session: WCSession,
		didReceiveApplicationContext applicationContext: [String: Any]
	) {
		let defaults = UserDefaults(suiteName: appGroupID) ?? .standard

		if let tokensUsed = applicationContext[WatchConnectivityManager.tokensUsedKey] as? Int {
			defaults.set(tokensUsed, forKey: WatchConnectivityManager.tokensUsedKey)
		}
		if let tokenLimit = applicationContext[WatchConnectivityManager.tokenLimitKey] as? Int {
			defaults.set(tokenLimit, forKey: WatchConnectivityManager.tokenLimitKey)
		}
		if let sessionCount = applicationContext[WatchConnectivityManager.sessionCountKey] as? Int {
			defaults.set(sessionCount, forKey: WatchConnectivityManager.sessionCountKey)
		}
		if let sessionLimit = applicationContext[WatchConnectivityManager.sessionLimitKey] as? Int {
			defaults.set(sessionLimit, forKey: WatchConnectivityManager.sessionLimitKey)
		}

		#if os(watchOS)
		// Reload WidgetKit timelines so the complication reflects the new data
		WidgetCenter.shared.reloadTimelines(ofKind: "com.mrdemonwolf.howlalert.complication")
		#endif
	}

	// MARK: - iOS-only delegate methods

	#if os(iOS)
	public func sessionDidBecomeInactive(_ session: WCSession) {}
	public func sessionDidDeactivate(_ session: WCSession) {
		// Re-activate on the new Apple Watch if the user switched watches
		WCSession.default.activate()
	}
	#endif
}
#endif
