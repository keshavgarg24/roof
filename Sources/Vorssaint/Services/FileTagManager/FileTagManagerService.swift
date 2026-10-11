// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import SwiftUI

final class FileTagManagerService: ObservableObject {
    static let shared = FileTagManagerService()
    private init() {}

    @AppStorage("fileTagManager.tags") private var tagsData: Data = Data()
    @AppStorage("fileTagManager.rules") private var rulesData: Data = Data()
    @Published private(set) var tags: [CustomTag] = []
    @Published private(set) var rules: [AutoTagRule] = []
    @Published var selectedTagName: String?
    @Published private(set) var taggedFiles: [URL] = []

    func syncWithPreferences() {
        tags = FileTagManagerSupport.decode(tagsData.isEmpty ? nil : tagsData)
        rules = FileTagManagerSupport.decodeRules(rulesData.isEmpty ? nil : rulesData)
    }

    func addTag(name: String, color: TagColor) {
        tags.append(CustomTag(name: name, color: color))
        saveTags()
    }

    func deleteTag(_ tag: CustomTag) {
        tags.removeAll { $0.id == tag.id }
        saveTags()
    }

    func addRule(_ rule: AutoTagRule) {
        rules.append(rule)
        saveRules()
    }

    func deleteRule(_ rule: AutoTagRule) {
        rules.removeAll { $0.id == rule.id }
        saveRules()
    }

    func findFiles(for tagName: String, in roots: [URL]) {
        selectedTagName = tagName
        DispatchQueue.global(qos: .userInitiated).async {
            let files = FileTagManagerSupport.filesWithTag(tagName, searchRoots: roots)
            DispatchQueue.main.async { self.taggedFiles = files }
        }
    }

    func runRule(_ rule: AutoTagRule, in directory: URL, completion: @escaping (Int) -> Void) {
        FileTagManagerSupport.applyAutoRule(rule, in: directory, completion: completion)
    }

    private func saveTags() { tagsData = FileTagManagerSupport.encode(tags) }
    private func saveRules() { rulesData = FileTagManagerSupport.encodeRules(rules) }
}
