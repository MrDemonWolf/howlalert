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
            IntegrationSettingsTab()
                .tabItem { Label("Integration", systemImage: "link") }
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

/// Claude Code Stop-hook registration — opt-in, writes ~/.claude/settings.json.
private struct IntegrationSettingsTab: View {
    @State private var enabled = HookInstaller.isEnabled()
    @State private var errorText: String?
    private let binaryPath = HookInstaller.hookBinaryPath()

    var body: some View {
        Form {
            Section {
                Toggle("Instant refresh via Claude Code Stop hook", isOn: $enabled)
                    .disabled(binaryPath == nil)
                    .onChange(of: enabled) { _, on in apply(on) }
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    if let binaryPath {
                        Text("Adds a Stop hook to ~/.claude/settings.json so HowlAlert refreshes the moment a Claude Code turn ends. Toggling off removes exactly that entry; your file is backed up first.")
                        Text(binaryPath).font(.caption.monospaced()).foregroundStyle(.tertiary)
                    } else {
                        Text("The howlalert-hook binary isn't available yet — it ships bundled with the released app. For development, set HOWL_HOOK_PATH to the built binary and reopen Settings.")
                    }
                    if let errorText {
                        Text(errorText).foregroundStyle(.red)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private func apply(_ on: Bool) {
        do {
            try HookInstaller.setEnabled(on)
            errorText = nil
        } catch {
            errorText = error.localizedDescription
            enabled = HookInstaller.isEnabled()   // resync to reality
        }
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
            UpdateControl()
            HStack(spacing: HowlSpacing.s4) {
                Link("Website", destination: URL(string: "https://mrdemonwolf.com")!)
                Link("Docs", destination: URL(string: "https://mrdemonwolf.github.io/howlalert/")!)
            }
            .font(.callout)
            HStack(spacing: HowlSpacing.s3) {
                Link("Privacy", destination: URL(string: "https://mrdemonwolf.github.io/howlalert/docs/legal/privacy")!)
                Text("·").foregroundStyle(.tertiary)
                Link("Terms", destination: URL(string: "https://mrdemonwolf.github.io/howlalert/docs/legal/eula")!)
                Text("·").foregroundStyle(.tertiary)
                Link("Disclaimer", destination: URL(string: "https://mrdemonwolf.github.io/howlalert/docs/legal/disclaimer")!)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            Text("Not affiliated with or endorsed by Anthropic. Claude and Claude Code are trademarks of Anthropic, PBC.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Text("Made with love by MrDemonWolf, Inc.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(HowlSpacing.s5)
    }
}

/// "Check for Updates" in About — a real Sparkle check, unless the app was
/// installed via Homebrew (then `brew upgrade` owns updates and we say so).
private struct UpdateControl: View {
    private let isHomebrew = UpdaterService.shared.isHomebrewInstall

    var body: some View {
        if isHomebrew {
            Text("Updates are managed by Homebrew — run `brew upgrade --cask howlalert`.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        } else {
            Button("Check for Updates…") {
                UpdaterService.shared.checkForUpdates()
            }
            .font(.callout)
        }
    }
}

#Preview("Settings") {
    SettingsView()
}
