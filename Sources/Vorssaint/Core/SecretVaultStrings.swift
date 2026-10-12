// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct SecretVaultStrings {
    let pageTitle: String
    let hubDescription: String
    let addSecretButton: String
    let copyButton: String
    let deleteButton: String
    let nameLabel: String
    let valueLabel: String
    let categoryLabel: String
    let searchPlaceholder: String
    let categoryAPIKey: String
    let categoryToken: String
    let categoryCertificate: String
    let categoryPassword: String
    let categoryOther: String
    let noSecretsCaption: String
    let copiedLabel: String
    let editButton: String
    let importEnvButton: String
    let keychainNote: String

    static let enUS = SecretVaultStrings(
        pageTitle: "Secret Vault",
        hubDescription: "Securely store API keys, tokens and credentials in macOS Keychain, never in plain text.",
        addSecretButton: "Add Secret",
        copyButton: "Copy",
        deleteButton: "Delete",
        nameLabel: "Name",
        valueLabel: "Value",
        categoryLabel: "Category",
        searchPlaceholder: "Search secrets…",
        categoryAPIKey: "API Key",
        categoryToken: "Token",
        categoryCertificate: "Certificate",
        categoryPassword: "Password",
        categoryOther: "Other",
        noSecretsCaption: "No secrets stored yet.",
        copiedLabel: "Copied!",
        editButton: "Edit",
        importEnvButton: "Import .env…",
        keychainNote: "All secrets are stored in macOS Keychain."
    )
}

extension FeatureStrings {
    static func secretVault(_ language: AppLanguage) -> SecretVaultStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
