// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct WorldClockStrings {
    let pageTitle: String
    let hubDescription: String
    let addTimezoneButton: String
    let removeButton: String
    let copyButton: String
    let copiedLabel: String
    let searchPlaceholder: String
    let noZonesCaption: String
    let yourTimeLabel: String
    let offsetLabel: String
    let refreshButton: String
    let configTitle: String
    // UI aliases
    var clocksSection: String { configTitle }
    var addButton: String { addTimezoneButton }
    var noClocks: String { noZonesCaption }
    var customLabelPlaceholder: String { "Label (optional)" }
    var cancelButton: String { "Cancel" }

    static let enUS = WorldClockStrings(
        pageTitle: "World Clock",
        hubDescription: "See the current time across your favourite time zones at a glance.",
        addTimezoneButton: "Add Time Zone",
        removeButton: "Remove",
        copyButton: "Copy",
        copiedLabel: "Copied",
        searchPlaceholder: "Search time zones…",
        noZonesCaption: "No time zones added. Add one below.",
        yourTimeLabel: "Your Time",
        offsetLabel: "Offset",
        refreshButton: "Refresh",
        configTitle: "Time Zones"
    )
}

extension FeatureStrings {
    static func worldClock(_ language: AppLanguage) -> WorldClockStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
