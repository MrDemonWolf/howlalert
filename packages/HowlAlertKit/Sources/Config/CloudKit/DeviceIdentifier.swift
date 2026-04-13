// DeviceIdentifier — Determine current Mac's identity for multi-Mac tracking
// © 2026 MrDemonWolf, Inc.

import Foundation
import Models

#if os(macOS)
import IOKit

public struct DeviceIdentifier: Sendable {
    public let id: String
    public let name: String
    public let type: DeviceType

    public init() {
        self.id = Self.hardwareUUID()
        self.name = Host.current().localizedName ?? "Mac"
        self.type = Self.detectType()
    }

    private static func hardwareUUID() -> String {
        let service = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )
        defer { IOObjectRelease(service) }

        guard let uuid = IORegistryEntryCreateCFProperty(
            service,
            "IOPlatformUUID" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? String else {
            return UUID().uuidString
        }
        return uuid
    }

    private static func detectType() -> DeviceType {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        let bytes = model.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }
        let modelString = String(decoding: bytes, as: UTF8.self).lowercased()

        if modelString.contains("macbookpro") { return .macBookPro }
        if modelString.contains("macbookair") { return .macBookAir }
        if modelString.contains("macmini") { return .macMini }
        if modelString.contains("macstudio") { return .macStudio }
        if modelString.contains("imac") { return .iMac }
        if modelString.contains("macpro") { return .macPro }
        return .unknown
    }
}
#endif
