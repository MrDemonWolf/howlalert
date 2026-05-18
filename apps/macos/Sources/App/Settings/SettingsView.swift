// SettingsView.swift
//
// Tabbed Settings scene. General tab hosts the Demo Mode toggle and a stub
// "Check for Updates…" entry that Sparkle (Slice 9) will wire up.

import SwiftUI
import HowlAlertKit

struct SettingsView: View {
    @Bindable var model: UsageViewModel

    var body: some View {
        TabView {
            GeneralTab(model: model)
                .tabItem { Label("General", systemImage: "gearshape") }
            AboutTab()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 460, height: 280)
    }
}

private struct GeneralTab: View {
    @Bindable var model: UsageViewModel
    @AppStorage("demoMode") private var demoMode: Bool = false

    var body: some View {
        Form {
            Section {
                Toggle("Demo Mode", isOn: $demoMode)
                Text("Cycles the icon through idle → warn → crit and fires test notifications. Useful for demoing without touching `claude`.")
                    .font(.howlCaption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Behavior")
            }

            Section {
                Button("Check for Updates…") {
                    UpdaterController.shared.checkForUpdates()
                }
            } header: {
                Text("Updates")
            }
        }
        .formStyle(.grouped)
        .onChange(of: demoMode) { _, new in
            model.setDemoMode(new)
        }
    }
}

private struct AboutTab: View {
    var body: some View {
        VStack(spacing: HowlSpacing.s3) {
            WolfMark(tint: .howlCyan500, size: 64)
            Text("HowlAlert").font(.howlTitle1)
            Text("Watches your Claude Code usage so you don't get caught out.")
                .font(.howlBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("© 2026 MrDemonWolf, Inc.")
                .font(.howlCaption)
                .foregroundStyle(.tertiary)
        }
        .padding(HowlSpacing.s4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
