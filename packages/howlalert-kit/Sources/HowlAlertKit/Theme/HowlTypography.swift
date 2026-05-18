// HowlTypography.swift
//
// Type scale from the Claude Design bundle (HowlAlert.html section A3).
// SF Pro everywhere via the system font. SF Mono for numerics — opt in with
// `.monospacedDigit()` on call sites that show counters / countdowns.

import SwiftUI

public extension Font {
    /// 700 56/60 — huge crit countdown numerals.
    static let howlCrit = Font.system(size: 56, weight: .bold)
    /// 700 34/40 — top-level screen titles.
    static let howlDisplay = Font.system(size: 34, weight: .bold)
    /// 600 22/28 — section titles.
    static let howlTitle1 = Font.system(size: 22, weight: .semibold)
    /// 600 17/22 — card titles, list rows.
    static let howlTitle2 = Font.system(size: 17, weight: .semibold)
    /// 400 15/22 — body copy.
    static let howlBody = Font.system(size: 15, weight: .regular)
    /// 500 13/18 — captions, secondary metadata.
    static let howlCaption = Font.system(size: 13, weight: .medium)
    /// 600 11/14 — micro labels, uppercase chips.
    static let howlMicro = Font.system(size: 11, weight: .semibold)
}

public enum HowlLineHeight {
    public static let crit: CGFloat = 60
    public static let display: CGFloat = 40
    public static let title1: CGFloat = 28
    public static let title2: CGFloat = 22
    public static let body: CGFloat = 22
    public static let caption: CGFloat = 18
    public static let micro: CGFloat = 14
}
