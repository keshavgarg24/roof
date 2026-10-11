// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct DiffViewerSettings: View {
    @ObservedObject private var service = DiffViewerService.shared
    @ObservedObject private var l10n = L10n.shared

    private var s: DiffViewerStrings { FeatureStrings.diffViewer(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.originalLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $service.originalText)
                            .font(.system(.caption, design: .monospaced))
                            .frame(height: 120)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.modifiedLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $service.modifiedText)
                            .font(.system(.caption, design: .monospaced))
                            .frame(height: 120)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                    }
                }

                HStack {
                    Button(s.pasteOriginalButton) {
                        service.pasteOriginalFromClipboard()
                    }
                    Button(s.clearButton) {
                        service.clear()
                    }
                    Spacer()
                    Button(s.compareButton) {
                        service.compute()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(service.originalText.isEmpty && service.modifiedText.isEmpty)
                }
            } header: {
                Text(s.inputSection)
            }

            if !service.diffLines.isEmpty {
                Section {
                    HStack(spacing: 16) {
                        Label("\(service.addedCount) \(s.addedLabel)", systemImage: "plus.circle.fill")
                            .foregroundStyle(.green)
                        Label("\(service.removedCount) \(s.removedLabel)", systemImage: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .font(.callout)
                    .padding(.vertical, 2)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(service.diffLines) { line in
                                DiffLineRow(line: line)
                            }
                        }
                    }
                    .frame(height: 200)
                } header: {
                    Text(s.diffSection)
                }
            }
        }
        .formStyle(.grouped)
    }
}

private struct DiffLineRow: View {
    let line: DiffLine

    var body: some View {
        HStack(spacing: 0) {
            Text(lineNumberText)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
                .padding(.trailing, 6)
            Text(prefix)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(prefixColor)
                .frame(width: 12)
            Text(line.text)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 1)
        .padding(.horizontal, 4)
        .background(background)
    }

    private var lineNumberText: String {
        switch line.type {
        case .unchanged: return "\(line.lineNumber ?? 0)"
        case .added:     return "+\(line.newLineNumber ?? 0)"
        case .removed:   return "-\(line.lineNumber ?? 0)"
        }
    }

    private var prefix: String {
        switch line.type {
        case .unchanged: return " "
        case .added:     return "+"
        case .removed:   return "-"
        }
    }

    private var prefixColor: Color {
        switch line.type {
        case .unchanged: return .secondary
        case .added:     return .green
        case .removed:   return .red
        }
    }

    private var background: Color {
        switch line.type {
        case .unchanged: return .clear
        case .added:     return .green.opacity(0.1)
        case .removed:   return .red.opacity(0.1)
        }
    }
}
