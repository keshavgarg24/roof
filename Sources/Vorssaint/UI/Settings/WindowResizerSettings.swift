// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct WindowResizerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var service = WindowResizerService.shared
    @State private var draftName = ""
    @State private var draftWidth = ""
    @State private var draftHeight = ""

    var body: some View {
        let s = FeatureStrings.windowResizer(l10n.language)
        Form {
            Section {
                Text(s.subtitle).font(.headline)
                Text(s.presetsCaption).font(.caption).foregroundStyle(.secondary)
                Text(s.accessibilityNote).font(.caption2).foregroundStyle(.tertiary)
            }

            Section("Built-in Presets") {
                ForEach(WindowResizerSupport.builtInPresets) { preset in
                    presetRow(preset, s: s, isBuiltIn: true)
                }
            }

            if !service.customPresets.isEmpty {
                Section("Custom Presets") {
                    ForEach(service.customPresets) { preset in
                        presetRow(preset, s: s, isBuiltIn: false)
                    }
                    .onDelete { indexSet in
                        var updated = service.customPresets
                        updated.remove(atOffsets: indexSet)
                        service.saveCustomPresets(updated)
                    }
                }
            }

            Section(s.customTitle) {
                TextField(s.presetNamePlaceholder, text: $draftName)
                    .textFieldStyle(.roundedBorder)
                HStack(spacing: 12) {
                    LabeledContent(s.widthLabel) {
                        TextField("1280", text: $draftWidth)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    LabeledContent(s.heightLabel) {
                        TextField("800", text: $draftHeight)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                }
                Button(s.addPresetButton) { addPreset(s: s) }
                    .disabled(!canAdd)
            }
        }
        .formStyle(.grouped)
    }

    private var canAdd: Bool {
        !draftName.trimmingCharacters(in: .whitespaces).isEmpty
            && Int(draftWidth) != nil && Int(draftHeight) != nil
    }

    private func presetRow(_ preset: WindowResizerPreset,
                            s: WindowResizerStrings,
                            isBuiltIn: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(preset.name).font(.body)
                Text("\(preset.width) × \(preset.height)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(s.applyButton) {
                service.apply(preset: preset)
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
    }

    private func addPreset(s: WindowResizerStrings) {
        let name = draftName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let w = Int(draftWidth), let h = Int(draftHeight) else { return }
        let preset = WindowResizerPreset(name: name, width: w, height: h)
        service.saveCustomPresets(service.customPresets + [preset])
        draftName = ""
        draftWidth = ""
        draftHeight = ""
    }
}
