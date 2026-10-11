// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

enum AppearanceSchedulerSupport {
    /// Parses an "HH:mm" string into hours and minutes. Returns nil if malformed.
    static func parseTime(_ raw: String) -> (hour: Int, minute: Int)? {
        let parts = raw.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0...23).contains(hour),
              (0...59).contains(minute) else { return nil }
        return (hour, minute)
    }

    /// How many seconds until the next occurrence of (hour, minute) from `now`.
    static func secondsUntil(hour: Int, minute: Int, from now: Date) -> TimeInterval {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        guard let target = calendar.date(from: components) else { return 86_400 }
        let interval = target.timeIntervalSince(now)
        return interval > 0 ? interval : interval + 86_400
    }

    /// Returns which appearance (light/dark) should be active right now given
    /// the two scheduled switch times.
    static func currentAppearance(lightModeTime: String,
                                   darkModeTime: String,
                                   now: Date = Date()) -> AppAppearance {
        guard let light = parseTime(lightModeTime),
              let dark = parseTime(darkModeTime) else { return .system }
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        let nowMinutes = (nowComponents.hour ?? 0) * 60 + (nowComponents.minute ?? 0)
        let lightMinutes = light.hour * 60 + light.minute
        let darkMinutes = dark.hour * 60 + dark.minute

        if lightMinutes < darkMinutes {
            // Light window: [light, dark); dark otherwise
            return (lightMinutes...darkMinutes).contains(nowMinutes) ? .light : .dark
        } else {
            // Dark window starts before midnight (e.g. dark=20:00, light=07:00)
            return (darkMinutes...lightMinutes).contains(nowMinutes) ? .dark : .light
        }
    }

    static func formatTime(hour: Int, minute: Int) -> String {
        String(format: "%02d:%02d", hour, minute)
    }
}
