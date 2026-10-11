// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct JSONFormatterStrings {
    let pageTitle: String
    let hubDescription: String
    let inputLabel: String
    let inputPlaceholder: String
    let formatButton: String
    let minifyButton: String
    let copyButton: String
    let clearButton: String
    let pasteButton: String
    let validBadge: String
    let invalidBadge: String
    let emptyCaption: String
    let sortKeysLabel: String
}

extension JSONFormatterStrings {
    static let enUS = JSONFormatterStrings(
        pageTitle: "JSON Formatter",
        hubDescription: "Format, minify, and validate JSON — paste from clipboard or type directly.",
        inputLabel: "JSON Input",
        inputPlaceholder: "Paste JSON here…",
        formatButton: "Format",
        minifyButton: "Minify",
        copyButton: "Copy",
        clearButton: "Clear",
        pasteButton: "Paste",
        validBadge: "Valid JSON",
        invalidBadge: "Invalid JSON",
        emptyCaption: "Paste or type JSON above.",
        sortKeysLabel: "Sort keys"
    )
}

extension FeatureStrings {
    static func jsonFormatter(_ language: AppLanguage) -> JSONFormatterStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
