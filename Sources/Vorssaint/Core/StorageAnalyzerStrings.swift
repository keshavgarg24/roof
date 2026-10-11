// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct StorageAnalyzerStrings {
    let pageTitle: String
    let hubDescription: String
    let scanButton: String
    let scanningLabel: String
    let totalLabel: String
    let usedLabel: String
    let freeLabel: String
    let categoryApps: String
    let categoryCaches: String
    let categoryDocuments: String
    let categoryMedia: String
    let categoryDownloads: String
    let categoryDeveloper: String
    let categorySystem: String
    let categoryOther: String
    let largestFilesTitle: String
    let recommendationsTitle: String
    let openInFinderButton: String
    let noDataCaption: String

    static let enUS = StorageAnalyzerStrings(
        pageTitle: "Storage Analyzer",
        hubDescription: "Visualize what’s eating your disk — by app, cache, media, downloads and developer junk.",
        scanButton: "Scan Now",
        scanningLabel: "Scanning…",
        totalLabel: "Total",
        usedLabel: "Used",
        freeLabel: "Free",
        categoryApps: "Applications",
        categoryCaches: "Caches",
        categoryDocuments: "Documents",
        categoryMedia: "Media",
        categoryDownloads: "Downloads",
        categoryDeveloper: "Developer",
        categorySystem: "System",
        categoryOther: "Other",
        largestFilesTitle: "Largest Items",
        recommendationsTitle: "Recommendations",
        openInFinderButton: "Show in Finder",
        noDataCaption: "Press Scan to analyze your storage."
    )
}

extension FeatureStrings {
    static func storageAnalyzer(_ language: AppLanguage) -> StorageAnalyzerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
