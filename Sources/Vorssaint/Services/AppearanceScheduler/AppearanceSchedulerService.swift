// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit

/// Switches the app appearance (light/dark) on a daily schedule.
final class AppearanceSchedulerService: ObservableObject {
    static let shared = AppearanceSchedulerService()

    private var timer: Timer?

    private init() {}

    func syncWithPreferences() {
        let enabled = AppFeature.appearanceScheduler.isAvailable
            && UserDefaults.standard.bool(forKey: DefaultsKey.appearanceSchedulerEnabled)
        if enabled {
            applyNow()
            scheduleNext()
        } else {
            stop()
        }
    }

    func applyNow() {
        let defaults = UserDefaults.standard
        let light = defaults.string(forKey: DefaultsKey.appearanceSchedulerLightModeTime) ?? "07:00"
        let dark = defaults.string(forKey: DefaultsKey.appearanceSchedulerDarkModeTime) ?? "20:00"
        let target = AppearanceSchedulerSupport.currentAppearance(lightModeTime: light,
                                                                   darkModeTime: dark)
        DispatchQueue.main.async {
            AppAppearanceController.shared.appearance = target
        }
    }

    private func scheduleNext() {
        timer?.invalidate()
        let defaults = UserDefaults.standard
        let lightRaw = defaults.string(forKey: DefaultsKey.appearanceSchedulerLightModeTime) ?? "07:00"
        let darkRaw = defaults.string(forKey: DefaultsKey.appearanceSchedulerDarkModeTime) ?? "20:00"
        guard let light = AppearanceSchedulerSupport.parseTime(lightRaw),
              let dark = AppearanceSchedulerSupport.parseTime(darkRaw) else { return }
        let now = Date()
        let untilLight = AppearanceSchedulerSupport.secondsUntil(hour: light.hour,
                                                                  minute: light.minute,
                                                                  from: now)
        let untilDark = AppearanceSchedulerSupport.secondsUntil(hour: dark.hour,
                                                                 minute: dark.minute,
                                                                 from: now)
        let nextInterval = min(untilLight, untilDark)
        timer = Timer.scheduledTimer(withTimeInterval: nextInterval, repeats: false) { [weak self] _ in
            self?.applyNow()
            self?.scheduleNext()
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }
}
