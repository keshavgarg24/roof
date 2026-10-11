// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct DiffViewerStrings {
    let pageTitle: String
    let hubDescription: String
    let originalLabel: String
    let modifiedLabel: String
    let originalPlaceholder: String
    let modifiedPlaceholder: String
    let compareButton: String
    let clearButton: String
    let pasteOriginalButton: String
    let pasteModifiedButton: String
    let resultTitle: String
    let noChanges: String
    let addedLabel: String
    let removedLabel: String
    let changedLabel: String
    let statsFormat: String
    // UI aliases
    var inputSection: String { "Input" }
    var diffSection: String { resultTitle }

    static let enUS = DiffViewerStrings(
        pageTitle: "Diff Viewer",
        hubDescription: "Compare two pieces of text line-by-line and see exactly what changed.",
        originalLabel: "Original",
        modifiedLabel: "Modified",
        originalPlaceholder: "Paste the original text here…",
        modifiedPlaceholder: "Paste the modified text here…",
        compareButton: "Compare",
        clearButton: "Clear",
        pasteOriginalButton: "Paste",
        pasteModifiedButton: "Paste",
        resultTitle: "Differences",
        noChanges: "No differences found.",
        addedLabel: "Added",
        removedLabel: "Removed",
        changedLabel: "Changed",
        statsFormat: "%d added · %d removed"
    )
}

extension FeatureStrings {
    static func diffViewer(_ language: AppLanguage) -> DiffViewerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
