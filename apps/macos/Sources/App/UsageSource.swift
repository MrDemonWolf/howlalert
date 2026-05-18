// UsageSource.swift
//
// Pluggable source for live popover data. Both DemoUsageSource and
// LiveUsageSource conform; UsageViewModel swaps between them when the user
// toggles Demo Mode in Settings.

import Foundation
import HowlAlertKit

@MainActor
public protocol UsageSource: AnyObject {
    var snapshot: UsageSnapshot { get }
    var onChange: ((UsageSnapshot) -> Void)? { get set }
    func start()
    func stop()
}

public struct UsageSnapshot: Sendable, Equatable {
    public let window: UsageWindow
    public let planLimit: Int
    public let requestsSoFar: Int
    public let models: [ModelRow.Model]
    public let projected: PaceProjector.Reading
    public let now: Date

    public init(
        window: UsageWindow,
        planLimit: Int,
        requestsSoFar: Int,
        models: [ModelRow.Model],
        projected: PaceProjector.Reading,
        now: Date
    ) {
        self.window = window
        self.planLimit = planLimit
        self.requestsSoFar = requestsSoFar
        self.models = models
        self.projected = projected
        self.now = now
    }
}
