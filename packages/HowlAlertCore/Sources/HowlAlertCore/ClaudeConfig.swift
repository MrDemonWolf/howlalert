import Foundation

/// Locates Claude Code's transcript directories.
///
/// Resolution order (CodexBar-compatible):
/// 1. `CLAUDE_CONFIG_DIR` env — comma-separated; each part gets `projects`
///    appended unless it already ends in `projects`.
/// 2. `~/.config/claude/projects`
/// 3. `~/.claude/projects`
public enum ClaudeConfig {
    /// Existing transcript roots, de-duplicated, in priority order.
    public static func discoverTranscriptRoots(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser,
        fileManager: FileManager = .default
    ) -> [URL] {
        var candidates: [URL] = []

        if let configDir = environment["CLAUDE_CONFIG_DIR"], !configDir.isEmpty {
            for part in configDir.split(separator: ",") {
                let trimmed = part.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { continue }
                var url = URL(fileURLWithPath: trimmed, isDirectory: true)
                if url.lastPathComponent != "projects" {
                    url.appendPathComponent("projects", isDirectory: true)
                }
                candidates.append(url)
            }
        }

        candidates.append(homeDirectory.appendingPathComponent(".config/claude/projects", isDirectory: true))
        candidates.append(homeDirectory.appendingPathComponent(".claude/projects", isDirectory: true))

        var seen = Set<String>()
        var roots: [URL] = []
        for url in candidates {
            let path = url.standardizedFileURL.path
            guard !seen.contains(path) else { continue }
            seen.insert(path)
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue {
                roots.append(url.standardizedFileURL)
            }
        }
        return roots
    }
}
