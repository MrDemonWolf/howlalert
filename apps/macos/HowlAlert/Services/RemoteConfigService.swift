import Foundation
import HowlAlertKit

/// Fetches remote config from the Worker and feeds multiplier into PaceCalculator.
@MainActor
final class RemoteConfigService: ObservableObject {
	@Published var currentConfig: RemoteConfig?
	@Published var effectiveMultiplier: Double = 1.0
	@Published var isMultiplierBoosted: Bool = false
	@Published var lastFetchError: String?

	private let configFetcher: ConfigFetcher
	private var refreshTask: Task<Void, Never>?

	init(workerURL: URL = URL(string: "https://howlalert-worker.mrdemonwolf.workers.dev")!) {
		self.configFetcher = ConfigFetcher(workerURL: workerURL)
	}

	/// Start periodic config refresh (every 5 minutes).
	func startRefreshing() {
		refreshTask?.cancel()
		refreshTask = Task {
			while !Task.isCancelled {
				await refresh()
				try? await Task.sleep(for: .seconds(300))
			}
		}
	}

	/// Stop periodic refresh.
	func stopRefreshing() {
		refreshTask?.cancel()
		refreshTask = nil
	}

	/// Fetch latest config and update multiplier.
	func refresh() async {
		let config = await configFetcher.fetch()
		currentConfig = config
		// Compute effective multiplier: use promo if active, else base multiplier
		let now = Date()
		if let promo = config.activePromo, now < promo.endsAt {
			effectiveMultiplier = config.multiplier
		} else {
			effectiveMultiplier = config.activePromo == nil ? config.multiplier : 1.0
		}
		isMultiplierBoosted = effectiveMultiplier > 1.0
		lastFetchError = nil
	}

	/// Get the multiplier badge text for the menu bar.
	var multiplierBadgeText: String? {
		guard isMultiplierBoosted else { return nil }
		if effectiveMultiplier == 2.0 {
			return "2x Active"
		}
		return String(format: "%.1fx Active", effectiveMultiplier)
	}
}
