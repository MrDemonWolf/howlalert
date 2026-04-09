import Foundation

public actor ConfigFetcher {
    private let workerURL: URL
    private let cacheKey = "remoteConfig"
    public private(set) var config: RemoteConfig = .default

    public init(workerURL: URL) {
        self.workerURL = workerURL
        // Load cached config from UserDefaults on init
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode(RemoteConfig.self, from: data) {
            self.config = cached
        }
    }

    @discardableResult
    public func fetch() async -> RemoteConfig {
        let url = workerURL.appendingPathComponent("config")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetched = try JSONDecoder().decode(RemoteConfig.self, from: data)
            self.config = fetched
            UserDefaults.standard.set(try? JSONEncoder().encode(fetched), forKey: cacheKey)
            return fetched
        } catch {
            return self.config  // return cached on failure
        }
    }

    public func startPolling(interval: TimeInterval = 300) {
        Task {
            while true {
                try? await Task.sleep(for: .seconds(interval))
                await fetch()
            }
        }
    }
}
