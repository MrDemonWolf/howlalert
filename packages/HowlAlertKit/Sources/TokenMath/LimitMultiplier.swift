import Foundation

public func effectiveMultiplier(at date: Date, config: RemoteConfig) -> Double {
	guard config.multiplier != 1.0 else {
		return 1.0
	}

	// Check if promotion is active (has date range)
	if let activeFrom = config.activeFrom, let activeUntil = config.activeUntil {
		guard date >= activeFrom && date <= activeUntil else {
			return 1.0
		}
	}

	// If not off-peak only, the multiplier applies at all times
	guard config.offPeakOnly else {
		return config.multiplier
	}

	// Off-peak logic
	var calendar = Calendar(identifier: .gregorian)
	calendar.timeZone = TimeZone(identifier: "UTC")!

	let weekday = calendar.component(.weekday, from: date)
	let isWeekend = weekday == 1 || weekday == 7

	if isWeekend {
		// Check weekend config
		if let windows = config.offPeakWindows, let weekend = windows.weekend {
			if weekend == "all" {
				return config.multiplier
			}
		}
		return 1.0
	}

	// Weekday — check off-peak windows
	guard let windows = config.offPeakWindows, let weekdayWindows = windows.weekday else {
		return 1.0
	}

	let hour = calendar.component(.hour, from: date)
	for window in weekdayWindows {
		if hour >= window.startUTC && hour < window.endUTC {
			return config.multiplier
		}
	}

	return 1.0
}
