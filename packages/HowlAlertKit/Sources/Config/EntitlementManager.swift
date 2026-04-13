// EntitlementManager — CloudKit entitlement read + Keychain grace cache
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

public final class EntitlementManager: Sendable {
    private let keychainKey = "com.mrdemonwolf.howlalert.entitlement"
    private let graceDays: Int

    public init(graceDays: Int = HowlAlertConstants.keychainGraceDays) {
        self.graceDays = graceDays
    }

    /// Check if user is entitled, with Keychain fallback.
    /// In production, `cloudKitState` comes from a CloudKit query.
    /// If CloudKit is unreachable, falls back to cached Keychain state
    /// with a grace period.
    public func isEntitled(
        cloudKitState: EntitlementState?,
        now: Date = .now
    ) -> Bool {
        if let state = cloudKitState {
            cacheToKeychain(state)
            return state.isValid
        }

        // CloudKit unreachable — check Keychain cache
        guard let cached = loadFromKeychain() else {
            return false
        }

        let graceDeadline = cached.updatedAt.addingTimeInterval(
            TimeInterval(graceDays * 24 * 3600)
        )

        return cached.entitlementActive && now < graceDeadline
    }

    // MARK: - Keychain (placeholder — real impl uses Security framework)

    private func cacheToKeychain(_ state: EntitlementState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults(suiteName: HowlAlertConstants.appGroup)?
            .set(data, forKey: keychainKey)
    }

    private func loadFromKeychain() -> EntitlementState? {
        guard let data = UserDefaults(suiteName: HowlAlertConstants.appGroup)?
            .data(forKey: keychainKey) else { return nil }
        return try? JSONDecoder().decode(EntitlementState.self, from: data)
    }
}
