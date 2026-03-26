import Foundation

public actor ConfigFetcher {
	private let workerURL: URL
	private var cachedConfig: RemoteConfig?
	private var lastFetch: Date?
	private let refreshInterval: TimeInterval = 300 // 5 minutes

	public init(workerURL: URL) {
		self.workerURL = workerURL
	}

	public func config() async -> RemoteConfig? {
		if let cachedConfig, let lastFetch,
			Date().timeIntervalSince(lastFetch) < refreshInterval
		{
			return cachedConfig
		}
		return await forceRefresh()
	}

	public func forceRefresh() async -> RemoteConfig? {
		let url = workerURL.appendingPathComponent("config")
		do {
			let (data, response) = try await URLSession.shared.data(from: url)
			guard let httpResponse = response as? HTTPURLResponse,
				httpResponse.statusCode == 200
			else {
				return cachedConfig
			}

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let config = try decoder.decode(RemoteConfig.self, from: data)
			cachedConfig = config
			lastFetch = Date()
			return config
		} catch {
			return cachedConfig
		}
	}
}
