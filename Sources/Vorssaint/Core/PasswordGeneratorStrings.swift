// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct PasswordGeneratorStrings {
    let pageTitle: String
    let hubDescription: String
    let generateButton: String
    let copyButton: String
    let copiedLabel: String
    let lengthLabel: String
    let uppercaseToggle: String
    let lowercaseToggle: String
    let numbersToggle: String
    let symbolsToggle: String
    let excludeAmbiguousToggle: String
    let excludeAmbiguousCaption: String
    let strengthLabel: String
    let strengthWeak: String
    let strengthFair: String
    let strengthStrong: String
    let strengthVeryStrong: String
    let configTitle: String
    let noPassword: String
    let commandBarTitle: String
    // UI section/field aliases
    var passwordSection: String { pageTitle }
    var configSection: String { configTitle }
    var noPasswordYet: String { noPassword }
    var uppercaseLabel: String { uppercaseToggle }
    var lowercaseLabel: String { lowercaseToggle }
    var numbersLabel: String { numbersToggle }
    var symbolsLabel: String { symbolsToggle }
    var excludeAmbiguousLabel: String { excludeAmbiguousToggle }

    static let enUS = PasswordGeneratorStrings(
        pageTitle: "Password Generator",
        hubDescription: "Generate strong, random passwords instantly from the Command Bar.",
        generateButton: "Generate",
        copyButton: "Copy",
        copiedLabel: "Copied!",
        lengthLabel: "Length",
        uppercaseToggle: "Uppercase (A–Z)",
        lowercaseToggle: "Lowercase (a–z)",
        numbersToggle: "Numbers (0–9)",
        symbolsToggle: "Symbols (!@#…)",
        excludeAmbiguousToggle: "Exclude ambiguous characters",
        excludeAmbiguousCaption: "Removes characters like 0, O, l, 1, I that look alike.",
        strengthLabel: "Strength",
        strengthWeak: "Weak",
        strengthFair: "Fair",
        strengthStrong: "Strong",
        strengthVeryStrong: "Very Strong",
        configTitle: "Options",
        noPassword: "Press Generate to create a password.",
        commandBarTitle: "Generate Password"
    )
}

extension FeatureStrings {
    static func passwordGenerator(_ language: AppLanguage) -> PasswordGeneratorStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
