import Foundation
import HowlAlertKit

/// Generates fake usage data for App Store review demo mode
@MainActor
final class DemoDataGenerator: ObservableObject {
	@Published var currentState: DemoState = .ok
	@Published var usagePercent: Double = 0
	@Published var paceState: PaceState?

	private var timer: Timer?
	private var stateIndex = 0

	enum DemoState: CaseIterable {
		case ok
		case approaching
		case limitHit
		case reset
		case inReserve
		case onTrack
		case inDebt

		var displayName: String {
			switch self {
			case .ok: return "OK — Under 60%"
			case .approaching: return "Approaching — 60-85%"
			case .limitHit: return "Limit Hit — 85%+"
			case .reset: return "Reset — New Window"
			case .inReserve: return "Pace: In Reserve"
			case .onTrack: return "Pace: On Track"
			case .inDebt: return "Pace: In Debt"
			}
		}
	}

	/// Start cycling through demo states every 5 seconds
	func startDemo() {
		stateIndex = 0
		updateToState(DemoState.allCases[0])

		timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
			Task { @MainActor in
				guard let self else { return }
				self.stateIndex = (self.stateIndex + 1) % DemoState.allCases.count
				self.updateToState(DemoState.allCases[self.stateIndex])
			}
		}
	}

	/// Stop the demo cycle
	func stopDemo() {
		timer?.invalidate()
		timer = nil
	}

	private func updateToState(_ state: DemoState) {
		currentState = state
		let now = Date()
		let windowStart = now.addingTimeInterval(-3600)  // 1 hour ago
		let windowEnd = now.addingTimeInterval(14400)     // 4 hours from now

		switch state {
		case .ok:
			usagePercent = 35
			paceState = calculatePace(
				consumed: 35000, limit: 100000,
				windowStart: windowStart, windowEnd: windowEnd, now: now
			)
		case .approaching:
			usagePercent = 72
			paceState = calculatePace(
				consumed: 72000, limit: 100000,
				windowStart: windowStart, windowEnd: windowEnd, now: now
			)
		case .limitHit:
			usagePercent = 94
			paceState = calculatePace(
				consumed: 94000, limit: 100000,
				windowStart: windowStart, windowEnd: windowEnd, now: now
			)
		case .reset:
			usagePercent = 2
			paceState = nil
		case .inReserve:
			usagePercent = 15
			paceState = calculatePace(
				consumed: 15000, limit: 100000,
				windowStart: windowStart, windowEnd: windowEnd, now: now
			)
		case .onTrack:
			usagePercent = 20
			paceState = calculatePace(
				consumed: 20000, limit: 100000,
				windowStart: windowStart, windowEnd: windowEnd, now: now
			)
		case .inDebt:
			usagePercent = 55
			paceState = calculatePace(
				consumed: 55000, limit: 100000,
				windowStart: windowStart, windowEnd: windowEnd, now: now,
				multiplier: 0.5  // Simulate faster consumption
			)
		}
	}

	/// Generate fake recent events for the history view
	static func generateFakeEvents(count: Int = 10) -> [FakeUsageEvent] {
		let models = ["claude-opus-4-6", "claude-sonnet-4-6", "claude-haiku-4-5"]
		var events: [FakeUsageEvent] = []

		for i in 0..<count {
			let minutesAgo = Double(i * 5 + Int.random(in: 0...3))
			events.append(FakeUsageEvent(
				model: models.randomElement()!,
				inputTokens: Int.random(in: 500...5000),
				outputTokens: Int.random(in: 200...3000),
				timestamp: Date().addingTimeInterval(-minutesAgo * 60)
			))
		}

		return events.sorted { $0.timestamp > $1.timestamp }
	}
}

struct FakeUsageEvent: Identifiable {
	let id = UUID()
	let model: String
	let inputTokens: Int
	let outputTokens: Int
	let timestamp: Date

	var totalTokens: Int { inputTokens + outputTokens }
}
