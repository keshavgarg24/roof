// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import Security

enum SecretCategory: String, CaseIterable, Identifiable, Codable {
    case apiKey, token, certificate, password, other
    var id: String { rawValue }
}

struct VaultSecret: Identifiable, Equatable {
    let id: String     // UUID stored in label
    var name: String
    var category: SecretCategory
    var notes: String
    // value is NOT stored in this struct — read from Keychain on demand
}

enum SecretVaultSupport {
    private static let service = "com.vorssaint.utils.secretvault"

    static func allSecrets() -> [VaultSecret] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let items = result as? [[String: Any]] else { return [] }
        return items.compactMap { item -> VaultSecret? in
            guard let id = item[kSecAttrAccount as String] as? String,
                  let name = item[kSecAttrLabel as String] as? String else { return nil }
            let catRaw = item[kSecAttrDescription as String] as? String ?? SecretCategory.other.rawValue
            let notes = item[kSecAttrComment as String] as? String ?? ""
            return VaultSecret(id: id, name: name, category: SecretCategory(rawValue: catRaw) ?? .other, notes: notes)
        }
    }

    static func saveSecret(name: String, value: String, category: SecretCategory, notes: String) throws -> String {
        let id = UUID().uuidString
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id,
            kSecAttrLabel as String: name,
            kSecAttrDescription as String: category.rawValue,
            kSecAttrComment as String: notes,
            kSecValueData as String: Data(value.utf8)
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
        return id
    }

    static func readValue(id: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func updateSecret(id: String, name: String, value: String, category: SecretCategory, notes: String) throws {
        let search: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id
        ]
        let update: [String: Any] = [
            kSecAttrLabel as String: name,
            kSecAttrDescription as String: category.rawValue,
            kSecAttrComment as String: notes,
            kSecValueData as String: Data(value.utf8)
        ]
        let status = SecItemUpdate(search as CFDictionary, update as CFDictionary)
        if status != errSecSuccess { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
    }

    static func deleteSecret(id: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    static func importFromEnvFile(url: URL) throws -> [(name: String, value: String)] {
        let content = try String(contentsOf: url, encoding: .utf8)
        return content.components(separatedBy: "\n").compactMap { line -> (String, String)? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#"),
                  let eq = trimmed.firstIndex(of: "=") else { return nil }
            let key = String(trimmed[trimmed.startIndex..<eq])
            var value = String(trimmed[trimmed.index(after: eq)...])
            if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
               (value.hasPrefix("'") && value.hasSuffix("'")) {
                value = String(value.dropFirst().dropLast())
            }
            return (key, value)
        }
    }
}
