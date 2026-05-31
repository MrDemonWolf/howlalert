import Foundation

/// Pure edits to the `Stop` hook in Claude Code's `settings.json`.
///
/// Claude Code stores hooks as `hooks.Stop = [ { hooks: [ { type, command } ] } ]`.
/// These functions add/remove exactly our command, idempotently, and leave every
/// other hook and setting untouched. The desktop app owns the file I/O; this is
/// the testable core.
public enum ClaudeSettingsHook {
    static let hookType = "command"

    /// True if `command` is registered as a Stop hook anywhere in `settings`.
    public static func isRegistered(_ settings: JSONValue, command: String) -> Bool {
        let groups = settings.objectValue?["hooks"]?.objectValue?["Stop"]?.arrayValue ?? []
        for group in groups {
            let inner = group.objectValue?["hooks"]?.arrayValue ?? []
            if inner.contains(where: { $0.objectValue?["command"]?.stringValue == command }) {
                return true
            }
        }
        return false
    }

    /// Add `command` as a Stop hook. No-op if already present.
    public static func register(_ settings: JSONValue, command: String) -> JSONValue {
        guard !isRegistered(settings, command: command) else { return settings }
        var root = settings.objectValue ?? [:]
        var hooks = root["hooks"]?.objectValue ?? [:]
        var stop = hooks["Stop"]?.arrayValue ?? []

        let entry = JSONValue.object(["type": .string(hookType), "command": .string(command)])
        stop.append(.object(["hooks": .array([entry])]))

        hooks["Stop"] = .array(stop)
        root["hooks"] = .object(hooks)
        return .object(root)
    }

    /// Remove every Stop-hook entry whose command equals `command`, dropping any
    /// group (or the `Stop` / `hooks` keys) left empty as a result.
    public static func unregister(_ settings: JSONValue, command: String) -> JSONValue {
        guard var root = settings.objectValue,
              var hooks = root["hooks"]?.objectValue,
              let stop = hooks["Stop"]?.arrayValue else { return settings }

        var newStop: [JSONValue] = []
        for group in stop {
            guard var g = group.objectValue, let inner = g["hooks"]?.arrayValue else {
                newStop.append(group)   // unrecognized shape — leave it alone
                continue
            }
            let kept = inner.filter { $0.objectValue?["command"]?.stringValue != command }
            if kept.isEmpty { continue } // drop now-empty group
            g["hooks"] = .array(kept)
            newStop.append(.object(g))
        }

        if newStop.isEmpty { hooks.removeValue(forKey: "Stop") } else { hooks["Stop"] = .array(newStop) }
        if hooks.isEmpty { root.removeValue(forKey: "hooks") } else { root["hooks"] = .object(hooks) }
        return .object(root)
    }
}
