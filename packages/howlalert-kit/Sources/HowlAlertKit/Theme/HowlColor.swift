// HowlColor.swift
//
// Brand color tokens from the Claude Design bundle (see
// downloads/howlalert-design/howlalert/project/HowlAlert.html, section A2).
// Never hard-code hex anywhere else — consume these constants.

import SwiftUI

public extension Color {
    // MARK: - Navy (background scale)
    static let howlNavy900 = Color(red: 0x09 / 255, green: 0x15 / 255, blue: 0x33 / 255)
    static let howlNavy800 = Color(red: 0x0E / 255, green: 0x1B / 255, blue: 0x42 / 255)
    static let howlNavy700 = Color(red: 0x15 / 255, green: 0x27 / 255, blue: 0x5A / 255)
    static let howlNavy600 = Color(red: 0x1E / 255, green: 0x34 / 255, blue: 0x75 / 255)

    // MARK: - Cyan (accent)
    static let howlCyan500 = Color(red: 0x0F / 255, green: 0xAC / 255, blue: 0xED / 255)
    static let howlCyan400 = Color(red: 0x3D / 255, green: 0xBE / 255, blue: 0xF1 / 255)
    static let howlCyan300 = Color(red: 0x7B / 255, green: 0xD3 / 255, blue: 0xF6 / 255)
    static let howlCyan100 = Color(red: 0xD5 / 255, green: 0xF0 / 255, blue: 0xFB / 255)

    // MARK: - State
    /// Window just reset / plenty of room.
    static let howlStateFresh = Color(red: 0x3D / 255, green: 0xDC / 255, blue: 0x97 / 255)
    /// Normal operating state.
    static let howlStateOK = Color(red: 0x0F / 255, green: 0xAC / 255, blue: 0xED / 255)
    /// 80% threshold.
    static let howlStateWarn = Color(red: 0xFF / 255, green: 0xA5 / 255, blue: 0x33 / 255)
    /// 95% threshold.
    static let howlStateCrit = Color(red: 0xFF / 255, green: 0x4D / 255, blue: 0x4D / 255)

    // MARK: - Ink (text on navy)
    static let howlInk100 = Color(red: 0xF4 / 255, green: 0xF7 / 255, blue: 0xFB / 255)
    static let howlInk300 = Color(red: 0xA8 / 255, green: 0xB5 / 255, blue: 0xCF / 255)
    static let howlInk500 = Color(red: 0x6A / 255, green: 0x7A / 255, blue: 0x99 / 255)
    static let howlInk700 = Color(red: 0x3A / 255, green: 0x46 / 255, blue: 0x66 / 255)

    // MARK: - Light surfaces (iOS light mode)
    static let howlLightSurface = Color(red: 0xF8 / 255, green: 0xFA / 255, blue: 0xFE / 255)
    static let howlLightSurface2 = Color(red: 0xEE / 255, green: 0xF2 / 255, blue: 0xF9 / 255)
    static let howlLightInk = Color(red: 0x09 / 255, green: 0x15 / 255, blue: 0x33 / 255)
    static let howlLightInk2 = Color(red: 0x3A / 255, green: 0x46 / 255, blue: 0x66 / 255)
    static let howlLightInk3 = Color(red: 0x6A / 255, green: 0x7A / 255, blue: 0x99 / 255)
}
