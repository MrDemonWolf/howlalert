import Foundation

/// View data for `DetailedPopover`. The desktop app maps a live usage snapshot
/// into this; `.demo` is the rich static showcase (also used by previews and
/// Demo Mode).
public struct PopoverData: Sendable, Equatable {
    /// One usage meter row (Session / Week).
    public struct Window: Sendable, Equatable {
        public var title: String
        public var remaining: Double
        public var pace: Double
        public var state: HowlState
        public var trailingValue: String
        public var metaLeading: String
        public var deficit: String?

        public init(title: String, remaining: Double, pace: Double, state: HowlState,
                    trailingValue: String, metaLeading: String, deficit: String? = nil) {
            self.title = title
            self.remaining = remaining
            self.pace = pace
            self.state = state
            self.trailingValue = trailingValue
            self.metaLeading = metaLeading
            self.deficit = deficit
        }
    }

    /// One "Recent" model row.
    public struct Model: Sendable, Equatable {
        public var name: String
        public var points: [Double]
        public var value: String
        public var state: HowlState

        public init(name: String, points: [Double], value: String, state: HowlState) {
            self.name = name
            self.points = points
            self.value = value
            self.state = state
        }
    }

    public var paceText: String
    public var paceState: HowlState
    public var critRemaining: Double
    public var critState: HowlState
    public var critLabel: String
    public var resetText: String
    public var resetState: HowlState
    public var resetLastMinute: Bool
    public var session: Window
    /// Shown only when present (the weekly window isn't wired live yet).
    public var week: Window?
    public var models: [Model]
    /// e.g. "Updated 12s ago" — `nil` hides it (demo).
    public var updatedText: String?

    public init(
        paceText: String, paceState: HowlState,
        critRemaining: Double, critState: HowlState, critLabel: String,
        resetText: String, resetState: HowlState, resetLastMinute: Bool,
        session: Window, week: Window? = nil, models: [Model] = [], updatedText: String? = nil
    ) {
        self.paceText = paceText
        self.paceState = paceState
        self.critRemaining = critRemaining
        self.critState = critState
        self.critLabel = critLabel
        self.resetText = resetText
        self.resetState = resetState
        self.resetLastMinute = resetLastMinute
        self.session = session
        self.week = week
        self.models = models
        self.updatedText = updatedText
    }

    /// Rich static showcase — mirrors the design refs.
    public static let demo = PopoverData(
        paceText: "Runs out in 47m", paceState: .warn,
        critRemaining: 0.16, critState: .warn, critLabel: "5-hour window",
        resetText: "Resets in 47m", resetState: .warn, resetLastMinute: false,
        session: Window(title: "Session", remaining: 0.16, pace: 0.4, state: .warn,
                        trailingValue: "16%", metaLeading: "3.2M tokens", deficit: "runs out in 47m"),
        week: Window(title: "Week", remaining: 0.62, pace: 0.55, state: .ok,
                     trailingValue: "62%", metaLeading: "Resets Sunday"),
        models: [
            Model(name: "Opus 4.7", points: [2, 3, 5, 4, 7, 6, 9], value: "1.8M", state: .warn),
            Model(name: "Sonnet 4.6", points: [1, 2, 2, 3, 2, 4, 3], value: "0.9M", state: .ok),
        ]
    )
}
