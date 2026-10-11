// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct DeveloperCleanerStrings {
    let pageTitle: String
    let hubDescription: String
    let scanButton: String
    let deleteSelectedButton: String
    let selectAllButton: String
    let deselectAllButton: String
    let scanningLabel: String
    let deletingLabel: String
    let totalReclaimable: String
    let categoryXcode: String
    let categoryNode: String
    let categoryDocker: String
    let categoryPython: String
    let categoryRuby: String
    let categoryGo: String
    let categoryGit: String
    let noJunkFound: String
    let deleteWarning: String
    let commandBarTitle: String

    static let enUS = DeveloperCleanerStrings(
        pageTitle: "Developer Cleaner",
        hubDescription: "Reclaim gigabytes from Xcode, npm, Docker, pip and other developer tool caches.",
        scanButton: "Scan",
        deleteSelectedButton: "Delete Selected",
        selectAllButton: "Select All",
        deselectAllButton: "Deselect All",
        scanningLabel: "Scanning…",
        deletingLabel: "Deleting…",
        totalReclaimable: "Total Reclaimable",
        categoryXcode: "Xcode",
        categoryNode: "Node.js",
        categoryDocker: "Docker",
        categoryPython: "Python",
        categoryRuby: "Ruby",
        categoryGo: "Go",
        categoryGit: "Git",
        noJunkFound: "No developer junk found.",
        deleteWarning: "Selected items will be permanently deleted.",
        commandBarTitle: "Scan Developer Junk"
    )
}

extension FeatureStrings {
    static func developerCleaner(_ language: AppLanguage) -> DeveloperCleanerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
