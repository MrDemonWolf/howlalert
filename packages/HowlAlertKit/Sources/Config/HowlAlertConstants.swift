// HowlAlertConstants — App-wide constants
// © 2026 MrDemonWolf, Inc.

import Foundation

public enum HowlAlertConstants {
    // MARK: - Bundle IDs
    public static let iosBundleID = "com.mrdemonwolf.howlalert"
    public static let watchBundleID = "com.mrdemonwolf.howlalert.watchkitapp"
    public static let macBundleID = "com.mrdemonwolf.howlalert.mac"

    // MARK: - CloudKit
    public static let cloudKitContainer = "iCloud.com.mrdemonwolf.howlalert"
    public static let appGroup = "group.com.mrdemonwolf.howlalert"

    // MARK: - CloudKit Record Types
    public static let devicePairingRecordType = "DevicePairing"
    public static let entitlementRecordType = "Entitlement"
    public static let usageSnapshotRecordType = "UsageSnapshot"

    // MARK: - RevenueCat
    public static let revenueCatEntitlement = "pro"
    public static let monthlyProductID = "com.howlalert.monthly"
    public static let annualProductID = "com.howlalert.annual"

    // MARK: - Timing
    public static let snapshotThrottleSeconds: TimeInterval = 10
    public static let entitlementRefreshHours: TimeInterval = 6
    public static let staleMacMinutes: TimeInterval = 30
    public static let pushCooldownMinutes = 30
    public static let keychainGraceDays = 7
    public static let windowDurationHours: TimeInterval = 5

    // MARK: - Branding
    public static let brandNavy = "#091533"
    public static let brandCyan = "#0FACED"
    public static let supportEmail = "support@mrdemonwolf.com"
    public static let legalEmail = "legal@mrdemonwolf.com"
    public static let copyright = "© 2026 MrDemonWolf, Inc."

    // MARK: - URLs
    public static let websiteURL = URL(string: "https://mrdemonwolf.github.io/howlalert/")!
    public static let privacyURL = URL(string: "https://mrdemonwolf.github.io/howlalert/legal/privacy/")!
    public static let termsURL = URL(string: "https://mrdemonwolf.github.io/howlalert/legal/terms/")!
}
