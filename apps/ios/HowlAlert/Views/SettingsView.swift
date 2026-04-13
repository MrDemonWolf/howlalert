// SettingsView — iOS app settings
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import Config

struct SettingsView: View {
    let appState: iOSAppState

    var body: some View {
        List {
            Section("Subscription") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(appState.isEntitled ? "Pro" : "Not subscribed")
                        .foregroundStyle(appState.isEntitled ? .green : .secondary)
                }
                if !appState.isEntitled {
                    NavigationLink("Upgrade to Pro") {
                        // PaywallView placeholder — Phase 11
                        Text("Paywall coming in Phase 11")
                    }
                }
            }

            Section("Devices") {
                if appState.activeMacs.isEmpty {
                    Text("No Macs paired")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(appState.activeMacs, id: \.deviceID) { mac in
                        HStack {
                            Text(mac.deviceType.emoji)
                            Text(mac.deviceName)
                            Spacer()
                            Text(mac.isActive ? "Active" : "Idle")
                                .font(.caption)
                                .foregroundStyle(mac.isActive ? .green : .secondary)
                        }
                    }
                }
            }

            Section("Developer") {
                Toggle("Demo Mode", isOn: Binding(
                    get: { appState.isDemoMode },
                    set: { appState.isDemoMode = $0 }
                ))
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }
                Link("Privacy Policy", destination: HowlAlertConstants.privacyURL)
                Link("Terms of Service", destination: HowlAlertConstants.termsURL)
                Link("Support", destination: URL(string: "mailto:\(HowlAlertConstants.supportEmail)")!)
            }
        }
        .navigationTitle("Settings")
    }
}
