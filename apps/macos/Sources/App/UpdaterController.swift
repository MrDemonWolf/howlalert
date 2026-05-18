// UpdaterController.swift
//
// Thin wrapper around Sparkle's SPUStandardUpdaterController. Lives at app
// scope so SettingsView can bind the "Check for Updates…" button to it.
// EdDSA public key and feed URL are configured in Info.plist (SUFeedURL +
// SUPublicEDKey) — the workflow in Slice 10 substitutes the real public key
// during release builds.

import Foundation
import Sparkle

@MainActor
final class UpdaterController {
    static let shared = UpdaterController()

    let controller: SPUStandardUpdaterController

    private init() {
        self.controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
