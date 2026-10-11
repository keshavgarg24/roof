// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct QRCodeGeneratorStrings {
    let pageTitle: String
    let hubDescription: String
    let inputLabel: String
    let inputPlaceholder: String
    let generateButton: String
    let copyImageButton: String
    let saveImageButton: String
    let errorCorrectionLabel: String
    let scaleLabel: String
    let savedCaption: String
    let emptyCaption: String
}

extension QRCodeGeneratorStrings {
    static let enUS = QRCodeGeneratorStrings(
        pageTitle: "QR Code Generator",
        hubDescription: "Turn any text, URL, or contact into a scannable QR code — copy or save as PNG.",
        inputLabel: "Content",
        inputPlaceholder: "Enter text or URL…",
        generateButton: "Generate",
        copyImageButton: "Copy Image",
        saveImageButton: "Save PNG…",
        errorCorrectionLabel: "Error Correction",
        scaleLabel: "Size",
        savedCaption: "Saved.",
        emptyCaption: "Enter text above to generate a QR code."
    )
}

extension FeatureStrings {
    static func qrCodeGenerator(_ language: AppLanguage) -> QRCodeGeneratorStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
