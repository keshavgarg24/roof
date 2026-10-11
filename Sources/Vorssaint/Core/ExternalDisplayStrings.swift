// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct ExternalDisplayStrings {
    let pageTitle: String
    let hubDescription: String
    let brightnessLabel: String
    let volumeLabel: String
    let contrastLabel: String
    let noDisplaysCaption: String
    let builtInLabel: String
    let externalLabel: String
    let syncBrightnessLabel: String
    let syncBrightnessCaption: String
    let ddcNotSupported: String
    let commandBarBrightness: String
    let commandBarVolume: String

    static let enUS = ExternalDisplayStrings(
        pageTitle: "External Display",
        hubDescription: "Control external monitor brightness, volume and contrast using DDC — no extra cables.",
        brightnessLabel: "Brightness",
        volumeLabel: "Volume",
        contrastLabel: "Contrast",
        noDisplaysCaption: "No external displays detected.",
        builtInLabel: "Built-in",
        externalLabel: "External",
        syncBrightnessLabel: "Sync with Built-in",
        syncBrightnessCaption: "Mirrors the built-in display brightness to all external monitors.",
        ddcNotSupported: "This display does not support DDC/CI brightness control.",
        commandBarBrightness: "Set External Display Brightness",
        commandBarVolume: "Set External Display Volume"
    )
}

extension FeatureStrings {
    static func externalDisplay(_ language: AppLanguage) -> ExternalDisplayStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
