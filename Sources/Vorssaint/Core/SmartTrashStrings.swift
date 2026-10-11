// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct SmartTrashStrings {
    let pageTitle: String
    let hubDescription: String
    let trashSection: String
    let snapshotSection: String
    let restoreButton: String
    let emptyTrashButton: String
    let openInFinderButton: String
    let noTrashItems: String
    let noSnapshots: String
    let snapshotDate: String
    let trashSizeLabel: String
    let itemsCountLabel: String
    let recoveryNote: String
    let restoreConfirmation: String
    let emptyConfirmation: String

    static let enUS = SmartTrashStrings(
        pageTitle: "Smart Trash",
        hubDescription: "Manage your Trash intelligently and recover files from APFS snapshots.",
        trashSection: "Trash Contents",
        snapshotSection: "APFS Snapshots",
        restoreButton: "Restore",
        emptyTrashButton: "Empty Trash",
        openInFinderButton: "Show in Finder",
        noTrashItems: "Trash is empty.",
        noSnapshots: "No APFS snapshots available. Enable Time Machine to create snapshots.",
        snapshotDate: "Snapshot",
        trashSizeLabel: "Trash size",
        itemsCountLabel: "items",
        recoveryNote: "Files deleted before the snapshot was taken can be recovered from it.",
        restoreConfirmation: "Restore \"%@\" to its original location?",
        emptyConfirmation: "Permanently delete all items in the Trash?"
    )
}

extension FeatureStrings {
    static func smartTrash(_ language: AppLanguage) -> SmartTrashStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
