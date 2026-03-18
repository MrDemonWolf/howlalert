// Reads ~/.claude/projects/ to find the active Claude Code project and recent session info

import Foundation

public struct ActiveClaudeSession {
	public let projectPath: String
	public let projectName: String
	public let lastActiveDate: Date

	public init(projectPath: String, projectName: String, lastActiveDate: Date) {
		self.projectPath = projectPath
		self.projectName = projectName
		self.lastActiveDate = lastActiveDate
	}
}

public struct ClaudeSessionReader {

	public static func readActiveSession() -> ActiveClaudeSession? {
		#if os(macOS)
		let fm = FileManager.default
		let home = fm.homeDirectoryForCurrentUser
		let projectsURL = home.appendingPathComponent(".claude/projects", isDirectory: true)

		guard fm.fileExists(atPath: projectsURL.path) else { return nil }

		guard let contents = try? fm.contentsOfDirectory(
			at: projectsURL,
			includingPropertiesForKeys: [.contentModificationDateKey, .isDirectoryKey],
			options: .skipsHiddenFiles
		) else { return nil }

		let directories = contents.filter { url in
			(try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
		}

		guard !directories.isEmpty else { return nil }

		let sorted = directories.compactMap { url -> (URL, Date)? in
			guard let date = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate else {
				return nil
			}
			return (url, date)
		}.sorted { $0.1 > $1.1 }

		guard let (mostRecent, modDate) = sorted.first else { return nil }

		let dirName = mostRecent.lastPathComponent
		let decoded = decodePath(dirName)

		let projectName = decoded
			.split(separator: "/", omittingEmptySubsequences: true)
			.last
			.map(String.init) ?? decoded

		return ActiveClaudeSession(
			projectPath: decoded,
			projectName: projectName,
			lastActiveDate: modDate
		)
		#else
		return nil
		#endif
	}

	// Decodes a Claude project directory name back to an absolute path.
	// Encoding: /Users/foo/bar -> -Users-foo-bar (leading slash becomes hyphen, each slash becomes hyphen)
	// Decoding: replace all hyphens with slashes, prepend / if not already present
	private static func decodePath(_ dirName: String) -> String {
		var path = dirName.replacingOccurrences(of: "-", with: "/")
		if !path.hasPrefix("/") {
			path = "/" + path
		}
		return path
	}
}
