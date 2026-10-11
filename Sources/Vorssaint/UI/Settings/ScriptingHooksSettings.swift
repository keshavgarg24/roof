// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct ScriptingHooksSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var service = ScriptingHooksService.shared
    @AppStorage(DefaultsKey.scriptingHooksEnabled) private var enabled = false
    @State private var draftName = ""
    @State private var draftEvent: ScriptingHookEvent = .wake
    @State private var draftType: ScriptingHookType = .shell
    @State private var draftScript = ""
    @State private var editingHook: ScriptingHook?

    var body: some View {
        let s = FeatureStrings.scriptingHooks(l10n.language)
        Form {
            Section {
                Toggle(s.enableToggle, isOn: $enabled)
                    .onChange(of: enabled) { _, _ in
                        ScriptingHooksService.shared.syncWithPreferences()
                    }
                Text(s.enableCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(s.hooksTitle) {
                if service.hooks.isEmpty {
                    Text(s.noHooksCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(service.hooks) { hook in
                        hookRow(hook, s: s)
                    }
                    .onDelete { indexSet in
                        var updated = service.hooks
                        updated.remove(atOffsets: indexSet)
                        service.saveHooks(updated)
                    }
                }
                Text(s.hooksCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(s.addHookTitle) {
                TextField(s.hookNamePlaceholder, text: $draftName)
                    .textFieldStyle(.roundedBorder)
                Picker(s.eventLabel, selection: $draftEvent) {
                    ForEach(ScriptingHookEvent.allCases, id: \.self) { event in
                        Text(event.title(s)).tag(event)
                    }
                }
                Picker(s.scriptTypeLabel, selection: $draftType) {
                    ForEach(ScriptingHookType.allCases, id: \.self) { type in
                        Text(type.title(s)).tag(type)
                    }
                }
                TextEditor(text: $draftScript)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                if draftScript.isEmpty {
                    Text(s.hookScriptPlaceholder)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Button(s.addButton) { addHook(s: s) }
                    .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty
                                || draftScript.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .formStyle(.grouped)
    }

    private func hookRow(_ hook: ScriptingHook, s: ScriptingHooksStrings) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(hook.name.isEmpty ? s.hookNamePlaceholder : hook.name)
                    .font(.body)
                HStack(spacing: 4) {
                    Text(hook.event.title(s))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(hook.scriptType.title(s))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(s.testButton) {
                service.testHook(hook)
            }
            .buttonStyle(.borderless)
            .font(.caption)
            Toggle("", isOn: Binding(
                get: { hook.isEnabled },
                set: { newVal in
                    var updated = service.hooks
                    if let i = updated.firstIndex(where: { $0.id == hook.id }) {
                        updated[i].isEnabled = newVal
                        service.saveHooks(updated)
                    }
                }
            ))
            .labelsHidden()
            .controlSize(.small)
        }
    }

    private func addHook(s: ScriptingHooksStrings) {
        let name = draftName.trimmingCharacters(in: .whitespaces)
        let script = draftScript.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !script.isEmpty else { return }
        let hook = ScriptingHook(name: name, event: draftEvent,
                                  scriptType: draftType, script: script, isEnabled: true)
        service.saveHooks(service.hooks + [hook])
        draftName = ""
        draftScript = ""
    }
}
