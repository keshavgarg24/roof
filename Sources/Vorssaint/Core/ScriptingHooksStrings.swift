// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct ScriptingHooksStrings {
    let pageTitle: String
    let hubDescription: String
    let enableToggle: String
    let enableCaption: String
    let hooksTitle: String
    let hooksCaption: String
    let addHookTitle: String
    let hookNamePlaceholder: String
    let hookScriptPlaceholder: String
    let addButton: String
    let removeButton: String
    let noHooksCaption: String
    let eventLabel: String
    let scriptLabel: String
    let nameLabel: String
    let eventWake: String
    let eventSleep: String
    let eventDisplayConnect: String
    let eventDisplayDisconnect: String
    let eventPowerConnect: String
    let eventPowerDisconnect: String
    let eventAppLaunch: String
    let eventAppQuit: String
    let testButton: String
    let scriptTypeShell: String
    let scriptTypeAppleScript: String
    let scriptTypeLabel: String

    static let enUS = ScriptingHooksStrings(
        pageTitle: "Scripting Hooks",
        hubDescription: "Run shell scripts or AppleScript automatically on system events.",
        enableToggle: "Enable Scripting Hooks",
        enableCaption: "Automatically run scripts when the selected system events occur.",
        hooksTitle: "Hooks",
        hooksCaption: "Each hook runs its script when the chosen event fires.",
        addHookTitle: "Add Hook",
        hookNamePlaceholder: "Hook name",
        hookScriptPlaceholder: "Script to run",
        addButton: "Add",
        removeButton: "Remove",
        noHooksCaption: "No hooks configured. Add one above.",
        eventLabel: "Event",
        scriptLabel: "Script",
        nameLabel: "Name",
        eventWake: "Wake from Sleep",
        eventSleep: "Going to Sleep",
        eventDisplayConnect: "Display Connected",
        eventDisplayDisconnect: "Display Disconnected",
        eventPowerConnect: "Power Connected",
        eventPowerDisconnect: "Power Disconnected",
        eventAppLaunch: "App Launch",
        eventAppQuit: "App Quit",
        testButton: "Test",
        scriptTypeShell: "Shell",
        scriptTypeAppleScript: "AppleScript",
        scriptTypeLabel: "Type"
    )
}

extension FeatureStrings {
    static func scriptingHooks(_ language: AppLanguage) -> ScriptingHooksStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
