// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct ColorConverterStrings {
    let pageTitle: String
    let hubDescription: String
    let inputLabel: String
    let inputPlaceholder: String
    let pasteButton: String
    let clearButton: String
    let copyButton: String
    let copiedLabel: String
    let hexLabel: String
    let rgbLabel: String
    let hslLabel: String
    let hsbLabel: String
    let swiftUILabel: String
    let cssRGBALabel: String
    let noInputCaption: String
    let invalidColorCaption: String
    let previewLabel: String
    // UI aliases
    var colorSection: String { "Color" }
    var formatsSection: String { "Formats" }
    var codeSection: String { "Code" }

    static let enUS = ColorConverterStrings(
        pageTitle: "Color Converter",
        hubDescription: "Convert colors between HEX, RGB, HSL, HSB and more — paste any format.",
        inputLabel: "Color",
        inputPlaceholder: "Paste a color (#FF5733, rgb(255,87,51), hsl(11,100%,60%)…)",
        pasteButton: "Paste",
        clearButton: "Clear",
        copyButton: "Copy",
        copiedLabel: "Copied",
        hexLabel: "HEX",
        rgbLabel: "RGB",
        hslLabel: "HSL",
        hsbLabel: "HSB",
        swiftUILabel: "SwiftUI",
        cssRGBALabel: "CSS rgba()",
        noInputCaption: "Paste a color value above to convert it.",
        invalidColorCaption: "Could not parse as a color.",
        previewLabel: "Preview"
    )
}

extension FeatureStrings {
    static func colorConverter(_ language: AppLanguage) -> ColorConverterStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
