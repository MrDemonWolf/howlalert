// UsageWindow.swift
//
// Claude Code's 5-hour usage window. Per PLAN.md §4:
//   windowStart = floor(firstRequestTime, hour, .utc)
//   windowEnd   = windowStart + 5h
//
// All math runs in UTC. DST never enters the picture.

import Foundation

public struct UsageWindow: Sendable, Equatable, Hashable, Codable {
    /// First request inside the window — what we floor against.
    public let firstRequestTime: Date
    /// UTC-hour-floored start of the 5h window.
    public let windowStart: Date
    /// `windowStart + 5h`.
    public let windowEnd: Date

    public init(firstRequestTime: Date) {
        self.firstRequestTime = firstRequestTime
        self.windowStart = Self.floorToUTCHour(firstRequestTime)
        self.windowEnd = self.windowStart.addingTimeInterval(Self.windowSeconds)
    }

    /// Window length in seconds (5h).
    public static let windowSeconds: TimeInterval = 5 * 60 * 60

    /// Floor a `Date` to the start of its UTC hour.
    public static func floorToUTCHour(_ date: Date) -> Date {
        let interval = date.timeIntervalSince1970
        let hourSeconds: TimeInterval = 3600
        let floored = floor(interval / hourSeconds) * hourSeconds
        return Date(timeIntervalSince1970: floored)
    }

    /// Seconds elapsed inside this window at `now`. Clamped to `[0, windowSeconds]`.
    public func elapsed(at now: Date) -> TimeInterval {
        max(0, min(Self.windowSeconds, now.timeIntervalSince(windowStart)))
    }

    /// Seconds remaining until `windowEnd`. Negative when the window has already
    /// ended (a fresh window should be created).
    public func remaining(at now: Date) -> TimeInterval {
        windowEnd.timeIntervalSince(now)
    }

    /// True when `now` falls within `[windowStart, windowEnd)`.
    public func contains(_ now: Date) -> Bool {
        now >= windowStart && now < windowEnd
    }

    /// Resume vs. fresh window decision.
    ///
    /// Given the previous window (if any) and the timestamp of the next request,
    /// return whichever window should host the new request. A fresh window is
    /// created when the previous window has fully elapsed.
    public static func resume(previous: UsageWindow?, requestTime: Date) -> UsageWindow {
        if let previous, previous.contains(requestTime) {
            return previous
        }
        return UsageWindow(firstRequestTime: requestTime)
    }
}
