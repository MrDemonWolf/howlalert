import Foundation

public final class UserPreferences: ObservableObject {
    private let defaults: UserDefaults

    public static let shared = UserPreferences()

    @Published public var thresholds: [AlertThreshold] {
        didSet { saveThresholds() }
    }

    @Published public var isDemoMode: Bool {
        didSet { defaults.set(isDemoMode, forKey: "isDemoMode") }
    }

    @Published public var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    @Published public var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    @Published public var selectedPlan: ClaudePlan {
        didSet { defaults.set(selectedPlan.rawValue, forKey: "selectedPlan") }
    }

    private init() {
        let suite = UserDefaults(suiteName: "group.com.mrdemonwolf.howlalert") ?? .standard
        self.defaults = suite
        self.isDemoMode = suite.bool(forKey: "isDemoMode")
        self.launchAtLogin = suite.bool(forKey: "launchAtLogin")
        self.notificationsEnabled = suite.bool(forKey: "notificationsEnabled")
        self.thresholds = UserPreferences.loadThresholds(from: suite)
        self.selectedPlan = ClaudePlan(rawValue: suite.string(forKey: "selectedPlan") ?? "") ?? .pro
    }

    private static func loadThresholds(from defaults: UserDefaults) -> [AlertThreshold] {
        guard let data = defaults.data(forKey: "thresholds"),
              let thresholds = try? JSONDecoder().decode([AlertThreshold].self, from: data) else {
            return AlertThreshold.defaults
        }
        return thresholds
    }

    private func saveThresholds() {
        guard let data = try? JSONEncoder().encode(thresholds) else { return }
        defaults.set(data, forKey: "thresholds")
    }

    public var dailyCostThreshold: Double {
        thresholds.first(where: { $0.type == .dailyCost && $0.isEnabled })?.value ?? 5.0
    }
}
