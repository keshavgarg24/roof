// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct AppRelauncherStrings {
    let pageTitle: String
    let hubDescription: String
    let relaunchButton: String
    let relaunchFrontmostButton: String
    let clearPrefsToggle: String
    let clearPrefsCaption: String
    let runningAppsTitle: String
    let runningAppsCaption: String
    let relaunchingLabel: String
    let relaunchedLabel: String
    let noRunningApps: String
    let frontmostLabel: String
    let confirmClearPrefs: String

    static let enUS = AppRelauncherStrings(
        pageTitle: "App Relauncher",
        hubDescription: "Kill and instantly relaunch any running app, optionally resetting its preferences.",
        relaunchButton: "Relaunch",
        relaunchFrontmostButton: "Relaunch Frontmost App",
        clearPrefsToggle: "Reset preferences on relaunch",
        clearPrefsCaption: "Deletes the app’s UserDefaults plist before relaunching.",
        runningAppsTitle: "Running Apps",
        runningAppsCaption: "Tap Relaunch to quit and immediately restart an app.",
        relaunchingLabel: "Relaunching…",
        relaunchedLabel: "Relaunched",
        noRunningApps: "No apps running.",
        frontmostLabel: "Frontmost",
        confirmClearPrefs: "This will delete the app’s saved preferences. Continue?"
    )
}

extension FeatureStrings {
    static func appRelauncher(_ language: AppLanguage) -> AppRelauncherStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
