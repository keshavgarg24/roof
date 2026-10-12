// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct TextTransformerStrings {
    let pageTitle: String
    let hubDescription: String
    let subtitle: String
    let noClipboardText: String
    let resultCopied: String
    let opUppercase: String
    let opLowercase: String
    let opTitleCase: String
    let opCamelCase: String
    let opSnakeCase: String
    let opKebabCase: String
    let opBase64Encode: String
    let opBase64Decode: String
    let opURLEncode: String
    let opURLDecode: String
    let opJSONPrettify: String
    let opJSONMinify: String
    let opGenerateUUID: String
    let opReverse: String
    let opSortLines: String
    let opDeduplicateLines: String
    let opTrimWhitespace: String
    let opWordCount: String
    let opCharCount: String
    let opLineCount: String

    static let enUS = TextTransformerStrings(
        pageTitle: "Text Transformer",
        hubDescription: "Transform clipboard text in the Command Bar, case, encoding, sorting and more.",
        subtitle: "Text Transformer",
        noClipboardText: "No text in clipboard",
        resultCopied: "Result copied",
        opUppercase: "UPPERCASE",
        opLowercase: "lowercase",
        opTitleCase: "Title Case",
        opCamelCase: "camelCase",
        opSnakeCase: "snake_case",
        opKebabCase: "kebab-case",
        opBase64Encode: "Base64 Encode",
        opBase64Decode: "Base64 Decode",
        opURLEncode: "URL Encode",
        opURLDecode: "URL Decode",
        opJSONPrettify: "Prettify JSON",
        opJSONMinify: "Minify JSON",
        opGenerateUUID: "Generate UUID",
        opReverse: "Reverse Text",
        opSortLines: "Sort Lines",
        opDeduplicateLines: "Remove Duplicate Lines",
        opTrimWhitespace: "Trim Whitespace",
        opWordCount: "Word Count",
        opCharCount: "Character Count",
        opLineCount: "Line Count"
    )
}

extension FeatureStrings {
    static func textTransformer(_ language: AppLanguage) -> TextTransformerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
