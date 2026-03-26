import Foundation

struct JSONLEvent {
	let inputTokens: Int
	let outputTokens: Int
	let cacheReadTokens: Int
	let cacheWriteTokens: Int
	let model: String
	let timestamp: Date?
}

/// Parses Claude Code JSONL lines to extract usage data.
///
/// Each line in a Claude Code `.jsonl` file is a JSON object.
/// Usage data lives at `message.usage` with keys like `input_tokens`,
/// `output_tokens`, `cache_creation_input_tokens`, and `cache_read_input_tokens`.
enum JSONLParser {

	/// Parse a single line from a `.jsonl` file.
	///
	/// Returns `nil` for malformed lines or lines that do not contain usage data.
	static func parse(line: String) -> JSONLEvent? {
		guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }

		guard let data = line.data(using: .utf8),
			  let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
		else {
			return nil
		}

		// Usage lives under message.usage
		guard let message = root["message"] as? [String: Any],
			  let usage = message["usage"] as? [String: Any]
		else {
			return nil
		}

		guard let inputTokens = usage["input_tokens"] as? Int,
			  let outputTokens = usage["output_tokens"] as? Int
		else {
			return nil
		}

		let cacheCreation = usage["cache_creation_input_tokens"] as? Int ?? 0
		let cacheRead = usage["cache_read_input_tokens"] as? Int ?? 0

		// Model can be at the top level or inside message
		let model = (root["model"] as? String)
			?? (message["model"] as? String)
			?? ""

		// Attempt to parse an ISO-8601 timestamp if present
		var timestamp: Date?
		if let ts = root["timestamp"] as? String ?? message["timestamp"] as? String {
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
			timestamp = formatter.date(from: ts)
			if timestamp == nil {
				// Retry without fractional seconds
				formatter.formatOptions = [.withInternetDateTime]
				timestamp = formatter.date(from: ts)
			}
		}

		return JSONLEvent(
			inputTokens: inputTokens,
			outputTokens: outputTokens,
			cacheReadTokens: cacheRead,
			cacheWriteTokens: cacheCreation,
			model: model,
			timestamp: timestamp
		)
	}
}
