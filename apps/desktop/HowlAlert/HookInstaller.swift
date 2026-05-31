import Foundation
import HowlAlertCore

/// Registers/unregisters HowlAlert's Stop hook in Claude Code's `settings.json`.
///
/// The merge logic is the pure, tested `ClaudeSettingsHook` in HowlAlertCore;
/// this layer is just file I/O — and it's careful with the user's real config:
/// it backs the file up once before the first edit, writes atomically, and
/// refuses to touch a file it can't parse (so a malformed settings.json is never
/// clobbered). Opt-in only — called from the Integration settings toggle.
enum HookInstaller {
    enum HookError: LocalizedError {
        case binaryNotFound
        case unreadableSettings

        var errorDescription: String? {
            switch self {
            case .binaryNotFound:
                "The howlalert-hook binary isn't available. It ships with the released app; for development set HOWL_HOOK_PATH."
            case .unreadableSettings:
                "~/.claude/settings.json isn't valid JSON — HowlAlert left it untouched. Fix it, then try again."
            }
        }
    }

    /// Absolute path to the hook binary, or `nil` if it can't be located.
    /// Resolution order: `HOWL_HOOK_PATH` (dev) → bundled auxiliary executable.
    static func hookBinaryPath() -> String? {
        if let override = ProcessInfo.processInfo.environment["HOWL_HOOK_PATH"], !override.isEmpty {
            return FileManager.default.isExecutableFile(atPath: override) ? override : nil
        }
        if let bundled = Bundle.main.url(forAuxiliaryExecutable: "howlalert-hook") {
            return bundled.path
        }
        return nil
    }

    /// `~/.claude/settings.json`, honoring `CLAUDE_CONFIG_DIR`.
    static func settingsURL() -> URL {
        let env = ProcessInfo.processInfo.environment
        let base: URL
        if let dir = env["CLAUDE_CONFIG_DIR"], !dir.isEmpty {
            base = URL(fileURLWithPath: dir, isDirectory: true)
        } else {
            base = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude", isDirectory: true)
        }
        return base.appendingPathComponent("settings.json")
    }

    /// Whether our hook is currently registered. `false` if the binary can't be
    /// found or the file can't be read/parsed.
    static func isEnabled() -> Bool {
        guard let cmd = hookBinaryPath(), let settings = try? loadSettings() else { return false }
        return ClaudeSettingsHook.isRegistered(settings, command: cmd)
    }

    /// Register (true) or unregister (false) the hook. Throws `HookError` rather
    /// than risk damaging the file.
    static func setEnabled(_ enabled: Bool) throws {
        guard let cmd = hookBinaryPath() else { throw HookError.binaryNotFound }
        let current = try loadSettings()
        let updated = enabled
            ? ClaudeSettingsHook.register(current, command: cmd)
            : ClaudeSettingsHook.unregister(current, command: cmd)
        try writeSettings(updated)
    }

    // MARK: - File I/O

    /// Load + parse settings. A missing file is an empty object; an unparseable
    /// one throws (so callers never overwrite it).
    private static func loadSettings() throws -> JSONValue {
        let url = settingsURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return .object([:]) }
        let text = try String(contentsOf: url, encoding: .utf8)
        do { return try JSONValue.parse(text) }
        catch { throw HookError.unreadableSettings }
    }

    private static func writeSettings(_ value: JSONValue) throws {
        let url = settingsURL()
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        // One-time backup before our first edit.
        if FileManager.default.fileExists(atPath: url.path) {
            let backup = url.appendingPathExtension("howlalert-backup")
            if !FileManager.default.fileExists(atPath: backup.path) {
                try? FileManager.default.copyItem(at: url, to: backup)
            }
        }
        let text = try value.serialized() + "\n"
        try text.write(to: url, atomically: true, encoding: .utf8)
    }
}
