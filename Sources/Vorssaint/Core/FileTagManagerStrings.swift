// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct FileTagManagerStrings {
    let pageTitle: String
    let hubDescription: String
    let addTagButton: String
    let deleteTagButton: String
    let tagFilesButton: String
    let removeTagButton: String
    let searchByTagLabel: String
    let tagsSection: String
    let autoRulesSection: String
    let addRuleButton: String
    let noTagsCaption: String
    let openInFinderButton: String
    let ruleConditionLabel: String
    let ruleTagLabel: String
    let ruleOlderThan: String
    let ruleInFolder: String
    let ruleExtension: String

    static let enUS = FileTagManagerStrings(
        pageTitle: "File Tag Manager",
        hubDescription: "Manage Finder tags across files and folders, with auto-tag rules for Downloads and more.",
        addTagButton: "New Tag",
        deleteTagButton: "Delete Tag",
        tagFilesButton: "Tag Files…",
        removeTagButton: "Remove Tag",
        searchByTagLabel: "Search by tag",
        tagsSection: "Tags",
        autoRulesSection: "Auto-Tag Rules",
        addRuleButton: "Add Rule",
        noTagsCaption: "No custom tags yet.",
        openInFinderButton: "Show in Finder",
        ruleConditionLabel: "When",
        ruleTagLabel: "Apply Tag",
        ruleOlderThan: "File is older than",
        ruleInFolder: "File is in folder",
        ruleExtension: "File has extension"
    )
}

extension FeatureStrings {
    static func fileTagManager(_ language: AppLanguage) -> FileTagManagerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
