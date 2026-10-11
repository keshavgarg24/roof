// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct WindowSessionStrings {
    let pageTitle: String
    let hubDescription: String
    let saveButton: String
    let restoreButton: String
    let deleteButton: String
    let newSessionName: String
    let sessionNameLabel: String
    let appsLabel: String
    let windowsLabel: String
    let saveCurrentButton: String
    let noSessionsCaption: String
    let restoreConfirmation: String
    let accessibilityNeeded: String
    let commandBarSave: String
    let commandBarRestore: String

    static let enUS = WindowSessionStrings(
        pageTitle: "Window Sessions",
        hubDescription: "Save and instantly restore named sets of window positions across all your apps.",
        saveButton: "Save",
        restoreButton: "Restore",
        deleteButton: "Delete",
        newSessionName: "New Session",
        sessionNameLabel: "Name",
        appsLabel: "Apps",
        windowsLabel: "Windows",
        saveCurrentButton: "Save Current Layout",
        noSessionsCaption: "No sessions saved yet.",
        restoreConfirmation: "Restore the \"%@\" window layout?",
        accessibilityNeeded: "Accessibility permission is required to read and restore window positions.",
        commandBarSave: "Save Window Session",
        commandBarRestore: "Restore Window Session"
    )
}

extension FeatureStrings {
    static func windowSession(_ language: AppLanguage) -> WindowSessionStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
