// MenuBarPopoverView — Click popover from menu bar icon
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Models
import ColorState
import Config

struct MenuBarPopoverView: View {
    let appState: AppState
    private let navy = Color(hex: "#091533")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("🐺 HowlAlert")
                    .font(.headline)
                Spacer()
                if appState.isDemoMode {
                    Text("DEMO")
                        .font(.caption2.bold())
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            if !appState.isEntitled && !appState.isDemoMode {
                // Paywall state
                lockedView
            } else if let pace = appState.paceState, let snapshot = appState.latestSnapshot {
                // Entitled / demo — show stats
                usageCard(title: "SESSION", percent: pace.usagePercent, snapshot: snapshot)
                paceCard(pace: pace)
                lastUpdatedView(snapshot: snapshot)
            } else {
                Text("Waiting for Claude Code...")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            Divider()

            // Bottom actions
            HStack {
                Button {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } label: {
                    Image(systemName: "gear")
                }
                .buttonStyle(.borderless)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .keyboardShortcut("q")
            }
        }
        .padding()
        .frame(width: 280)
        .background(navy)
        .foregroundStyle(.white)
    }

    private var lockedView: some View {
        VStack(spacing: 8) {
            Text("HowlAlert Pro required")
                .font(.subheadline.bold())
            Text("Subscribe on your iPhone to unlock")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let snapshot = appState.latestSnapshot {
                // Read-only teaser
                Divider()
                HStack {
                    Text("Raw tokens:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(snapshot.totalBillableTokens.formatted())")
                        .font(.caption.monospacedDigit())
                }
            }
        }
    }

    private func usageCard(title: String, percent: Double, snapshot: UsageSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            CritBarView(percent: percent, critState: appState.critState)
            HStack {
                Text("\(Int(percent))%")
                    .font(.title2.bold().monospacedDigit())
                Spacer()
                if let windowEnd = appState.paceState?.windowEnd {
                    let remaining = windowEnd.timeIntervalSince(.now)
                    let hours = Int(remaining / 3600)
                    let minutes = Int(remaining.truncatingRemainder(dividingBy: 3600) / 60)
                    Text("Resets in \(hours)h \(minutes)m")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func paceCard(pace: PaceState) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PACE")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            HStack {
                Text(paceLabel(pace))
                    .font(.subheadline.bold())
                Spacer()
                if let runout = pace.displayRunout {
                    Text("Runs out in \(runout)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func lastUpdatedView(snapshot: UsageSnapshot) -> some View {
        HStack {
            Text("Last updated")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(snapshot.updatedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func paceLabel(_ pace: PaceState) -> String {
        switch pace.status {
        case .onTrack: return "On track"
        case .inDebt: return "\(Int(pace.debtPercent))% in debt"
        case .inReserve: return "\(Int(abs(pace.debtPercent)))% in reserve"
        case .limitHit: return "Limit hit"
        case .freshReset: return "Fresh reset"
        }
    }
}
