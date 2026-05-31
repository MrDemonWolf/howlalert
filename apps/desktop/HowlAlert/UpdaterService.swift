import Foundation
import OSLog
import Sparkle

/// Thin wrapper around Sparkle's `SPUStandardUpdaterController` for the desktop
/// app's auto-update flow.
///
/// Sparkle verifies every update against the EdDSA public key in Info.plist
/// (`SUPublicEDKey`) and fetches the appcast from `SUFeedURL`. The appcast is
/// published on the app's GitHub Releases (`releases/latest/download/appcast.xml`).
///
/// Behavior:
/// - **Release**: background checks run on the Info.plist schedule; the appcast
///   feed comes from `SUFeedURL`.
/// - **DEBUG**: the updater is created but not started (`startingUpdater: false`)
///   so background checks never fire while developing; a manual "Check for
///   Updates" still drives the full Sparkle UI against the real feed.
/// - **Homebrew installs**: Sparkle is fully disabled — `brew upgrade` owns
///   updates, so the two never fight.
///
/// `@MainActor` to match `SPUUpdaterDelegate` (`NS_SWIFT_UI_ACTOR`).
@MainActor
final class UpdaterService: NSObject {
    static let shared = UpdaterService()

    private let log = Logger(subsystem: "com.mrdemonwolf.howlalert", category: "Update")
    private var controller: SPUStandardUpdaterController?
    private var updater: SPUUpdater? { controller?.updater }

    /// Sparkle drives a real update check here (not a Homebrew install, and the
    /// controller wired up).
    let isHomebrewInstall: Bool
    var isAvailable: Bool { !isHomebrewInstall && updater != nil }

    private override init() {
        self.isHomebrewInstall = Bundle.main.isHomebrewInstall
        super.init()

        guard !isHomebrewInstall else {
            log.info("Homebrew install detected — Sparkle disabled, brew manages updates")
            return
        }

        #if DEBUG
        let startingUpdater = false
        #else
        let startingUpdater = true
        #endif

        controller = SPUStandardUpdaterController(
            startingUpdater: startingUpdater,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
        log.info("Sparkle initialized (starting: \(startingUpdater, privacy: .public))")
    }

    /// No-op the app can call on launch to force the controller to instantiate
    /// (and, in Release, begin its scheduled checks). Safe on Homebrew installs.
    func bootstrap() { _ = isAvailable }

    /// Manually trigger an update check (shows Sparkle's UI).
    ///
    /// - Returns: `false` when the call is a no-op (Homebrew install or the
    ///   updater never initialized) so the caller can fall back to a web link.
    @discardableResult
    func checkForUpdates() -> Bool {
        guard let updater else {
            log.error("Manual check ignored — updater unavailable (homebrew: \(self.isHomebrewInstall, privacy: .public))")
            return false
        }
        log.info("Manual update check")
        updater.checkForUpdates()
        return true
    }
}

extension UpdaterService: SPUUpdaterDelegate {
    /// Release uses `SUFeedURL` from Info.plist (return nil). DEBUG would point
    /// at a bundled dev-appcast if one existed; none yet, so nil there too.
    nonisolated func feedURLString(for updater: SPUUpdater) -> String? { nil }

    /// Don't prompt for permission to check — onboarding/About handles consent
    /// and `SUEnableAutomaticChecks` in Info.plist provides the default.
    nonisolated func updaterShouldPromptForPermissionToCheck(forUpdates updater: SPUUpdater) -> Bool {
        false
    }

    /// Privacy: send no system-profile telemetry with appcast requests. The feed
    /// is a static file, so profile data would only feed analytics — opt out.
    nonisolated func allowedSystemProfileKeys(for updater: SPUUpdater) -> [String]? { [] }
}
