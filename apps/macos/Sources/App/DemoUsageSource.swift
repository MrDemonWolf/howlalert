// DemoUsageSource.swift
//
// Synthetic data source for Demo Mode. Cycles through idle → warn → crit
// over a configurable interval so Nathanial (and TestFlight reviewers) can
// see every UI state without touching `claude`.

import Foundation
import HowlAlertKit

@MainActor
final class DemoUsageSource: UsageSource {
    var onChange: ((UsageSnapshot) -> Void)?

    private(set) var snapshot: UsageSnapshot
    private var task: Task<Void, Never>?
    private let stepInterval: TimeInterval

    init(stepInterval: TimeInterval = 20) {
        self.stepInterval = stepInterval
        self.snapshot = Self.makeSnapshot(percentUsed: 0.10, model: "claude-sonnet-4-6")
    }

    func start() {
        stop()
        task = Task { [weak self] in
            guard let self else { return }
            let cycle: [Double] = [0.10, 0.40, 0.78, 0.85, 0.92, 0.96, 1.0, 0.0]
            var i = 0
            while !Task.isCancelled {
                let percent = cycle[i % cycle.count]
                self.snapshot = Self.makeSnapshot(percentUsed: percent, model: "claude-sonnet-4-6")
                self.onChange?(self.snapshot)
                i += 1
                try? await Task.sleep(for: .seconds(stepInterval))
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    private static func makeSnapshot(percentUsed: Double, model: String) -> UsageSnapshot {
        let now = Date()
        // Pin demo window to "started 1h ago" so the countdown renders ~4h.
        let firstRequest = now.addingTimeInterval(-3600)
        let window = UsageWindow(firstRequestTime: firstRequest)
        let planLimit = 200
        let requestsSoFar = Int(Double(planLimit) * percentUsed)
        let projector = PaceProjector()
        let reading = projector.project(
            window: window,
            requestsSoFar: max(1, requestsSoFar),
            planLimit: planLimit,
            now: now
        )
        return UsageSnapshot(
            window: window,
            planLimit: planLimit,
            requestsSoFar: requestsSoFar,
            models: [
                .init(id: model, name: model, sessions: max(1, requestsSoFar / 8), percentOfWindow: percentUsed * 0.78),
                .init(id: "claude-opus-4-7", name: "claude-opus-4-7", sessions: max(1, requestsSoFar / 12), percentOfWindow: percentUsed * 0.22),
            ],
            projected: reading,
            now: now
        )
    }
}
