// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit
import Foundation

struct TagColor: Codable, Equatable {
    var red: Double; var green: Double; var blue: Double
    static let presets: [TagColor] = [
        TagColor(red: 1, green: 0.2, blue: 0.2),   // red
        TagColor(red: 1, green: 0.6, blue: 0),      // orange
        TagColor(red: 1, green: 0.9, blue: 0),      // yellow
        TagColor(red: 0.2, green: 0.8, blue: 0.2),  // green
        TagColor(red: 0.2, green: 0.6, blue: 1),    // blue
        TagColor(red: 0.7, green: 0.3, blue: 1),    // purple
        TagColor(red: 0.9, green: 0.4, blue: 0.7),  // pink
        TagColor(red: 0.6, green: 0.6, blue: 0.6),  // gray
    ]
}

struct CustomTag: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var color: TagColor
    var finderTagName: String { name }  // Finder tags are just strings
}

enum AutoRuleCondition: String, Codable, CaseIterable {
    case olderThan, inFolder, hasExtension
}

struct AutoTagRule: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var condition: AutoRuleCondition
    var conditionValue: String   // days, folder path, or extension
    var tagName: String
    var isEnabled: Bool = true
}

enum FileTagManagerSupport {
    static func tags(for url: URL) -> [String] {
        (try? url.resourceValues(forKeys: [.tagNamesKey]))?.tagNames ?? []
    }

    static func addTag(_ tagName: String, to url: URL) throws {
        var existing = tags(for: url)
        guard !existing.contains(tagName) else { return }
        existing.append(tagName)
        try (url as NSURL).setResourceValue(existing, forKey: .tagNamesKey)
    }

    static func removeTag(_ tagName: String, from url: URL) throws {
        let updated = tags(for: url).filter { $0 != tagName }
        try (url as NSURL).setResourceValue(updated, forKey: .tagNamesKey)
    }

    static func filesWithTag(_ tagName: String, searchRoots: [URL]) -> [URL] {
        var results: [URL] = []
        let fm = FileManager.default
        for root in searchRoots {
            guard let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: [.tagNamesKey], options: [.skipsHiddenFiles]) else { continue }
            for case let url as URL in enumerator {
                if tags(for: url).contains(tagName) { results.append(url) }
            }
        }
        return results
    }

    static func applyAutoRule(_ rule: AutoTagRule, in directory: URL, completion: @escaping (Int) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let enumerator = FileManager.default.enumerator(
                at: directory, includingPropertiesForKeys: [.tagNamesKey, .contentModificationDateKey], options: [.skipsHiddenFiles]) else {
                DispatchQueue.main.async { completion(0) }
                return
            }
            var count = 0
            for case let url as URL in enumerator {
                var matches = false
                switch rule.condition {
                case .olderThan:
                    let days = Int(rule.conditionValue) ?? 30
                    let modDate = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date()
                    matches = modDate < Date().addingTimeInterval(-Double(days) * 86400)
                case .inFolder:
                    matches = url.deletingLastPathComponent().path == rule.conditionValue
                case .hasExtension:
                    matches = url.pathExtension.lowercased() == rule.conditionValue.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
                }
                if matches, let _ = try? addTag(rule.tagName, to: url) { count += 1 }
            }
            DispatchQueue.main.async { completion(count) }
        }
    }

    static func decode(_ data: Data?) -> [CustomTag] {
        guard let data, let tags = try? JSONDecoder().decode([CustomTag].self, from: data) else { return [] }
        return tags
    }

    static func encode(_ tags: [CustomTag]) -> Data {
        (try? JSONEncoder().encode(tags)) ?? Data()
    }

    static func decodeRules(_ data: Data?) -> [AutoTagRule] {
        guard let data, let rules = try? JSONDecoder().decode([AutoTagRule].self, from: data) else { return [] }
        return rules
    }

    static func encodeRules(_ rules: [AutoTagRule]) -> Data {
        (try? JSONEncoder().encode(rules)) ?? Data()
    }
}
