// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct GlobalHotkeysStrings {
    let pageTitle: String
    let hubDescription: String
    let addRuleButton: String
    let deleteButton: String
    let enabledLabel: String
    let keyComboLabel: String
    let actionLabel: String
    let hyperKeySection: String
    let hyperKeyEnabled: String
    let hyperKeyCaption: String
    let rulesSection: String
    let actionLaunchApp: String
    let actionOpenURL: String
    let actionRunScript: String
    let actionTypeText: String
    let actionToggleFeature: String
    let recordingHint: String
    let noRulesCaption: String

    static let enUS = GlobalHotkeysStrings(
        pageTitle: "Global Hotkeys",
        hubDescription: "Map any key combination to launch apps, open URLs, run scripts or type text system-wide.",
        addRuleButton: "Add Rule",
        deleteButton: "Delete",
        enabledLabel: "Enabled",
        keyComboLabel: "Shortcut",
        actionLabel: "Action",
        hyperKeySection: "Hyper Key",
        hyperKeyEnabled: "Enable Hyper Key",
        hyperKeyCaption: "CapsLock held = ⌘⌥⌃⇧ (Hyper). Tapped alone = Escape.",
        rulesSection: "Rules",
        actionLaunchApp: "Launch App",
        actionOpenURL: "Open URL",
        actionRunScript: "Run Script",
        actionTypeText: "Type Text",
        actionToggleFeature: "Toggle Feature",
        recordingHint: "Click the shortcut field, then press your key combination.",
        noRulesCaption: "No rules yet. Add one to get started."
    )
}

extension FeatureStrings {
    static func globalHotkeys(_ language: AppLanguage) -> GlobalHotkeysStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
