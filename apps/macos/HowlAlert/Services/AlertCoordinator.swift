import Foundation
import HowlAlertKit
import Combine

/// Coordinates all services: watcher -> aggregator -> pace -> push.
///
/// Subscribes to ``SessionFileWatcher`` snapshot changes, recalculates pace
/// and usage percentage, and fires push notifications through ``PushService``
/// when thresholds are crossed.
@MainActor
final class AlertCoordinator: ObservableObject {

	// MARK: - Published state

	@Published var usagePercent: Double = 0
	@Published var paceState: PaceState?
	@Published var critBarColor: CritBarColor = .normal
	@Published var isWatching = false
	@Published var isPaired = false

	// MARK: - Child services

	let watcher = SessionFileWatcher()
	let configService = RemoteConfigService()
	let pushService = PushService()
	let pairingReader = PairingReader()

	// MARK: - Configuration

	/// Selected plan identifier (matches RemoteConfig.PlanLimits keys).
	@Published var selectedPlan: String = UserDefaults.standard.string(forKey: "selectedPlan") ?? "pro"

	/// Billing window boundaries (5-hour session window).
	var windowStart: Date = Date()
	var windowEnd: Date = Date().addingTimeInterval(5 * 3600)

	// MARK: - Private

	private var cancellables = Set<AnyCancellable>()

	// MARK: - Public API

	/// Start all services and begin monitoring.
	func start() async {
		await pairingReader.fetchPairedDevices()
		isPaired = pairingReader.isPaired

		configService.startRefreshing()
		watcher.startWatching()
		isWatching = watcher.isWatching

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

	private func setupBindings() {
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

		watcher.$isWatching
			.receive(on: RunLoop.main)
			.assign(to: \.isWatching, on: self)
			.store(in: &cancellables)

		pairingReader.$pairedDevices
			.receive(on: RunLoop.main)
			.map { !$0.isEmpty }
			.assign(to: \.isPaired, on: self)
			.store(in: &cancellables)

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
		let config = configService.currentConfig ?? .default
		let plan = selectedPlan

		let baseLimit: Int
		switch plan {
		case "free":  baseLimit = config.planLimits.free
		case "max5":  baseLimit = config.planLimits.max5
		case "max20": baseLimit = config.planLimits.max20
		default:      baseLimit = config.planLimits.pro
		}

		let effectiveLimit = LimitMultiplier.effectiveLimit(
			basePlanLimit: baseLimit,
			config: config,
			at: Date()
		)
		let multiplier = configService.effectiveMultiplier

		let percent = effectiveLimit > 0
			? (Double(snapshot.sessionTokens) / Double(effectiveLimit)) * 100.0
			: 0
		usagePercent = min(percent, 999)

		let windowDuration: TimeInterval = 5 * 3600
		let pace = PaceCalculator.calculate(
			tokensUsed: snapshot.sessionTokens,
			effectiveLimit: effectiveLimit,
			windowStart: snapshot.sessionWindowStart,
			windowDuration: windowDuration,
			now: Date()
		)
		paceState = pace

		critBarColor = ThresholdColor.color(for: usagePercent / 100.0)

		guard isPaired,
			  let pairing = pairingReader.getStoredPairing(),
			  let pace
		else { return }

		let windowEnd = snapshot.sessionWindowStart.addingTimeInterval(windowDuration)

		await pushService.checkAndPush(
			usagePercent: usagePercent,
			snapshot: snapshot,
			paceState: pace,
			pairingSecret: pairing.secret,
			deviceToken: pairing.deviceToken,
			multiplier: multiplier,
			limit: baseLimit,
			windowStart: snapshot.sessionWindowStart,
			windowEnd: windowEnd
		)
	}
}
