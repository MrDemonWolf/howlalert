// PushClient — Send push requests to the HowlAlert Worker
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public struct PushPayload: Codable, Sendable {
    public let deviceToken: String
    public let cloudkitUserId: String
    public let sourceDeviceName: String
    public let usage: Double
    public let pace: Double
    public let windowEnd: String
    public let kind: String // "threshold" | "done" | "reset"

    public init(
        deviceToken: String,
        cloudkitUserId: String,
        sourceDeviceName: String,
        usage: Double,
        pace: Double,
        windowEnd: Date,
        kind: PushKind
    ) {
        self.deviceToken = deviceToken
        self.cloudkitUserId = cloudkitUserId
        self.sourceDeviceName = sourceDeviceName
        self.usage = usage
        self.pace = pace
        self.windowEnd = ISO8601DateFormatter().string(from: windowEnd)
        self.kind = kind.rawValue
    }
}

public enum PushKind: String, Codable, Sendable {
    case threshold
    case done
    case reset
}

public actor PushClient {
    private let workerURL: URL
    private let session: URLSession

    public init(workerURL: URL = URL(string: "https://howlalert-worker.workers.dev")!) {
        self.workerURL = workerURL
        self.session = URLSession(configuration: .ephemeral)
    }

    public func send(_ payload: PushPayload) async throws -> Bool {
        var request = URLRequest(url: workerURL.appendingPathComponent("push"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { return false }

        if http.statusCode == 200 {
            if let result = try? JSONDecoder().decode(PushResponse.self, from: data) {
                return !result.throttled
            }
        }
        return false
    }
}

private struct PushResponse: Decodable {
    let ok: Bool
    let throttled: Bool
}
