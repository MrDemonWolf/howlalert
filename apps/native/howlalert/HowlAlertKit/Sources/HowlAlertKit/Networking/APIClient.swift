import Foundation

public final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    public init(
        baseURL: URL = URL(string: "https://howlalert-worker.mrdemonwolf.workers.dev")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func setAuthToken(_ token: String) {
        self.authToken = token
    }

    public func registerDevice(deviceToken: String, platform: String) async throws {
        let body = ["device_token": deviceToken, "platform": platform]
        _ = try await post(path: "/register", body: body)
    }

    public func sendEvent(_ event: UsageEvent) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(event)
        _ = try await postData(path: "/event", data: data)
    }

    public func getHistory(limit: Int = 50, offset: Int = 0) async throws -> [UsageEvent] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/history"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
        ]
        let (data, _) = try await authorizedRequest(url: components.url!)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode([String: [UsageEvent]].self, from: data)
        return response["events"] ?? []
    }

    public func updatePreferences(thresholds: [AlertThreshold]) async throws {
        struct PrefsBody: Encodable {
            let thresholds: [AlertThreshold]
        }
        let data = try JSONEncoder().encode(PrefsBody(thresholds: thresholds))
        _ = try await postData(path: "/preferences", data: data)
    }

    private func post<T: Encodable>(path: String, body: T) async throws -> Data {
        let data = try JSONEncoder().encode(body)
        return try await postData(path: path, data: data)
    }

    private func postData(path: String, data: Data) async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = data
        let (responseData, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return responseData
    }

    private func authorizedRequest(url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return try await session.data(for: request)
    }
}

public enum APIError: Error {
    case httpError(Int)
    case unauthorized
    case decodingError
}
