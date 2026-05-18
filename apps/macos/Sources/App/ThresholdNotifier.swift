// ThresholdNotifier.swift
//
// Fires local UNUserNotifications when usage crosses the 80% / 95% / reset
// boundaries. Each threshold fires at most once per window so the user
// doesn't get spammed while hovering near a line.

import Foundation
import UserNotifications
import HowlAlertKit

@MainActor
final class ThresholdNotifier {
    enum Threshold: String { case warn, crit, reset }

    private var firedThisWindow: Set<Threshold> = []
    private var lastWindowStart: Date?

    func requestAuthorization() {
        Task {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        }
    }

    func observe(snapshot: UsageSnapshot, previousSnapshot: UsageSnapshot?) {
        // Reset bookkeeping when a new window starts.
        if snapshot.window.windowStart != lastWindowStart {
            firedThisWindow.removeAll()
            lastWindowStart = snapshot.window.windowStart
            // If the prior window had usage > 0 and we just rolled over, fire the
            // "reset" notification once.
            if let prev = previousSnapshot, prev.requestsSoFar > 0 {
                fire(.reset, title: "Window reset!", body: "Fresh 5-hour window. You're back to full reserve.")
            }
        }
        let percent = Double(snapshot.requestsSoFar) / Double(max(1, snapshot.planLimit))
        if percent >= 0.95 {
            fire(.crit, title: "95% used", body: "Runs out in \(ResetCountdown.format(remaining: snapshot.window.remaining(at: snapshot.now))).")
        } else if percent >= 0.80 {
            fire(.warn, title: "80% used", body: "Window is getting tight.")
        }
    }

    private func fire(_ threshold: Threshold, title: String, body: String) {
        guard firedThisWindow.insert(threshold).inserted else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "howlalert.\(threshold.rawValue).\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
