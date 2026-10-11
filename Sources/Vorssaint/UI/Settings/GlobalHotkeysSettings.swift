// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct GlobalHotkeysSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = GlobalHotkeysService.shared
    @State private var showAddSheet = false

    private var s: GlobalHotkeysStrings { FeatureStrings.globalHotkeys(l10n.language) }

    var body: some View {
        Form {
            Section(s.hyperKeySection) {
                if !AXIsProcessTrusted() {
                    Label(s.hyperKeyCaption, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Button(s.actionLaunchApp) {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }
                } else {
                    Text(s.hyperKeyEnabled).foregroundStyle(.secondary)
                }
            }

            Section(s.rulesSection) {
                if svc.rules.isEmpty {
                    Text(s.noRulesCaption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                } else {
                    ForEach(svc.rules) { rule in
                        HStack {
                            Toggle(isOn: Binding(
                                get: { rule.isEnabled },
                                set: { _ in svc.toggleRule(id: rule.id) }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(rule.label)
                                    Text(rule.displayString).font(.caption.monospaced()).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { svc.deleteRule(at: $0) }
                }
                Button(s.addRuleButton) { showAddSheet = true }
                Text(s.recordingHint).font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showAddSheet) {
            AddHotkeyRuleSheet(isPresented: $showAddSheet, s: s, svc: svc)
        }
    }
}

private struct AddHotkeyRuleSheet: View {
    @Binding var isPresented: Bool
    let s: GlobalHotkeysStrings
    let svc: GlobalHotkeysService
    @State private var label = ""
    @State private var script = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(s.addRuleButton).font(.headline)
            TextField(s.keyComboLabel, text: $label)
            TextField(s.actionRunScript, text: $script)
            Text(s.recordingHint).font(.caption).foregroundStyle(.secondary)
            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Save") {
                    let rule = HotkeyRule(keyCode: 49,
                                          modifiers: UInt32(NSEvent.ModifierFlags.command.rawValue),
                                          action: .runScript(script: script),
                                          label: label.isEmpty ? s.actionRunScript : label)
                    svc.addRule(rule)
                    isPresented = false
                }
                .disabled(label.isEmpty && script.isEmpty)
            }
        }
        .padding(20)
        .frame(minWidth: 360)
    }
}
