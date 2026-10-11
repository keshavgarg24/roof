// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct FileTagManagerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = FileTagManagerService.shared
    @State private var newTagName = ""
    @State private var newTagColorIndex = 0
    @State private var showRuleSheet = false
    @State private var selectedTab = 0

    private var s: FileTagManagerStrings { FeatureStrings.fileTagManager(l10n.language) }

    var body: some View {
        Form {
            Section {
                Picker(s.ruleTagLabel, selection: $selectedTab) {
                    Text(s.tagsSection).tag(0)
                    Text(s.autoRulesSection).tag(1)
                }
                .pickerStyle(.segmented)
            }

            if selectedTab == 0 {
                Section(s.tagsSection) {
                    HStack {
                        TextField(s.searchByTagLabel, text: $newTagName)
                        Picker(s.ruleTagLabel, selection: $newTagColorIndex) {
                            ForEach(0..<TagColor.presets.count, id: \.self) { i in
                                let c = TagColor.presets[i]
                                Circle().fill(Color(red: c.red, green: c.green, blue: c.blue))
                                    .frame(width: 14, height: 14).tag(i)
                            }
                        }
                        .frame(width: 60)
                        Button(s.addTagButton) {
                            guard !newTagName.isEmpty else { return }
                            svc.addTag(name: newTagName, color: TagColor.presets[newTagColorIndex])
                            newTagName = ""
                        }
                    }
                    ForEach(svc.tags) { tag in
                        HStack {
                            Circle()
                                .fill(Color(red: tag.color.red, green: tag.color.green, blue: tag.color.blue))
                                .frame(width: 12, height: 12)
                            Text(tag.name)
                            Spacer()
                            Button(s.deleteTagButton, role: .destructive) { svc.deleteTag(tag) }
                                .buttonStyle(.borderless).foregroundStyle(.red)
                        }
                    }
                    if svc.tags.isEmpty {
                        Text(s.noTagsCaption).foregroundStyle(.secondary)
                    }
                }
            } else {
                Section(s.autoRulesSection) {
                    if svc.rules.isEmpty {
                        Text(s.noTagsCaption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                    } else {
                        ForEach(svc.rules) { rule in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ruleDescription(rule))
                                    Text("→ " + rule.tagName).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(s.tagFilesButton) {
                                    let panel = NSOpenPanel()
                                    panel.canChooseFiles = false; panel.canChooseDirectories = true
                                    if panel.runModal() == .OK, let url = panel.url {
                                        svc.runRule(rule, in: url) { _ in }
                                    }
                                }.buttonStyle(.borderless)
                                Button(s.deleteTagButton, role: .destructive) { svc.deleteRule(rule) }
                                    .buttonStyle(.borderless).foregroundStyle(.red)
                            }
                        }
                    }
                    Button(s.addRuleButton) { showRuleSheet = true }
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showRuleSheet) {
            AddAutoTagRuleSheet(isPresented: $showRuleSheet, s: s, svc: svc)
        }
    }

    private func ruleDescription(_ rule: AutoTagRule) -> String {
        switch rule.condition {
        case .olderThan: return "\(s.ruleOlderThan) \(rule.conditionValue) days"
        case .inFolder: return "\(s.ruleInFolder): \(rule.conditionValue)"
        case .hasExtension: return "\(s.ruleExtension): .\(rule.conditionValue)"
        }
    }
}

private struct AddAutoTagRuleSheet: View {
    @Binding var isPresented: Bool
    let s: FileTagManagerStrings
    let svc: FileTagManagerService
    @State private var condition: AutoRuleCondition = .olderThan
    @State private var conditionValue = "30"
    @State private var tagName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(s.addRuleButton).font(.headline)
            Picker(s.ruleConditionLabel, selection: $condition) {
                ForEach(AutoRuleCondition.allCases, id: \.self) { c in Text(c.rawValue).tag(c) }
            }
            TextField(s.ruleOlderThan, text: $conditionValue)
            TextField(s.ruleTagLabel, text: $tagName)
            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Save") {
                    let rule = AutoTagRule(condition: condition, conditionValue: conditionValue, tagName: tagName)
                    svc.addRule(rule)
                    isPresented = false
                }.disabled(tagName.isEmpty || conditionValue.isEmpty)
            }
        }
        .padding(20).frame(minWidth: 340)
    }
}
