import Foundation

// Fires callbacks when usage crosses configured thresholds
public final class ThresholdNotifier: @unchecked Sendable {
    public typealias ThresholdCallback = @Sendable (Double, ThresholdLevel) -> Void

    public enum ThresholdLevel: Double, CaseIterable {
        case approaching = 0.60
        case critical = 0.85
        case limit = 1.0
    }

    private let callback: ThresholdCallback
    private var firedLevels: Set<ThresholdLevel> = []
    private var lastResetAt: Date?

    public init(callback: @escaping ThresholdCallback) {
        self.callback = callback
    }

    /// Call this whenever usage percent changes
    public func update(usagePercent: Double, now: Date = .now) {
        // Reset fired levels if usage dropped back below 0.10 (session reset)
        if usagePercent < 0.10 {
            firedLevels.removeAll()
            lastResetAt = now
        }

        for level in ThresholdLevel.allCases {
            if usagePercent >= level.rawValue && !firedLevels.contains(level) {
                firedLevels.insert(level)
                callback(usagePercent, level)
            }
        }
    }

    public func reset() {
        firedLevels.removeAll()
    }
}

extension ThresholdNotifier.ThresholdLevel: Hashable {}
