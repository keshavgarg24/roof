// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct StartupManagerStrings {
    let pageTitle: String
    let hubDescription: String
    let loginItemsTitle: String
    let loginItemsCaption: String
    let launchAgentsTitle: String
    let launchAgentsCaption: String
    let loadedLabel: String
    let notLoadedLabel: String
    let enableButton: String
    let disableButton: String
    let refreshButton: String
    let noItemsCaption: String
    let bundleIDLabel: String
    let pathLabel: String
    let errorLabel: String
    let loadingLabel: String

    static let enUS = StartupManagerStrings(
        pageTitle: "Startup Manager",
        hubDescription: "See and control what runs when you log in.",
        loginItemsTitle: "Login Items",
        loginItemsCaption: "Apps and helpers that launch automatically when you log in.",
        launchAgentsTitle: "Launch Agents",
        launchAgentsCaption: "User-level background services from ~/Library/LaunchAgents.",
        loadedLabel: "Active",
        notLoadedLabel: "Inactive",
        enableButton: "Enable",
        disableButton: "Disable",
        refreshButton: "Refresh",
        noItemsCaption: "No items found.",
        bundleIDLabel: "Bundle ID",
        pathLabel: "Path",
        errorLabel: "Error",
        loadingLabel: "Loading…"
    )
}

extension FeatureStrings {
    static func startupManager(_ language: AppLanguage) -> StartupManagerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
