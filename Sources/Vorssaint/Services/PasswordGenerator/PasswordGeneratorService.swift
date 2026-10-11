// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit

final class PasswordGeneratorService: ObservableObject {
    static let shared = PasswordGeneratorService()

    @Published private(set) var lastPassword = ""
    @Published var config = PasswordConfig()

    private init() {
        loadConfig()
    }

    func syncWithPreferences() {
        loadConfig()
    }

    func generate() {
        lastPassword = PasswordGeneratorSupport.generate(config: config)
    }

    func generateAndCopy() {
        generate()
        copyToClipboard()
    }

    func copyToClipboard() {
        guard !lastPassword.isEmpty else { return }
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(lastPassword, forType: .string)
    }

    var strength: PasswordStrength {
        PasswordGeneratorSupport.strength(of: lastPassword, config: config)
    }

    func saveConfig() {
        let defaults = UserDefaults.standard
        defaults.set(config.length, forKey: DefaultsKey.passwordGenLength)
        defaults.set(config.useUppercase, forKey: DefaultsKey.passwordGenUppercase)
        defaults.set(config.useLowercase, forKey: DefaultsKey.passwordGenLowercase)
        defaults.set(config.useNumbers, forKey: DefaultsKey.passwordGenNumbers)
        defaults.set(config.useSymbols, forKey: DefaultsKey.passwordGenSymbols)
        defaults.set(config.excludeAmbiguous, forKey: DefaultsKey.passwordGenExcludeAmbiguous)
    }

    private func loadConfig() {
        let defaults = UserDefaults.standard
        config.length = defaults.integer(forKey: DefaultsKey.passwordGenLength).nonZero(fallback: 20)
        config.useUppercase = defaults.bool(forKey: DefaultsKey.passwordGenUppercase)
        config.useLowercase = defaults.bool(forKey: DefaultsKey.passwordGenLowercase)
        config.useNumbers = defaults.bool(forKey: DefaultsKey.passwordGenNumbers)
        config.useSymbols = defaults.bool(forKey: DefaultsKey.passwordGenSymbols)
        config.excludeAmbiguous = defaults.bool(forKey: DefaultsKey.passwordGenExcludeAmbiguous)
    }
}

private extension Int {
    func nonZero(fallback: Int) -> Int { self <= 0 ? fallback : self }
}
