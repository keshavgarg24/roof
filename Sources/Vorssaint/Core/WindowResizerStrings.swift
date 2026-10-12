// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct WindowResizerStrings {
    let pageTitle: String
    let hubDescription: String
    let subtitle: String
    let presetsTitle: String
    let presetsCaption: String
    let customTitle: String
    let widthLabel: String
    let heightLabel: String
    let addPresetButton: String
    let removeButton: String
    let presetNamePlaceholder: String
    let applyButton: String
    let noFocusedWindow: String
    let resizedMessage: String
    let accessibilityNote: String

    static let enUS = WindowResizerStrings(
        pageTitle: "Window Resizer",
        hubDescription: "Set any window to exact pixel dimensions, great for testing responsive designs.",
        subtitle: "Window Resizer",
        presetsTitle: "Presets",
        presetsCaption: "Click any preset in the Command Bar to resize the focused window instantly.",
        customTitle: "Custom Preset",
        widthLabel: "Width",
        heightLabel: "Height",
        addPresetButton: "Add Preset",
        removeButton: "Remove",
        presetNamePlaceholder: "Preset name (e.g. iPhone 15)",
        applyButton: "Apply to Focused Window",
        noFocusedWindow: "No focused window",
        resizedMessage: "Window resized",
        accessibilityNote: "Requires Accessibility permission to resize windows."
    )
}

extension FeatureStrings {
    static func windowResizer(_ language: AppLanguage) -> WindowResizerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
