public enum ClaudePlan: String, Sendable, Codable, Equatable, CaseIterable {
    case free
    case pro
    case max5 = "max_5"
    case max20 = "max_20"

    /// Token limit for this plan (5-hour window)
    public var tokenLimit: Int {
        switch self {
        case .free: return 0
        case .pro: return 32_000
        case .max5: return 160_000
        case .max20: return 640_000
        }
    }
}
