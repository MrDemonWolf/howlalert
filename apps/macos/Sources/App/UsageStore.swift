// UsageStore.swift
//
// In-memory store of observed Claude events, scoped to the current window.
// Phase 0 keeps everything in memory; SQLite history (PLAN.md §5) lands with
// the Stop hook in Slice 7. A new window is opened when a request arrives
// past the previous window's end.

import Foundation
import HowlAlertKit

@MainActor
final class UsageStore {
    private(set) var window: UsageWindow?
    private(set) var requestsByModel: [String: Int] = [:]
    private(set) var totalRequests: Int = 0

    func ingest(_ event: ClaudeEvent) {
        let win = UsageWindow.resume(previous: window, requestTime: event.timestamp)
        if win != window {
            window = win
            requestsByModel.removeAll(keepingCapacity: true)
            totalRequests = 0
        }
        totalRequests += 1
        let key = event.model ?? "unknown"
        requestsByModel[key, default: 0] += 1
    }

    func reset() {
        window = nil
        requestsByModel.removeAll()
        totalRequests = 0
    }

    func models() -> [ModelRow.Model] {
        let total = max(1, totalRequests)
        return requestsByModel
            .map { id, count in
                ModelRow.Model(
                    id: id,
                    name: id,
                    sessions: count,
                    percentOfWindow: Double(count) / Double(total)
                )
            }
            .sorted { $0.sessions > $1.sessions }
    }
}
