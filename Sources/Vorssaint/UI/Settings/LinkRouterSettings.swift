// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct LinkRouterSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var router = LinkRouterService.shared
    @AppStorage(DefaultsKey.linkRouterEnabled) private var enabled = false
    @State private var draftName = ""
    @State private var draftPattern = ""
    @State private var draftBrowserID = ""

    var body: some View {
        let s = FeatureStrings.linkRouter(l10n.language)
        Form {
            Section {
                Toggle(s.enableToggle, isOn: $enabled)
                    .onChange(of: enabled) { _, _ in
                        LinkRouterService.shared.syncWithPreferences()
                    }
                Text(s.enableCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(s.rulesTitle) {
                if router.rules.isEmpty {
                    Text(s.noRulesCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(router.rules) { rule in
                        ruleRow(rule, s: s)
                    }
                    .onDelete { indexSet in
                        var updated = router.rules
                        updated.remove(atOffsets: indexSet)
                        router.saveRules(updated)
                    }
                }
                Text(s.rulesCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(s.addRuleTitle) {
                TextField(s.ruleNamePlaceholder, text: $draftName)
                    .textFieldStyle(.roundedBorder)
                TextField(s.rulePatternPlaceholder, text: $draftPattern)
                    .textFieldStyle(.roundedBorder)
                installedBrowserPicker(s: s)
                TextField(s.ruleBrowserPlaceholder, text: $draftBrowserID)
                    .textFieldStyle(.roundedBorder)
                Button(s.addButton) { addRule() }
                    .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty
                                || draftPattern.trimmingCharacters(in: .whitespaces).isEmpty
                                || draftBrowserID.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .formStyle(.grouped)
    }

    private func ruleRow(_ rule: LinkRouterRule, s: LinkRouterStrings) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(rule.name)
                    .font(.body)
                HStack(spacing: 4) {
                    Text(rule.pattern)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("→")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(rule.browserBundleID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { newVal in
                    var updated = router.rules
                    if let i = updated.firstIndex(where: { $0.id == rule.id }) {
                        updated[i].isEnabled = newVal
                        router.saveRules(updated)
                    }
                }
            ))
            .labelsHidden()
        }
    }

    @ViewBuilder
    private func installedBrowserPicker(s: LinkRouterStrings) -> some View {
        let browsers = router.installedBrowsers()
        if !browsers.isEmpty {
            Picker(s.installedBrowsersLabel, selection: $draftBrowserID) {
                Text("").tag("")
                ForEach(browsers, id: \.bundleID) { browser in
                    Text(browser.name).tag(browser.bundleID)
                }
            }
        }
    }

    private func addRule() {
        let name = draftName.trimmingCharacters(in: .whitespaces)
        let pattern = draftPattern.trimmingCharacters(in: .whitespaces)
        let browserID = draftBrowserID.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !pattern.isEmpty, !browserID.isEmpty else { return }
        let rule = LinkRouterRule(name: name, pattern: pattern,
                                  browserBundleID: browserID, isEnabled: true)
        router.saveRules(router.rules + [rule])
        draftName = ""
        draftPattern = ""
        draftBrowserID = ""
    }
}
