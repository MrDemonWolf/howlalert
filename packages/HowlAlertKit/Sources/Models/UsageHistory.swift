import Foundation

/// A daily summary of usage events.
public struct DailySummary: Sendable {
	public let totalTokens: Int
	public let totalInput: Int
	public let totalOutput: Int
	public let totalCacheRead: Int
	public let totalCacheWrite: Int
	public let eventCount: Int
	public let uniqueModels: Set<String>
	public let firstEvent: Date?
	public let lastEvent: Date?

	public init(
		totalTokens: Int,
		totalInput: Int,
		totalOutput: Int,
		totalCacheRead: Int,
		totalCacheWrite: Int,
		eventCount: Int,
		uniqueModels: Set<String>,
		firstEvent: Date?,
		lastEvent: Date?
	) {
		self.totalTokens = totalTokens
		self.totalInput = totalInput
		self.totalOutput = totalOutput
		self.totalCacheRead = totalCacheRead
		self.totalCacheWrite = totalCacheWrite
		self.eventCount = eventCount
		self.uniqueModels = uniqueModels
		self.firstEvent = firstEvent
		self.lastEvent = lastEvent
	}
}

/// Manages a rolling window of usage events with persistence.
public actor UsageHistory {
	private var events: [UsageEvent] = []
	private let maxEvents: Int
	private let storageURL: URL?

	public init(maxEvents: Int = 500, storageURL: URL? = nil) {
		self.maxEvents = maxEvents
		self.storageURL = storageURL
	}

	public func add(_ event: UsageEvent) {
		events.append(event)
		// Trim to rolling window
		if events.count > maxEvents {
			events.removeFirst(events.count - maxEvents)
		}
	}

	public func events(since date: Date) -> [UsageEvent] {
		events.filter { $0.timestamp >= date }
	}

	public func todayEvents() -> [UsageEvent] {
		let startOfDay = Calendar.current.startOfDay(for: Date())
		return events(since: startOfDay)
	}

	public func recentEvents(count: Int = 20) -> [UsageEvent] {
		Array(events.suffix(count))
	}

	public func dailySummary() -> DailySummary {
		let today = todayEvents()

		let totalInput = today.reduce(0) { $0 + $1.inputTokens }
		let totalOutput = today.reduce(0) { $0 + $1.outputTokens }
		let totalCacheRead = today.reduce(0) { $0 + $1.cacheReadTokens }
		let totalCacheWrite = today.reduce(0) { $0 + $1.cacheWriteTokens }
		let totalTokens = totalInput + totalOutput + totalCacheRead + totalCacheWrite
		let models = Set(today.map { $0.model })

		return DailySummary(
			totalTokens: totalTokens,
			totalInput: totalInput,
			totalOutput: totalOutput,
			totalCacheRead: totalCacheRead,
			totalCacheWrite: totalCacheWrite,
			eventCount: today.count,
			uniqueModels: models,
			firstEvent: today.first?.timestamp,
			lastEvent: today.last?.timestamp
		)
	}

	public func clearOlderThan(_ date: Date) {
		events.removeAll { $0.timestamp < date }
	}

	// MARK: - Persistence

	public func save() async throws {
		guard let url = storageURL else { return }
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(events)
		try data.write(to: url, options: .atomic)
	}

	public func load() async throws {
		guard let url = storageURL else { return }
		guard FileManager.default.fileExists(atPath: url.path) else { return }
		let data = try Data(contentsOf: url)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		let loaded = try decoder.decode([UsageEvent].self, from: data)
		// Only keep up to maxEvents, most recent first
		if loaded.count > maxEvents {
			events = Array(loaded.suffix(maxEvents))
		} else {
			events = loaded
		}
	}
}
