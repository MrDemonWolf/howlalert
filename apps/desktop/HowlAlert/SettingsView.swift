import SwiftUI
import ServiceManagement
import HowlAlertUI

/// Native Preferences window (⌘, → the `Settings` scene in `HowlAlertApp`).
///
/// Standard macOS settings chrome on purpose: a `TabView` of grouped `Form`s with
/// system controls — NOT the brand navy/glass surfaces (those are the menu-bar
/// navigation layer only). Brand shows up just as the wolf mark in About.
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem { Label("General", systemImage: "gearshape") }
            NotificationsSettingsTab()
                .tabItem { Label("Notifications", systemImage: "bell") }
            AboutSettingsTab()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 460)
        .scenePadding()
    }
}

/// Launch-at-login, refresh cadence, demo data — all wired to real behavior.
private struct GeneralSettingsTab: View {
    /// Mirrors the actual login-item registration, not a free-floating bool.
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var loginError: String?

    @AppStorage("refreshInterval") private var refreshInterval = 60.0
    @AppStorage("demoMode") private var demoMode = false

    var body: some View {
        Form {
            Section {
                Toggle("Open HowlAlert at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, wantsEnabled in
                        setLoginItem(enabled: wantsEnabled)
                    }
            } footer: {
                if let loginError {
                    Text(loginError).foregroundStyle(.red)
                }
            }

            Section {
                Picker("Check usage every", selection: $refreshInterval) {
                    Text("30 seconds").tag(30.0)
                    Text("1 minute").tag(60.0)
                    Text("2 minutes").tag(120.0)
                    Text("5 minutes").tag(300.0)
                }
                .onChange(of: refreshInterval) { _, _ in
                    UsageModel.shared.armTimer()
                }
            } footer: {
                Text("HowlAlert also refreshes instantly on file changes and when a Claude Code turn ends — this is just the safety-net interval.")
            }

            Section {
                Toggle("Show demo data", isOn: $demoMode)
            } footer: {
                Text("Replaces your live usage with an example for screenshots and demos.")
            }
        }
        .formStyle(.grouped)
    }

    private func setLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginError = nil
        } catch {
            // Re-sync the toggle to the real status if the system rejected it.
            launchAtLogin = SMAppService.mainApp.status == .enabled
            loginError = "Couldn't update the login item: \(error.localizedDescription)"
        }
    }
}

/// Which window-state crossings post a local notification. Both default on; the
/// firing + threshold logic lives in `UsageModel.notifyIfNeeded()`.
private struct NotificationsSettingsTab: View {
    @AppStorage("notifyLow") private var notifyLow = true
    @AppStorage("notifyAlmostOut") private var notifyAlmostOut = true

    var body: some View {
        Form {
            Section {
                Toggle("When usage is running low", isOn: $notifyLow)
                Toggle("When usage is almost out", isOn: $notifyAlmostOut)
            } footer: {
                Text("HowlAlert posts a local notification as your 5-hour window crosses each level — once per crossing, not on every refresh. macOS asks for permission the first time it runs.")
            }
        }
        .formStyle(.grouped)
    }
}

/// Brand mark, version, and links.
private struct AboutSettingsTab: View {
    private var version: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "Version \(short) (\(build))"
    }

    var body: some View {
        VStack(spacing: HowlSpacing.s4) {
            WolfMark(.full, size: 64)
            VStack(spacing: 4) {
                Text("HowlAlert").font(.title2.weight(.semibold))
                Text(version).font(.callout).foregroundStyle(.secondary)
            }
            Text("Watching your Claude Code usage so you don't have to.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: HowlSpacing.s4) {
                Link("Website", destination: URL(string: "https://mrdemonwolf.com")!)
                Link("Docs", destination: URL(string: "https://mrdemonwolf.github.io/howlalert/")!)
            }
            .font(.callout)
            Text("Made with love by MrDemonWolf, Inc.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(HowlSpacing.s5)
    }
}

#Preview("Settings") {
    SettingsView()
}
