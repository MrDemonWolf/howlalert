// ThresholdNotifier — Fire alerts at 60/85/100% with cooldowns
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models
import TokenMath
import ColorState

public enum ThresholdLevel: Int, Codable, Sendable, CaseIterable {
    case approaching = 60
    case critical = 85
    case limitHit = 100
}

public struct ThresholdEvent: Sendable {
    public let level: ThresholdLevel
    public let usagePercent: Double
    public let paceState: PaceState
    public let sourceDeviceName: String?
}

public final class ThresholdNotifier: Sendable {
    private let cooldownSeconds: TimeInterval
    private let lastFired: ManagedAtomic<[ThresholdLevel: Date]>

    public init(cooldownMinutes: Int = 30) {
        self.cooldownSeconds = TimeInterval(cooldownMinutes * 60)
        self.lastFired = ManagedAtomic([:])
    }

    public func check(
        usagePercent: Double,
        paceState: PaceState,
        sourceDeviceName: String? = nil,
        now: Date = .now
    ) -> ThresholdEvent? {
        let levels = ThresholdLevel.allCases.reversed()

        for level in levels {
            guard usagePercent >= Double(level.rawValue) else { continue }

            let state = lastFired.value
            if let lastTime = state[level],
               now.timeIntervalSince(lastTime) < cooldownSeconds {
                continue
            }

            var updated = state
            updated[level] = now
            lastFired.value = updated

            return ThresholdEvent(
                level: level,
                usagePercent: usagePercent,
                paceState: paceState,
                sourceDeviceName: sourceDeviceName
            )
        }

        return nil
    }

    public func reset() {
        lastFired.value = [:]
    }
}

/// Simple thread-safe wrapper (Swift 6 strict concurrency)
private final class ManagedAtomic<Value: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Value

    init(_ value: Value) {
        self._value = value
    }

    var value: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _value = newValue
        }
    }
}
