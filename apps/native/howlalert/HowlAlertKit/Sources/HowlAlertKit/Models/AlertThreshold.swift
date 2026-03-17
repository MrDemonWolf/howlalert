import Foundation

public enum ThresholdType: String, Codable, CaseIterable {
    case dailyCost = "daily_cost"
    case tokenCount = "token_count"
    case sessionCount = "session_count"
}

public struct AlertThreshold: Codable, Identifiable, Equatable {
    public let id: String
    public let type: ThresholdType
    public var value: Double
    public var isEnabled: Bool

    public init(
        id: String = UUID().uuidString,
        type: ThresholdType,
        value: Double,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.type = type
        self.value = value
        self.isEnabled = isEnabled
    }

    public static let defaults: [AlertThreshold] = [
        AlertThreshold(type: .dailyCost, value: 5.0),
        AlertThreshold(type: .tokenCount, value: 100_000),
    ]
}
