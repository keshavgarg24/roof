// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct SecretVaultSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = SecretVaultService.shared
    @State private var showAdd = false
    @State private var revealedID: String?
    @State private var revealedValue = ""
    @State private var selectedCategory: SecretCategory = .apiKey

    private var s: SecretVaultStrings { FeatureStrings.secretVault(l10n.language) }

    var body: some View {
        Form {
            Section(s.pageTitle) {
                Picker(s.categoryLabel, selection: $selectedCategory) {
                    ForEach(SecretCategory.allCases) { cat in
                        Text(categoryLabel(cat)).tag(cat)
                    }
                }
                .pickerStyle(.segmented)

                let filtered = svc.secrets.filter { $0.category == selectedCategory }
                if filtered.isEmpty {
                    Text(s.noSecretsCaption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                } else {
                    ForEach(filtered) { secret in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(secret.name)
                                if !secret.notes.isEmpty {
                                    Text(secret.notes).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button(revealedID == secret.id ? s.copiedLabel : s.copyButton) {
                                if revealedID == secret.id {
                                    revealedID = nil; revealedValue = ""
                                } else {
                                    revealedID = secret.id
                                    revealedValue = svc.readValue(for: secret) ?? ""
                                }
                            }
                            .buttonStyle(.borderless)
                            Button(s.deleteButton, role: .destructive) { svc.delete(secret) }
                                .buttonStyle(.borderless).foregroundStyle(.red)
                        }
                        if revealedID == secret.id {
                            HStack {
                                Text(revealedValue).font(.caption.monospaced())
                                    .textSelection(.enabled)
                                Spacer()
                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(revealedValue, forType: .string)
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }

            Section {
                Button(s.addSecretButton) { showAdd = true }
                Text(s.keychainNote).font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear { svc.reload() }
        .sheet(isPresented: $showAdd) {
            AddSecretSheet(isPresented: $showAdd, s: s, svc: svc)
        }
    }

    private func categoryLabel(_ cat: SecretCategory) -> String {
        switch cat {
        case .apiKey: return s.categoryAPIKey
        case .token: return s.categoryToken
        case .certificate: return s.categoryCertificate
        case .password: return s.categoryPassword
        case .other: return s.categoryOther
        }
    }
}

private struct AddSecretSheet: View {
    @Binding var isPresented: Bool
    let s: SecretVaultStrings
    let svc: SecretVaultService
    @State private var name = ""
    @State private var value = ""
    @State private var category: SecretCategory = .apiKey
    @State private var notes = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(s.addSecretButton).font(.headline)
            TextField(s.nameLabel, text: $name)
            SecureField(s.valueLabel, text: $value)
            Picker(s.categoryLabel, selection: $category) {
                ForEach(SecretCategory.allCases) { cat in Text(cat.rawValue).tag(cat) }
            }
            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Save") {
                    svc.add(name: name, value: value, category: category, notes: notes)
                    isPresented = false
                }.disabled(name.isEmpty || value.isEmpty)
            }
        }
        .padding(20).frame(minWidth: 360)
    }
}
