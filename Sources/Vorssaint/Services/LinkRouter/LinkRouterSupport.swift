// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

/// One routing rule: if a URL's host or full string contains `pattern`,
/// open it in `browserBundleID`.
struct LinkRouterRule: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var pattern: String
    var browserBundleID: String
    var isEnabled: Bool

    init(id: UUID = UUID(),
         name: String,
         pattern: String,
         browserBundleID: String,
         isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.pattern = pattern
        self.browserBundleID = browserBundleID
        self.isEnabled = isEnabled
    }
}

enum LinkRouterSupport {
    /// Returns the bundle ID of the browser that should open `url`, or nil if
    /// no enabled rule matches and the default browser should be used.
    static func matchingBrowser(for url: URL, rules: [LinkRouterRule]) -> String? {
        let host = url.host?.lowercased() ?? ""
        let full = url.absoluteString.lowercased()
        for rule in rules where rule.isEnabled {
            let pattern = rule.pattern.lowercased()
            guard !pattern.isEmpty else { continue }
            if host.contains(pattern) || full.contains(pattern) {
                return rule.browserBundleID
            }
        }
        return nil
    }

    static func decode(_ data: Data?) -> [LinkRouterRule] {
        guard let data, !data.isEmpty,
              let rules = try? JSONDecoder().decode([LinkRouterRule].self, from: data) else {
            return []
        }
        return rules
    }

    static func encode(_ rules: [LinkRouterRule]) -> Data {
        (try? JSONEncoder().encode(rules)) ?? Data()
    }
}
