// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct AppearanceSchedulerStrings {
    let pageTitle: String
    let hubDescription: String
    let enableToggle: String
    let enableCaption: String
    let scheduleTitle: String
    let lightModeTimeLabel: String
    let darkModeTimeLabel: String
    let lightModeCaption: String
    let darkModeCaption: String
    let nextSwitchLabel: String
    let currentModeLabel: String
    let lightModeTitle: String
    let darkModeTitle: String
    let systemModeTitle: String
    let switchNowButton: String

    static let enUS = AppearanceSchedulerStrings(
        pageTitle: "Appearance Scheduler",
        hubDescription: "Switch between light and dark mode on a schedule you set.",
        enableToggle: "Enable Appearance Scheduler",
        enableCaption: "Automatically switch macOS appearance at the times you choose.",
        scheduleTitle: "Schedule",
        lightModeTimeLabel: "Switch to Light Mode at",
        darkModeTimeLabel: "Switch to Dark Mode at",
        lightModeCaption: "The Mac will switch to Light Mode at this time each day.",
        darkModeCaption: "The Mac will switch to Dark Mode at this time each day.",
        nextSwitchLabel: "Next switch",
        currentModeLabel: "Current",
        lightModeTitle: "Light",
        darkModeTitle: "Dark",
        systemModeTitle: "System",
        switchNowButton: "Switch Now"
    )
}

extension FeatureStrings {
    static func appearanceScheduler(_ language: AppLanguage) -> AppearanceSchedulerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
