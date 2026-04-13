// HowlAlert watchOS — App Entry Point
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import WatchConnectivity
import Models
import ColorState

@main
struct HowlAlertWatchApp: App {
    @State private var watchState = WatchAppState()

    var body: some Scene {
        WindowGroup {
            WatchDashboardView(state: watchState)
        }
    }
}

@Observable
final class WatchAppState: NSObject, WCSessionDelegate {
    var usagePercent: Double = 0
    var critState: CritState = .ok
    var paceLabel: String = "Waiting..."
    var runoutText: String?
    var isDemoMode = false

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            if let percent = userInfo["usagePercent"] as? Double {
                usagePercent = percent
            }
            if let crit = userInfo["critState"] as? String {
                critState = CritState(rawValue: crit) ?? .ok
            }
            if let pace = userInfo["paceLabel"] as? String {
                paceLabel = pace
            }
            runoutText = userInfo["runoutText"] as? String

            if let kind = userInfo["pushKind"] as? String, kind == "done" {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
}

struct WatchDashboardView: View {
    let state: WatchAppState

    private var barColor: Color {
        switch state.critState {
        case .ok: return Color(hex: "#0FACED")
        case .approaching: return Color(hex: "#F5A623")
        case .limitHit: return Color(hex: "#FF3B30")
        case .reset: return Color(hex: "#34C759")
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("🐺")
                .font(.title2)

            // Circular progress
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(state.usagePercent / 100, 1.0))
                    .stroke(barColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: state.usagePercent)

                Text("\(Int(state.usagePercent))%")
                    .font(.title3.bold().monospacedDigit())
            }
            .frame(width: 80, height: 80)

            Text(state.paceLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let runout = state.runoutText {
                Text("~\(runout)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(for: .navigation) {
            Color(hex: "#091533")
        }
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
