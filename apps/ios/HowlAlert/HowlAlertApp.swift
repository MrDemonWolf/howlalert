// HowlAlert iOS — App Entry Point
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Models
import Config
import TokenMath
import ColorState

@main
struct HowlAlertApp: App {
    @State private var appState = iOSAppState()

    var body: some Scene {
        WindowGroup {
            DashboardView(appState: appState)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    if url.scheme == "howlalert", url.host == "demo" {
                        appState.isDemoMode = true
                    }
                }
        }
    }
}

@Observable
final class iOSAppState {
    var snapshots: [UsageSnapshot] = []
    var aggregated: AggregatedUsage?
    var paceState: PaceState?
    var critState: CritState = .ok
    var isEntitled = false
    var isDemoMode = false
    var isPaired = false

    private let calculator = PaceCalculator()
    private let thresholdColor = ThresholdColor()
    private let aggregator = SnapshotAggregator()
    private let syncManager = CloudKitSyncManager()
    private let limit = 100_000

    init() {
        Task { await loadData() }
    }

    func loadData() async {
        // Check entitlement
        let ckState = try? await syncManager.fetchEntitlement()
        let mgr = EntitlementManager()
        isEntitled = mgr.isEntitled(cloudKitState: ckState)

        // Fetch all Mac snapshots
        if let fetched = try? await syncManager.fetchAllUsageSnapshots() {
            await MainActor.run {
                snapshots = fetched
                isPaired = !fetched.isEmpty
                recalculate()
            }
        }
    }

    @MainActor
    func recalculate() {
        let agg = aggregator.aggregate(snapshots)
        aggregated = agg

        guard agg.totalBillableTokens > 0, let firstSnap = snapshots.first else { return }

        let pace = calculator.calculate(
            totalTokens: agg.totalBillableTokens,
            limit: limit,
            windowStart: firstSnap.windowStart,
            windowEnd: firstSnap.windowEnd
        )
        paceState = pace
        critState = thresholdColor.state(
            for: pace.usagePercent,
            isReset: pace.status == .freshReset
        )
    }

    var activeMacs: [AggregatedUsage.MacSummary] {
        aggregated?.activeMacs ?? []
    }

    var showActiveMacs: Bool {
        activeMacs.count > 1
    }
}
