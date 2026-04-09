import Foundation
import HowlAlertKit

/// Sends usage alerts to the Cloudflare Worker for APNs delivery.
///
/// Tracks which percentage thresholds (60 %, 85 %, 100 %) have already fired
/// so the same alert is never sent twice within a billing window. When usage
/// drops back below 60 % the tracker resets automatically.
@MainActor
final class PushService: ObservableObject {

	// MARK: - Published state

	@Published var lastPushResult: PushResult?
	@Published var pushCount = 0

	// MARK: - Types

	struct PushResult {
		let success: Bool
		let timestamp: Date
		let threshold: Double
		let error: String?
	}

	// MARK: - Private

	private let workerURL: URL
	private var lastPushedThreshold: Double = 0
	private let thresholds: [Double] = [60, 85, 100]

	private static let iso8601: ISO8601DateFormatter = {
		let f = ISO8601DateFormatter()
		f.formatOptions = [.withInternetDateTime]
		return f
	}()

	// MARK: - Init

	init(workerURL: URL = URL(string: "https://howlalert-worker.mrdemonwolf.workers.dev")!) {
		self.workerURL = workerURL
	}

	// MARK: - Public API

	/// Check if usage crossed a threshold and send push if needed.
	func checkAndPush(
		usagePercent: Double,
		snapshot: UsageSnapshot,
		paceState: PaceState,
		pairingSecret: String,
		deviceToken: String,
		multiplier: Double,
		limit: Int,
		windowStart: Date,
		windowEnd: Date
	) async {
		if usagePercent < 60 {
			lastPushedThreshold = 0
			return
		}

		guard let crossedThreshold = thresholds.last(where: { usagePercent >= $0 }) else {
			return
		}

		guard crossedThreshold > lastPushedThreshold else { return }

		let payload = buildPayload(
			snapshot: snapshot,
			paceState: paceState,
			deviceToken: deviceToken,
			multiplier: multiplier,
			limit: limit,
			windowStart: windowStart,
			windowEnd: windowEnd
		)

		let result = await sendPush(payload: payload, secret: pairingSecret)
		lastPushResult = result

		if result.success {
			lastPushedThreshold = crossedThreshold
			pushCount += 1
		}
	}

	/// Force send a push (e.g., for rate_limit StopFailure).
	func forcePush(
		snapshot: UsageSnapshot,
		paceState: PaceState,
		pairingSecret: String,
		deviceToken: String,
		multiplier: Double,
		limit: Int,
		windowStart: Date,
		windowEnd: Date
	) async {
		let payload = buildPayload(
			snapshot: snapshot,
			paceState: paceState,
			deviceToken: deviceToken,
			multiplier: multiplier,
			limit: limit,
			windowStart: windowStart,
			windowEnd: windowEnd
		)

		let result = await sendPush(payload: payload, secret: pairingSecret)
		lastPushResult = result

		if result.success {
			pushCount += 1
		}
	}

	/// Reset threshold tracking (e.g., on new billing window).
	func resetThresholds() {
		lastPushedThreshold = 0
	}

	// MARK: - Private helpers

	private func buildPayload(
		snapshot: UsageSnapshot,
		paceState: PaceState,
		deviceToken: String,
		multiplier: Double,
		limit: Int,
		windowStart: Date,
		windowEnd: Date
	) -> [String: Any] {
		let effectiveLimit = Int(Double(limit) * multiplier)
		return [
			"deviceToken": deviceToken,
			"consumed": snapshot.sessionTokens,
			"limit": effectiveLimit,
			"model": snapshot.model,
			"windowStart": Self.iso8601.string(from: windowStart),
			"windowEnd": Self.iso8601.string(from: windowEnd),
			"paceStatus": paceState.status.rawValue,
			"pacePercent": round(paceState.pacePercent * 10) / 10,
		]
	}

	private func sendPush(payload: [String: Any], secret: String) async -> PushResult {
		var body = payload
		body["secret"] = secret

		let url = workerURL.appendingPathComponent("push")
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.timeoutInterval = 15

		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body)
		} catch {
			return PushResult(
				success: false,
				timestamp: Date(),
				threshold: lastPushedThreshold,
				error: "JSON serialization failed: \(error.localizedDescription)"
			)
		}

		do {
			let (data, response) = try await URLSession.shared.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse else {
				return PushResult(
					success: false,
					timestamp: Date(),
					threshold: lastPushedThreshold,
					error: "Invalid response type"
				)
			}

			let isSuccess = (200..<300).contains(httpResponse.statusCode)

			if !isSuccess {
				let responseBody = String(data: data, encoding: .utf8) ?? "No body"
				return PushResult(
					success: false,
					timestamp: Date(),
					threshold: lastPushedThreshold,
					error: "HTTP \(httpResponse.statusCode): \(responseBody)"
				)
			}

			return PushResult(
				success: true,
				timestamp: Date(),
				threshold: lastPushedThreshold,
				error: nil
			)
		} catch {
			return PushResult(
				success: false,
				timestamp: Date(),
				threshold: lastPushedThreshold,
				error: error.localizedDescription
			)
		}
	}
}
