import Foundation
import CoreFoundation

/// Lightweight cross-process nudge from the Stop-hook binary to the running app.
///
/// Uses a Darwin notification (no entitlements, no ports, survives across
/// processes). The hook binary `post()`s when a Claude Code turn ends; the app
/// `observeStop`s and refreshes immediately instead of waiting on FSEvents.
public enum HowlSignal {
    /// Darwin notification name shared by the hook binary and the app.
    public static let stopName = "com.howlalert.stop"

    /// Fire the "a turn just ended" signal. Safe to call from a short-lived CLI.
    public static func post() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(stopName as CFString),
            nil, nil, true
        )
    }

    // Darwin callbacks are C function pointers (no capture), so the handler is
    // held in a static and invoked from the callback.
    nonisolated(unsafe) private static var handler: (() -> Void)?

    /// Observe the stop signal. `block` runs on whichever run loop services the
    /// notification — callers should hop to their actor as needed.
    public static func observeStop(_ block: @escaping () -> Void) {
        handler = block
        let callback: CFNotificationCallback = { _, _, _, _, _ in
            HowlSignal.handler?()
        }
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            callback,
            stopName as CFString,
            nil,
            .deliverImmediately
        )
    }
}
