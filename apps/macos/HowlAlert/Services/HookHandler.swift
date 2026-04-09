import Foundation
import HowlAlertKit

#if canImport(AppKit)
import AppKit
#endif

/// Handles Claude Code Stop and StopFailure hook events.
enum HookHandler {
	struct HookEvent: Codable {
		let event: String
		let error: String?
		let sessionId: String?
		let lastAssistantMessage: String?
	}

	/// Parse a hook event from stdin JSON.
	static func parseEvent(from data: Data) -> HookEvent? {
		let decoder = JSONDecoder()
		return try? decoder.decode(HookEvent.self, from: data)
	}

	/// Check if the event indicates a rate limit.
	static func isRateLimited(_ event: HookEvent) -> Bool {
		return event.error == "rate_limit"
	}

	/// Generate the hook configuration JSON for .claude/settings.json.
	static func hookConfigJSON() -> String {
		let bundlePath = Bundle.main.bundlePath
		let hookBinary = "\(bundlePath)/Contents/MacOS/howlalert-hook"

		return """
		{
		  "hooks": {
		    "Stop": [
		      {
		        "hooks": [
		          {
		            "type": "command",
		            "command": "\(hookBinary) stop"
		          }
		        ]
		      }
		    ],
		    "StopFailure": [
		      {
		        "hooks": [
		          {
		            "type": "command",
		            "command": "\(hookBinary) stop-failure"
		          }
		        ]
		      }
		    ]
		  }
		}
		"""
	}

	/// Copy hook config to clipboard.
	static func copyHookConfigToClipboard() {
		#if canImport(AppKit)
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(hookConfigJSON(), forType: .string)
		#endif
	}
}
