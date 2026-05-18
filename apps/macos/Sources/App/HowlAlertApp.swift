// HowlAlertApp.swift
//
// @main App. Hosts a MenuBarExtra (window-style) and a Settings scene.
// LSUIElement=true keeps the Dock icon hidden — the menu bar is the surface.

import SwiftUI
import HowlAlertKit

@main
struct HowlAlertApp: App {
    @State private var model: UsageViewModel = {
        let demo = UserDefaults.standard.bool(forKey: "demoMode")
        let m = UsageViewModel(demoMode: demo)
        m.start()
        return m
    }()

    var body: some Scene {
        MenuBarExtra {
            HowlAlertPopover(model: model)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(model: model)
        }
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        // Icon Composer-exported PNGs land in Assets.xcassets as template
        // images named MenuBarIcon-{Idle,Warn,Crit}. Until those land, we
        // fall back to the WolfMark vector so the build never breaks.
        let name: String = {
            switch model.iconState {
            case .fresh, .ok: return "MenuBarIcon-Idle"
            case .warn:       return "MenuBarIcon-Warn"
            case .crit:       return "MenuBarIcon-Crit"
            }
        }()
        Image(name)
            .renderingMode(.template)
            .accessibilityLabel("HowlAlert: \(model.iconState.rawValue)")
    }
}
