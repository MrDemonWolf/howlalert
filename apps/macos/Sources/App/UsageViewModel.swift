// UsageViewModel.swift
//
// Observable model the popover binds to. Owns the active UsageSource and
// swaps between Demo and Live when @AppStorage("demoMode") flips.

import Foundation
import Observation
import SwiftUI
import HowlAlertKit

@MainActor
@Observable
final class UsageViewModel {
    private(set) var snapshot: UsageSnapshot
    private(set) var isDemoMode: Bool

    private var activeSource: (any UsageSource)?
    private var previousSnapshot: UsageSnapshot?
    private let notifier = ThresholdNotifier()

    init(demoMode: Bool) {
        self.isDemoMode = demoMode
        // Seed with an empty snapshot — the active source will overwrite on start.
        let now = Date()
        let window = UsageWindow(firstRequestTime: now)
        let projected = PaceProjector().project(window: window, requestsSoFar: 1, planLimit: 200, now: now)
        self.snapshot = UsageSnapshot(
            window: window,
            planLimit: 200,
            requestsSoFar: 0,
            models: [],
            projected: projected,
            now: now
        )
    }

    func start() {
        notifier.requestAuthorization()
        applyMode()
    }

    func setDemoMode(_ on: Bool) {
        guard on != isDemoMode else { return }
        isDemoMode = on
        applyMode()
    }

    private func applyMode() {
        activeSource?.stop()
        activeSource = nil

        let source: any UsageSource = isDemoMode ? DemoUsageSource() : LiveUsageSource()
        source.onChange = { [weak self] new in
            guard let self else { return }
            self.previousSnapshot = self.snapshot
            self.snapshot = new
            self.notifier.observe(snapshot: new, previousSnapshot: self.previousSnapshot)
        }
        activeSource = source
        source.start()
    }

    var iconState: UsageState { snapshot.projected.usageState }
}
