// DashboardView — Stacked cards layout
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Models
import ColorState

struct DashboardView: View {
    let appState: iOSAppState
    private let navy = Color(hex: "#091533")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !appState.isPaired && !appState.isDemoMode {
                        emptyState
                    } else if let pace = appState.paceState, let agg = appState.aggregated {
                        sessionCard(percent: pace.usagePercent)
                        paceCard(pace: pace)

                        if appState.showActiveMacs {
                            activeMacsCard(macs: appState.activeMacs)
                        }

                        lastUpdatedCard(agg: agg)
                    }
                }
                .padding()
            }
            .background(navy.ignoresSafeArea())
            .navigationTitle("HowlAlert")
            .refreshable {
                await appState.loadData()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(appState: appState)
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("🐺")
                .font(.system(size: 80))
            Text("Waiting for Mac...")
                .font(.title2.bold())
            Text("Install HowlAlert on your Mac and start a Claude Code session.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                appState.isDemoMode = true
            } label: {
                Text("Try Demo Mode")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#0FACED"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top)
        }
        .padding(40)
    }

    private func sessionCard(percent: Double) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("SESSION")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                iOSCritBarView(percent: percent, critState: appState.critState)
                HStack {
                    Text("\(Int(percent))%")
                        .font(.title.bold().monospacedDigit())
                    Spacer()
                    if let windowEnd = appState.paceState?.windowEnd {
                        let remaining = windowEnd.timeIntervalSince(.now)
                        let h = Int(remaining / 3600)
                        let m = Int(remaining.truncatingRemainder(dividingBy: 3600) / 60)
                        Text("Resets in \(h)h \(m)m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func paceCard(pace: PaceState) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("PACE")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                HStack {
                    Text(paceLabel(pace))
                        .font(.headline)
                    Spacer()
                    if let runout = pace.displayRunout {
                        Text("Runs out in \(runout)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func activeMacsCard(macs: [AggregatedUsage.MacSummary]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("ACTIVE MACS (\(macs.count))")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                ForEach(macs, id: \.deviceID) { mac in
                    HStack {
                        Text(mac.deviceType.emoji)
                        VStack(alignment: .leading) {
                            Text(mac.deviceName)
                                .font(.subheadline.bold())
                            Text(mac.isActive ? "Last seen \(mac.lastSeen, style: .relative)" : "Idle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(Int(mac.contributionPercent))%")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func lastUpdatedCard(agg: AggregatedUsage) -> some View {
        CardView {
            HStack {
                VStack(alignment: .leading) {
                    Text("LAST UPDATED")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text(agg.latestUpdate, style: .relative)
                        .font(.caption)
                }
                Spacer()
                if !agg.latestDeviceName.isEmpty {
                    Text("from \(agg.latestDeviceName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
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

struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct iOSCritBarView: View {
    let percent: Double
    let critState: CritState
    private var barColor: Color {
        switch critState {
        case .ok: return Color(hex: "#0FACED")
        case .approaching: return Color(hex: "#F5A623")
        case .limitHit: return Color(hex: "#FF3B30")
        case .reset: return Color(hex: "#34C759")
        }
    }
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white.opacity(0.1))
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(width: geo.size.width * min(percent / 100, 1.0))
                    .animation(.easeInOut(duration: 0.5), value: percent)
            }
        }
        .frame(height: 10)
        .accessibilityLabel("Session usage, \(Int(percent)) percent, \(critState.rawValue)")
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
