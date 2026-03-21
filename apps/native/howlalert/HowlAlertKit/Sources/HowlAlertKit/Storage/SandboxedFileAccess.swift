import Foundation

/// Manages sandboxed file access to the Claude configuration directory.
/// On macOS, handles security-scoped bookmark resolution for App Sandbox.
public final class SandboxedFileAccess {
	public static let shared = SandboxedFileAccess()

	private let defaults = UserDefaults(suiteName: "group.com.mrdemonwolf.howlalert") ?? .standard
	private let bookmarkKey = "claudeDirectoryBookmark"

	private init() {}

	/// The default Claude config directory URL
	public var defaultClaudeURL: URL {
		FileManager.default.homeDirectoryForCurrentUser
			.appendingPathComponent(".claude", isDirectory: true)
	}

	/// Whether the user has granted access to the Claude directory
	public var hasAccess: Bool {
		#if os(macOS)
		return defaults.data(forKey: bookmarkKey) != nil
			|| FileManager.default.isReadableFile(atPath: defaultClaudeURL.path)
		#else
		return false
		#endif
	}

	/// Store a security-scoped bookmark for the given URL
	#if os(macOS)
	public func storeBookmark(for url: URL) throws {
		let bookmark = try url.bookmarkData(
			options: .withSecurityScope,
			includingResourceValuesForKeys: nil,
			relativeTo: nil
		)
		defaults.set(bookmark, forKey: bookmarkKey)
	}
	#endif

	/// Resolve the bookmark and execute the closure with access to the Claude directory
	public func resolveAndAccess(_ body: (URL) throws -> Void) throws {
		#if os(macOS)
		// Try direct access first (non-sandboxed or already accessible)
		if FileManager.default.isReadableFile(atPath: defaultClaudeURL.path) {
			try body(defaultClaudeURL)
			return
		}

		// Try security-scoped bookmark
		guard let bookmarkData = defaults.data(forKey: bookmarkKey) else {
			throw SandboxError.noBookmark
		}

		var isStale = false
		let url = try URL(
			resolvingBookmarkData: bookmarkData,
			options: .withSecurityScope,
			relativeTo: nil,
			bookmarkDataIsStale: &isStale
		)

		if isStale {
			// Re-store the bookmark
			try storeBookmark(for: url)
		}

		guard url.startAccessingSecurityScopedResource() else {
			throw SandboxError.accessDenied
		}
		defer { url.stopAccessingSecurityScopedResource() }

		try body(url)
		#else
		throw SandboxError.unsupportedPlatform
		#endif
	}

	public enum SandboxError: Error, LocalizedError {
		case noBookmark
		case accessDenied
		case unsupportedPlatform

		public var errorDescription: String? {
			switch self {
			case .noBookmark: return "No Claude directory bookmark stored. Please select your Claude directory."
			case .accessDenied: return "Access to the Claude directory was denied."
			case .unsupportedPlatform: return "Direct file access is only available on macOS."
			}
		}
	}
}
