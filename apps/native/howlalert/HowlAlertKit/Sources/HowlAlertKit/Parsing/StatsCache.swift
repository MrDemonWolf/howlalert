import Foundation

public struct StatsCache: Codable {
    public let totalCost: Double?
    public let totalTokens: Int?
    public let sessionCount: Int?
    public let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case totalCost = "total_cost"
        case totalTokens = "total_tokens"
        case sessionCount = "session_count"
        case lastUpdated = "last_updated"
    }
}

public struct StatsCacheParser {
    public static func parse(from url: URL) throws -> StatsCache {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(StatsCache.self, from: data)
    }

    public static func defaultURL() -> URL? {
        #if os(macOS)
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/stats-cache.json")
        #else
        return nil
        #endif
    }
}
