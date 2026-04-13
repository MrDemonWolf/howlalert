// PreferencesView — macOS Settings window
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import ServiceManagement
import Config

struct PreferencesView: View {
    let appState: AppState
    @State private var launchAtLogin = false
    @State private var pushEnabled = true
    @State private var doneAlertsEnabled = true

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
                Toggle("Enable push notifications", isOn: $pushEnabled)
                Toggle("Enable \"Claude is done\" alerts", isOn: $doneAlertsEnabled)
            }

            Section("Providers") {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Claude Code")
                    Spacer()
                    Text("Active")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                    Text("Gemini CLI")
                    Spacer()
                    Text("Coming in v2.0")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Subscription") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(appState.isEntitled ? "Pro · via iPhone" : "Not subscribed")
                        .foregroundStyle(appState.isEntitled ? .green : .secondary)
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("© 2026 MrDemonWolf, Inc.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 400)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
