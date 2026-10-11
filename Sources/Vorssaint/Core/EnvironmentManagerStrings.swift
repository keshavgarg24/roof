// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct EnvironmentManagerStrings {
    let pageTitle: String
    let hubDescription: String
    let shellEnvSection: String
    let envFilesSection: String
    let searchPlaceholder: String
    let copyValueButton: String
    let openFileButton: String
    let refreshButton: String
    let scanForEnvButton: String
    let keyLabel: String
    let valueLabel: String
    let sourceLabel: String
    let noEnvFilesCaption: String
    let addPathButton: String
    let exportButton: String

    static let enUS = EnvironmentManagerStrings(
        pageTitle: "Environment Manager",
        hubDescription: "Browse all shell environment variables and .env files across your projects in one place.",
        shellEnvSection: "Shell Environment",
        envFilesSection: ".env Files",
        searchPlaceholder: "Search variables…",
        copyValueButton: "Copy Value",
        openFileButton: "Open File",
        refreshButton: "Refresh",
        scanForEnvButton: "Scan for .env Files",
        keyLabel: "Variable",
        valueLabel: "Value",
        sourceLabel: "Source",
        noEnvFilesCaption: "No .env files found. Add a path to scan.",
        addPathButton: "Add Scan Path…",
        exportButton: "Export"
    )
}

extension FeatureStrings {
    static func environmentManager(_ language: AppLanguage) -> EnvironmentManagerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
