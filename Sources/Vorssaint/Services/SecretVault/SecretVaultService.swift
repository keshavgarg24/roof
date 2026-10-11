// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

final class SecretVaultService: ObservableObject {
    static let shared = SecretVaultService()
    private init() {}

    @Published private(set) var secrets: [VaultSecret] = []
    @Published var lastError: String?

    func syncWithPreferences() { reload() }

    func reload() {
        secrets = SecretVaultSupport.allSecrets()
    }

    func add(name: String, value: String, category: SecretCategory, notes: String) {
        do {
            _ = try SecretVaultSupport.saveSecret(name: name, value: value, category: category, notes: notes)
            reload()
        } catch { lastError = error.localizedDescription }
    }

    func update(id: String, name: String, value: String, category: SecretCategory, notes: String) {
        do {
            try SecretVaultSupport.updateSecret(id: id, name: name, value: value, category: category, notes: notes)
            reload()
        } catch { lastError = error.localizedDescription }
    }

    func delete(_ secret: VaultSecret) {
        do {
            try SecretVaultSupport.deleteSecret(id: secret.id)
            reload()
        } catch { lastError = error.localizedDescription }
    }

    func readValue(for secret: VaultSecret) -> String? {
        SecretVaultSupport.readValue(id: secret.id)
    }
}
