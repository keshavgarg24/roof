// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct PasswordGeneratorSettings: View {
    @ObservedObject private var service = PasswordGeneratorService.shared
    @ObservedObject private var l10n = L10n.shared

    private var s: PasswordGeneratorStrings { FeatureStrings.passwordGenerator(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(service.lastPassword.isEmpty ? s.noPasswordYet : service.lastPassword)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(service.lastPassword.isEmpty ? .secondary : .primary)
                        .textSelection(.enabled)
                        .lineLimit(2)
                    Spacer()
                    Button(s.generateButton) {
                        service.generate()
                    }
                    .buttonStyle(.borderedProminent)
                    Button(s.copyButton) {
                        service.copyToClipboard()
                    }
                    .disabled(service.lastPassword.isEmpty)
                }
                if !service.lastPassword.isEmpty {
                    HStack {
                        Text(s.strengthLabel)
                            .foregroundStyle(.secondary)
                        Text(strengthText)
                            .foregroundStyle(strengthColor)
                            .fontWeight(.medium)
                    }
                }
            } header: {
                Text(s.passwordSection)
            }

            Section {
                Stepper(value: $service.config.length, in: 4...128) {
                    HStack {
                        Text(s.lengthLabel)
                        Spacer()
                        Text("\(service.config.length)")
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: service.config.length) { service.saveConfig() }

                Toggle(s.uppercaseLabel, isOn: $service.config.useUppercase)
                    .onChange(of: service.config.useUppercase) { service.saveConfig() }
                Toggle(s.lowercaseLabel, isOn: $service.config.useLowercase)
                    .onChange(of: service.config.useLowercase) { service.saveConfig() }
                Toggle(s.numbersLabel, isOn: $service.config.useNumbers)
                    .onChange(of: service.config.useNumbers) { service.saveConfig() }
                Toggle(s.symbolsLabel, isOn: $service.config.useSymbols)
                    .onChange(of: service.config.useSymbols) { service.saveConfig() }
                Toggle(s.excludeAmbiguousLabel, isOn: $service.config.excludeAmbiguous)
                    .onChange(of: service.config.excludeAmbiguous) { service.saveConfig() }
            } header: {
                Text(s.configSection)
            }
        }
        .formStyle(.grouped)
    }

    private var strengthText: String {
        switch service.strength {
        case .weak:      return s.strengthWeak
        case .fair:      return s.strengthFair
        case .strong:    return s.strengthStrong
        case .veryStrong: return s.strengthVeryStrong
        }
    }

    private var strengthColor: Color {
        switch service.strength {
        case .weak:      return .red
        case .fair:      return .orange
        case .strong:    return .green
        case .veryStrong: return .blue
        }
    }
}
