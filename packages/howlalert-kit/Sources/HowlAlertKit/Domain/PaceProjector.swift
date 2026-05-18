// PaceProjector.swift
//
// Given the current usage window + elapsed seconds + request count so far,
// project end-of-window usage and classify pace for PaceChip.
//
// The math is intentionally trivial: project as a linear extrapolation of
// observed usage rate. We are not trying to predict — we are showing the
// user what happens if they keep going at the current pace.

import Foundation

public struct PaceProjector: Sendable {
    public struct Reading: Sendable, Equatable {
        public let percentUsed: Double
        public let percentProjected: Double
        public let usageState: UsageState
        public let projectedState: UsageState
        public let pace: PaceChip.Pace
    }

    /// Threshold below which we always render `.fresh` regardless of usage —
    /// gives a brief grace period right after a window starts.
    public static let freshGraceSeconds: TimeInterval = 5 * 60

    public init() {}

    public func project(
        window: UsageWindow,
        requestsSoFar: Int,
        planLimit: Int,
        now: Date
    ) -> Reading {
        precondition(planLimit > 0, "planLimit must be positive")

        let elapsed = window.elapsed(at: now)
        let total = UsageWindow.windowSeconds
        let percentUsed = Double(requestsSoFar) / Double(planLimit)
        let projected: Double = {
            guard elapsed > 0 else { return percentUsed }
            let rate = Double(requestsSoFar) / elapsed   // requests per second
            return (rate * total) / Double(planLimit)
        }()

        // States.
        let isFresh = elapsed < Self.freshGraceSeconds
        let usageState: UsageState = isFresh ? .fresh : UsageState.from(percentUsed: percentUsed)
        let projectedState = UsageState.from(percentUsed: projected)

        // PaceChip classification.
        let pace: PaceChip.Pace
        if isFresh {
            pace = .fresh
        } else if projected > 1.0 {
            pace = .behind        // will overrun the window — bad
        } else if projected <= 0.80 {
            pace = .ahead         // forecast leaves comfortable headroom
        } else {
            pace = .onPace
        }

        return Reading(
            percentUsed: percentUsed,
            percentProjected: projected,
            usageState: usageState,
            projectedState: projectedState,
            pace: pace
        )
    }
}
