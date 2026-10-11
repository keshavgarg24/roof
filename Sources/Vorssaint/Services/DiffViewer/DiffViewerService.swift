// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit
import Foundation

final class DiffViewerService: ObservableObject {
    static let shared = DiffViewerService()

    @Published var originalText = ""
    @Published var modifiedText = ""
    @Published private(set) var diffLines: [DiffLine] = []

    private init() {}

    func syncWithPreferences() {}

    func compute() {
        diffLines = DiffViewerSupport.diff(original: originalText, modified: modifiedText)
    }

    var addedCount: Int { DiffViewerSupport.addedCount(diffLines) }
    var removedCount: Int { DiffViewerSupport.removedCount(diffLines) }

    func pasteOriginalFromClipboard() {
        GeneralPasteboardAccess.shared.async({
            NSPasteboard.general.string(forType: .string) ?? ""
        }, then: { [weak self] text in
            self?.originalText = text
            self?.compute()
        })
    }

    func clear() {
        originalText = ""
        modifiedText = ""
        diffLines = []
    }
}
