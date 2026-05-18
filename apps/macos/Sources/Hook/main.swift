// HowlAlertHook — Claude Code Stop hook handler (executable entry point).
//
// Contract (PLAN.md §5):
//   - Input:  JSON event on stdin.
//   - Output: exit 0 in <5s. Anything non-zero blocks the next Claude step.
//   - Side effect: append the event to the app's Stop-hook ingest socket so
//                  the menu-bar app can refresh without waiting for FSEvents.
//
// We intentionally never throw out of `main`. Any unexpected condition is
// swallowed and the binary still exits 0, because blocking Claude Code is
// strictly worse than missing one usage update.
//
// This file is intentionally named `main.swift` and uses top-level code —
// SwiftPM and Xcode both treat that as the executable entry point.

import Foundation

let payload = (try? FileHandle.standardInput.readToEnd()) ?? Data()

if let socketURL = appGroupSocketURL() {
    sendOverUnixSocket(socketURL: socketURL, payload: payload)
}

exit(0)

// MARK: - Helpers

func appGroupSocketURL() -> URL? {
    guard let dir = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.mrdemonwolf.howlalert")
    else { return nil }
    return dir.appending(path: "hook.sock")
}

func sendOverUnixSocket(socketURL: URL, payload: Data) {
    let fd = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
    guard fd >= 0 else { return }
    defer { Darwin.close(fd) }

    var addr = sockaddr_un()
    addr.sun_family = sa_family_t(AF_UNIX)
    let path = socketURL.path
    let pathBytes = Array(path.utf8)
    let maxLen = MemoryLayout.size(ofValue: addr.sun_path) - 1
    guard pathBytes.count <= maxLen else { return }
    withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
        ptr.withMemoryRebound(to: CChar.self, capacity: maxLen + 1) { buf in
            for (i, b) in pathBytes.enumerated() {
                buf[i] = CChar(bitPattern: b)
            }
            buf[pathBytes.count] = 0
        }
    }
    let connectResult = withUnsafePointer(to: &addr) { ptr -> Int32 in
        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { p in
            Darwin.connect(fd, p, socklen_t(MemoryLayout<sockaddr_un>.size))
        }
    }
    guard connectResult == 0 else { return }

    var bytes = Array(payload)
    bytes.append(UInt8(ascii: "\n"))
    _ = bytes.withUnsafeBufferPointer { buf in
        Darwin.send(fd, buf.baseAddress, buf.count, 0)
    }
}
