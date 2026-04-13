// EntitlementState — Subscription entitlement for CloudKit sync
// © 2026 MrDemonWolf, Inc.

import Foundation

public struct EntitlementState: Codable, Sendable, Equatable {
    public let entitlementActive: Bool
    public let expiresAt: Date?
    public let productID: String?
    public let updatedAt: Date

    public init(
        entitlementActive: Bool,
        expiresAt: Date? = nil,
        productID: String? = nil,
        updatedAt: Date = .now
    ) {
        self.entitlementActive = entitlementActive
        self.expiresAt = expiresAt
        self.productID = productID
        self.updatedAt = updatedAt
    }

    public static let inactive = EntitlementState(entitlementActive: false)

    public var isValid: Bool {
        guard entitlementActive else { return false }
        if let expiresAt {
            return expiresAt > .now
        }
        return true
    }
}
