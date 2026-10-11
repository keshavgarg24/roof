// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct HashGeneratorSettings: View {
    @ObservedObject private var service = HashGeneratorService.shared
    @ObservedObject private var l10n = L10n.shared
    @State private var inputMode: InputMode = .text

    private var s: HashGeneratorStrings { FeatureStrings.hashGenerator(l10n.language) }

    enum InputMode { case text, file }

    var body: some View {
        Form {
            Section {
                Picker(s.inputModeLabel, selection: $inputMode) {
                    Text(s.inputModeText).tag(InputMode.text)
                    Text(s.inputModeFile).tag(InputMode.file)
                }
                .pickerStyle(.segmented)

                if inputMode == .text {
                    TextEditor(text: $service.inputText)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.3))
                        )

                    HStack {
                        Button(s.pasteButton) {
                            service.pasteFromClipboard()
                        }
                        Spacer()
                        Button(s.computeButton) {
                            service.compute()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(service.inputText.isEmpty)
                    }
                } else {
                    HStack {
                        if let url = service.selectedFile {
                            Text(url.lastPathComponent)
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(s.noFileSelected)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(s.chooseFileButton) {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            if panel.runModal() == .OK {
                                service.selectedFile = panel.url
                                service.compute()
                            }
                        }
                    }
                }
            } header: {
                Text(s.inputSection)
            }

            if !service.hashes.isEmpty {
                Section {
                    ForEach(service.hashes, id: \.0) { (algo, hash) in
                        HStack {
                            Text(algo.rawValue)
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .leading)
                            Text(hash)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .lineLimit(1)
                            Spacer()
                            Button {
                                NSPasteboard.general.declareTypes([.string], owner: nil)
                                NSPasteboard.general.setString(hash, forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text(s.resultsSection)
                }
            }
        }
        .formStyle(.grouped)
    }
}
