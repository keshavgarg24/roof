// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct HashGeneratorStrings {
    let pageTitle: String
    let hubDescription: String
    let inputLabel: String
    let inputPlaceholder: String
    let pasteButton: String
    let clearButton: String
    let copyButton: String
    let copiedLabel: String
    let hashesTitle: String
    let noInputCaption: String
    let inputModeText: String
    let inputModeFile: String
    let chooseFileButton: String
    let fileLabel: String
    // UI aliases
    var commandBarTitle: String { "Hash Clipboard (SHA-256)" }
    var inputSection: String { inputLabel }
    var inputModeLabel: String { "Input Mode" }
    var computeButton: String { "Compute" }
    var noFileSelected: String { "No file selected" }
    var resultsSection: String { hashesTitle }

    static let enUS = HashGeneratorStrings(
        pageTitle: "Hash Generator",
        hubDescription: "Calculate MD5, SHA-1, SHA-256 and SHA-512 hashes of text or files.",
        inputLabel: "Input",
        inputPlaceholder: "Type or paste text to hash…",
        pasteButton: "Paste",
        clearButton: "Clear",
        copyButton: "Copy",
        copiedLabel: "Copied",
        hashesTitle: "Hashes",
        noInputCaption: "Enter text above to see its hashes.",
        inputModeText: "Text",
        inputModeFile: "File",
        chooseFileButton: "Choose File…",
        fileLabel: "File"
    )
}

extension FeatureStrings {
    static func hashGenerator(_ language: AppLanguage) -> HashGeneratorStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
