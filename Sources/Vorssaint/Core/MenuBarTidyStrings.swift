// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct MenuBarTidyStrings {
    let pageTitle: String
    let hubDescription: String
    let visibleSection: String
    let hiddenSection: String
    let hideButton: String
    let showButton: String
    let refreshButton: String
    let accessibilityNeeded: String
    let noItemsCaption: String
    let alwaysHideLabel: String
    let autoHideLabel: String
    let instructionsCaption: String

    static let enUS = MenuBarTidyStrings(
        pageTitle: "Menu Bar Tidy",
        hubDescription: "Declutter your menu bar, hide, reorder and group icons from any app.",
        visibleSection: "Visible",
        hiddenSection: "Hidden",
        hideButton: "Hide",
        showButton: "Show",
        refreshButton: "Refresh",
        accessibilityNeeded: "Accessibility permission is required to manage menu bar items.",
        noItemsCaption: "No menu bar items detected.",
        alwaysHideLabel: "Always Hide",
        autoHideLabel: "Auto-hide",
        instructionsCaption: "Drag items to reorder. Toggle the switch to hide or show each icon."
    )
}

extension FeatureStrings {
    static func menuBarTidy(_ language: AppLanguage) -> MenuBarTidyStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
