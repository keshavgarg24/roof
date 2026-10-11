// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct JSONFormatterSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = JSONFormatterService.shared

    private var s: JSONFormatterStrings { FeatureStrings.jsonFormatter(l10n.language) }

    var body: some View {
        Form {
            Section(s.pageTitle) {
                TextEditor(text: $svc.input)
                    .font(.system(.caption, design: .monospaced))
                    .frame(minHeight: 100, maxHeight: 160)
                    .onChange(of: svc.input) { svc.validate() }

                HStack(spacing: 8) {
                    Button(s.pasteButton) { svc.pasteFromClipboard() }
                    Button(s.clearButton) { svc.input = ""; svc.output = ""; svc.isValid = nil }
                    Toggle(s.sortKeysLabel, isOn: $svc.sortKeys)
                    Spacer()
                    if let valid = svc.isValid {
                        Label(valid ? s.validBadge : s.invalidBadge,
                              systemImage: valid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(valid ? .green : .red)
                            .font(.caption)
                    }
                }

                HStack(spacing: 8) {
                    Button(s.formatButton) { svc.format() }.disabled(svc.input.isEmpty)
                    Button(s.minifyButton) { svc.minify() }.disabled(svc.input.isEmpty)
                }
            }

            if !svc.output.isEmpty {
                Section {
                    ScrollView {
                        Text(svc.output)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 100, maxHeight: 200)

                    Button(s.copyButton) { svc.copyOutput() }
                }
            }
        }
        .formStyle(.grouped)
    }
}
