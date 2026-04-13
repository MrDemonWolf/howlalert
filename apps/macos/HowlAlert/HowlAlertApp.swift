// HowlAlert macOS — Menu Bar App
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Models
import Config
import TokenMath
import ColorState
import PaceEngine
import Providers
import DemoMode

@main
struct HowlAlertApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopoverView(appState: appState)
        } label: {
            Image(systemName: "pawprint.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(appState.menuBarColor)
        }
        .menuBarExtraStyle(.window)

        Settings {
            PreferencesView(appState: appState)
        }
    }
}

@Observable
final class AppState {
    var latestSnapshot: UsageSnapshot?
    var paceState: PaceState?
    var critState: CritState = .ok
    var isEntitled = false
    var isDemoMode = false

    private let calculator = PaceCalculator()
    private let thresholdColor = ThresholdColor()
    private let limit = 100_000 // TODO: Make configurable per plan

    #if os(macOS)
    private var watcher: JSONLWatcher?
    private let syncManager = CloudKitSyncManager()
    private let throttler = SnapshotThrottler()
    private let entitlementManager = EntitlementManager()
    private let deviceID = DeviceIdentifier()
    #endif

    var menuBarColor: Color {
        if !isEntitled && !isDemoMode {
            return .gray
        }
        let hex = thresholdColor.color(for: critState)
        return Color(hex: hex.hex)
    }

    init() {
        #if os(macOS)
        Task { await checkEntitlement() }
        startWatching()
        #endif
    }

    #if os(macOS)
    func startWatching() {
        let providers: [any UsageProvider] = [ClaudeCodeProvider()]
        watcher = JSONLWatcher(providers: providers) { [weak self] snapshot in
            Task { @MainActor in
                self?.handleSnapshot(snapshot)
            }
        }
        watcher?.scanExisting()
        watcher?.start()
    }

    func checkEntitlement() async {
        let cloudKitState = try? await syncManager.fetchEntitlement()
        isEntitled = entitlementManager.isEntitled(cloudKitState: cloudKitState)
    }
    #endif

    @MainActor
    func handleSnapshot(_ raw: UsageSnapshot) {
        #if os(macOS)
        // Stamp with this Mac's identity
        let snapshot = UsageSnapshot(
            sourceDeviceID: deviceID.id,
            sourceDeviceName: deviceID.name,
            sourceDeviceType: deviceID.type,
            model: raw.model,
            outputTokens: raw.outputTokens,
            cacheReadInputTokens: raw.cacheReadInputTokens,
            cacheCreationInputTokens: raw.cacheCreationInputTokens,
            windowStart: raw.windowStart,
            windowEnd: raw.windowEnd,
            updatedAt: raw.updatedAt
        )

        latestSnapshot = snapshot
        updatePace(from: snapshot)

        // Throttled CloudKit write
        Task {
            try? await throttler.throttledWrite(snapshot, using: syncManager)
        }
        #endif
    }

    @MainActor
    func updatePace(from snapshot: UsageSnapshot) {
        let pace = calculator.calculate(
            totalTokens: snapshot.totalBillableTokens,
            limit: limit,
            windowStart: snapshot.windowStart,
            windowEnd: snapshot.windowEnd
        )
        paceState = pace
        critState = thresholdColor.state(
            for: pace.usagePercent,
            isReset: pace.status == .freshReset
        )
    }

    func toggleDemoMode() {
        isDemoMode.toggle()
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
