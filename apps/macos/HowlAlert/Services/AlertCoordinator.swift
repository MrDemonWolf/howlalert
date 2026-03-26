import Foundation
import HowlAlertKit
import Combine

/// Coordinates all services: watcher -> aggregator -> pace -> push.
///
/// Subscribes to ``SessionFileWatcher`` snapshot changes, recalculates pace
/// and usage percentage, updates the ``CritBarState``, and fires push
/// notifications through ``PushService`` when thresholds are crossed.
@MainActor
final class AlertCoordinator: ObservableObject {

	// MARK: - Published state

	@Published var usagePercent: Double = 0
	@Published var paceState: PaceState?
	@Published var critBarState: CritBarState = .ok
	@Published var isWatching = false
	@Published var isPaired = false

	// MARK: - Child services

	let watcher = SessionFileWatcher()
	let configService = RemoteConfigService()
	let pushService = PushService()
	let pairingReader = PairingReader()

	// MARK: - Configuration

	/// Base token limit for the current plan (before multiplier).
	var baseLimit: Int = 100_000

	/// Current billing window boundaries.
	var windowStart: Date = Calendar.current.startOfDay(for: Date())
	var windowEnd: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)

	// MARK: - Private

	private var cancellables = Set<AnyCancellable>()

	// MARK: - Public API

	/// Start all services and begin monitoring.
	func start() async {
		// Fetch pairing info from CloudKit / Keychain
		await pairingReader.fetchPairedDevices()
		isPaired = pairingReader.isPaired

		// Start periodic remote config refresh
		configService.startRefreshing()

		// Start file system watcher
		watcher.startWatching()
		isWatching = watcher.isWatching

		// Wire up reactive bindings
		setupBindings()
	}

	/// Stop all services.
	func stop() {
		cancellables.removeAll()
		watcher.stopWatching()
		configService.stopRefreshing()
		isWatching = false
	}

	// MARK: - Private

	/// Subscribe to watcher changes, recalculate pace, check thresholds.
	private func setupBindings() {
		// React to new snapshots from the file watcher
		watcher.$currentSnapshot
			.compactMap { $0 }
			.receive(on: RunLoop.main)
			.sink { [weak self] snapshot in
				guard let self else { return }
				Task { @MainActor in
					await self.handleNewSnapshot(snapshot)
				}
			}
			.store(in: &cancellables)

		// Mirror watcher state
		watcher.$isWatching
			.receive(on: RunLoop.main)
			.assign(to: \.isWatching, on: self)
			.store(in: &cancellables)

		// Mirror pairing state
		pairingReader.$pairedDevices
			.receive(on: RunLoop.main)
			.map { !$0.isEmpty }
			.assign(to: \.isPaired, on: self)
			.store(in: &cancellables)

		// Reset push thresholds when a new window starts (multiplier changes
		// are a good proxy for window resets from RemoteConfigService).
		configService.$effectiveMultiplier
			.removeDuplicates()
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.pushService.resetThresholds()
			}
			.store(in: &cancellables)
	}

	/// Process a new usage snapshot: calculate pace, update UI state, push if needed.
	private func handleNewSnapshot(_ snapshot: UsageSnapshot) async {
		let multiplier = configService.effectiveMultiplier
		let effectiveLimit = Double(baseLimit) * multiplier

		// Calculate usage percentage
		let percent = effectiveLimit > 0
			? (Double(snapshot.totalTokens) / effectiveLimit) * 100.0
			: 0

		usagePercent = min(percent, 999) // cap for display sanity

		// Calculate pace
		let pace = calculatePace(
			consumed: snapshot.totalTokens,
			limit: baseLimit,
			windowStart: windowStart,
			windowEnd: windowEnd,
			now: Date(),
			multiplier: multiplier
		)
		paceState = pace

		// Update crit-bar state
		critBarState = ThresholdColor.state(for: usagePercent)

		// Send push if paired and threshold crossed
		guard isPaired,
			  let pairing = pairingReader.getStoredPairing()
		else { return }

		await pushService.checkAndPush(
			usagePercent: usagePercent,
			snapshot: snapshot,
			paceState: pace,
			pairingSecret: pairing.secret,
			deviceToken: pairing.deviceToken,
			multiplier: multiplier,
			limit: baseLimit,
			windowStart: windowStart,
			windowEnd: windowEnd
		)
	}
}
