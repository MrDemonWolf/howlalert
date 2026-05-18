// LiveUsageSource.swift
//
// Production usage source — JSONLWatcher feeds UsageStore, snapshots are
// recomputed and pushed to subscribers whenever new events arrive.

import Foundation
import HowlAlertKit

@MainActor
final class LiveUsageSource: UsageSource {
    var onChange: ((UsageSnapshot) -> Void)?

    private let watcher: JSONLWatcher
    private let store = UsageStore()
    private let projector = PaceProjector()
    private(set) var snapshot: UsageSnapshot

    /// Until we have enough completed windows, fall back to a conservative
    /// limit that mirrors the May-2026 Sonnet plan. P90 takes over once we
    /// have at least `PlanLimitEstimator.minSamples` windows on file.
    private var fallbackPlanLimit: Int = 200
    private let estimator = PlanLimitEstimator()

    init(watcher: JSONLWatcher = JSONLWatcher()) {
        self.watcher = watcher
        self.snapshot = Self.empty()
    }

    func start() {
        watcher.start { [weak self] events in
            guard let self else { return }
            for event in events {
                self.store.ingest(event)
            }
            self.refresh()
        }
        refresh()
    }

    func stop() {
        watcher.stop()
    }

    private func refresh() {
        let now = Date()
        guard let window = store.window else {
            snapshot = Self.empty()
            onChange?(snapshot)
            return
        }
        let limit = fallbackPlanLimit
        let projected = projector.project(
            window: window,
            requestsSoFar: max(1, store.totalRequests),
            planLimit: limit,
            now: now
        )
        snapshot = UsageSnapshot(
            window: window,
            planLimit: limit,
            requestsSoFar: store.totalRequests,
            models: store.models(),
            projected: projected,
            now: now
        )
        onChange?(snapshot)
    }

    private static func empty() -> UsageSnapshot {
        let now = Date()
        let window = UsageWindow(firstRequestTime: now)
        let projected = PaceProjector().project(
            window: window,
            requestsSoFar: 1,
            planLimit: 200,
            now: now
        )
        return UsageSnapshot(
            window: window,
            planLimit: 200,
            requestsSoFar: 0,
            models: [],
            projected: projected,
            now: now
        )
    }
}
