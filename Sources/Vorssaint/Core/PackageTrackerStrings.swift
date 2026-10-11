// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct PackageTrackerStrings {
    let pageTitle: String
    let hubDescription: String
    let refreshButton: String
    let updateAllButton: String
    let searchPlaceholder: String
    let versionLabel: String
    let latestLabel: String
    let updateAvailableLabel: String
    let upToDateLabel: String
    let categoryHomebrew: String
    let categoryNpm: String
    let categoryPip: String
    let categoryGem: String
    let categoryMas: String
    let noPackagesCaption: String
    let loadingLabel: String
    let commandBarTitle: String

    static let enUS = PackageTrackerStrings(
        pageTitle: "Package Tracker",
        hubDescription: "See all Homebrew, npm, pip and gem packages in one place — with one-click updates.",
        refreshButton: "Refresh",
        updateAllButton: "Update All",
        searchPlaceholder: "Search packages…",
        versionLabel: "Installed",
        latestLabel: "Latest",
        updateAvailableLabel: "Update available",
        upToDateLabel: "Up to date",
        categoryHomebrew: "Homebrew",
        categoryNpm: "npm",
        categoryPip: "pip",
        categoryGem: "gem",
        categoryMas: "Mac App Store",
        noPackagesCaption: "No packages found. Refresh to scan.",
        loadingLabel: "Loading…",
        commandBarTitle: "Check Package Updates"
    )
}

extension FeatureStrings {
    static func packageTracker(_ language: AppLanguage) -> PackageTrackerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
