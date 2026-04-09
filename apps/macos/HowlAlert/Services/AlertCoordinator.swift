import Foundation
import HowlAlertKit
import Combine

/// Coordinates all services: watcher -> aggregator -> pace -> push.
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
	let pushService = PushService()
	let pairingReader = PairingReader()

	// MARK: - Configuration

	/// Base token limit derived from the detected plan.
	var baseLimit: Int { ClaudePlan.detectFromDisk().sessionTokenLimit }

	// MARK: - Private

	private var cancellables = Set<AnyCancellable>()

	// MARK: - Public API

	/// Start all services and begin monitoring.
	func start() async {
		await pairingReader.fetchPairedDevices()
		isPaired = pairingReader.isPaired

		watcher.startWatching()
		isWatching = watcher.isWatching

		setupBindings()
	}

	/// Stop all services.
	func stop() {
		cancellables.removeAll()
		watcher.stopWatching()
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
	}

	/// Process a new usage snapshot: calculate pace, update UI state, push if needed.
	private func handleNewSnapshot(_ snapshot: UsageSnapshot) async {
		let limit = baseLimit
		let windowDuration: TimeInterval = 5 * 3600

		let percent = limit > 0
			? (Double(snapshot.sessionTokens) / Double(limit)) * 100.0
			: 0
		usagePercent = min(percent, 999)

		let pace = PaceCalculator.calculate(
			tokensUsed: snapshot.sessionTokens,
			effectiveLimit: limit,
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
			pairingSecret: pairing.pairingSecret,
			deviceToken: pairing.deviceToken,
			multiplier: 1.0,
			limit: limit,
			windowStart: snapshot.sessionWindowStart,
			windowEnd: windowEnd
		)
	}
}
