// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct AppTimerStrings {
    let pageTitle: String
    let hubDescription: String
    let addLimitButton: String
    let deleteLimitButton: String
    let appLabel: String
    let dailyLimitLabel: String
    let usedTodayLabel: String
    let noLimitsCaption: String
    let limitReachedTitle: String
    let limitReachedBody: String
    let minutesSuffix: String
    let resetDailyLabel: String
    let enabledLabel: String
}

extension AppTimerStrings {
    static let enUS = AppTimerStrings(
        pageTitle: "App Timer",
        hubDescription: "Set daily usage limits for any app — get notified when you've hit the limit.",
        addLimitButton: "Add Limit",
        deleteLimitButton: "Remove",
        appLabel: "App",
        dailyLimitLabel: "Daily Limit (min)",
        usedTodayLabel: "Used today",
        noLimitsCaption: "No app limits configured yet.",
        limitReachedTitle: "Time Limit Reached",
        limitReachedBody: "You've hit your daily limit for %@.",
        minutesSuffix: "min",
        resetDailyLabel: "Limits reset at midnight",
        enabledLabel: "Enable App Timer"
    )
}

extension FeatureStrings {
    static func appTimer(_ language: AppLanguage) -> AppTimerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
