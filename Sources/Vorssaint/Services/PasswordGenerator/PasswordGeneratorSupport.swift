// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

enum PasswordStrength {
    case weak, fair, strong, veryStrong

    func label(_ s: PasswordGeneratorStrings) -> String {
        switch self {
        case .weak: return s.strengthWeak
        case .fair: return s.strengthFair
        case .strong: return s.strengthStrong
        case .veryStrong: return s.strengthVeryStrong
        }
    }
}

struct PasswordConfig {
    var length: Int = 20
    var useUppercase: Bool = true
    var useLowercase: Bool = true
    var useNumbers: Bool = true
    var useSymbols: Bool = true
    var excludeAmbiguous: Bool = true
}

enum PasswordGeneratorSupport {
    private static let uppercase = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    private static let uppercaseAmbiguous = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private static let lowercase = "abcdefghjkmnpqrstuvwxyz"
    private static let lowercaseAmbiguous = "abcdefghijklmnopqrstuvwxyz"
    private static let numbers = "23456789"
    private static let numbersAmbiguous = "0123456789"
    private static let symbols = "!@#$%^&*()-_=+[]{}|;:,.<>?"

    static func generate(config: PasswordConfig) -> String {
        var pool = ""
        if config.useUppercase {
            pool += config.excludeAmbiguous ? uppercase : uppercaseAmbiguous
        }
        if config.useLowercase {
            pool += config.excludeAmbiguous ? lowercase : lowercaseAmbiguous
        }
        if config.useNumbers {
            pool += config.excludeAmbiguous ? numbers : numbersAmbiguous
        }
        if config.useSymbols {
            pool += symbols
        }
        guard !pool.isEmpty else { return "" }
        let chars = Array(pool)
        var rng = SystemRandomNumberGenerator()
        var password = ""
        // Guarantee at least one character from each enabled class
        var guaranteed: [Character] = []
        if config.useUppercase {
            let src = config.excludeAmbiguous ? uppercase : uppercaseAmbiguous
            guaranteed.append(Array(src).randomElement(using: &rng)!)
        }
        if config.useLowercase {
            let src = config.excludeAmbiguous ? lowercase : lowercaseAmbiguous
            guaranteed.append(Array(src).randomElement(using: &rng)!)
        }
        if config.useNumbers {
            let src = config.excludeAmbiguous ? numbers : numbersAmbiguous
            guaranteed.append(Array(src).randomElement(using: &rng)!)
        }
        if config.useSymbols {
            guaranteed.append(Array(symbols).randomElement(using: &rng)!)
        }
        for _ in 0..<max(0, config.length - guaranteed.count) {
            password.append(chars.randomElement(using: &rng)!)
        }
        password += String(guaranteed)
        return String(password.shuffled(using: &rng))
    }

    static func strength(of password: String, config: PasswordConfig) -> PasswordStrength {
        let poolSize = poolSize(config: config)
        let entropy = Double(password.count) * log2(Double(max(poolSize, 2)))
        switch entropy {
        case ..<40: return .weak
        case 40..<72: return .fair
        case 72..<100: return .strong
        default: return .veryStrong
        }
    }

    private static func poolSize(config: PasswordConfig) -> Int {
        var size = 0
        if config.useUppercase { size += config.excludeAmbiguous ? 23 : 26 }
        if config.useLowercase { size += config.excludeAmbiguous ? 23 : 26 }
        if config.useNumbers   { size += config.excludeAmbiguous ? 8 : 10 }
        if config.useSymbols   { size += symbols.count }
        return size
    }
}
