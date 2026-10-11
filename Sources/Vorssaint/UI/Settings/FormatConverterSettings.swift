// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct FormatConverterSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = FormatConverterService.shared

    private var s: FormatConverterStrings { FeatureStrings.formatConverter(l10n.language) }

    var body: some View {
        Form {
            Section(s.pageTitle) {
                Picker(s.outputFormatLabel, selection: $svc.selectedCategory) {
                    ForEach(ConversionCategory.allCases, id: \.self) { cat in
                        Text(categoryLabel(cat)).tag(cat)
                    }
                }
                .pickerStyle(.segmented)

                switch svc.selectedCategory {
                case .audio:
                    Picker(s.outputFormatLabel, selection: $svc.audioFormat) {
                        ForEach(AudioOutputFormat.allCases) { fmt in Text(fmt.rawValue).tag(fmt) }
                    }
                case .image:
                    Picker(s.outputFormatLabel, selection: $svc.imageFormat) {
                        ForEach(ImageOutputFormat.allCases) { fmt in Text(fmt.rawValue).tag(fmt) }
                    }
                case .video:
                    Picker(s.outputFormatLabel, selection: $svc.videoFormat) {
                        ForEach(VideoOutputFormat.allCases) { fmt in Text(fmt.rawValue).tag(fmt) }
                    }
                }
            }

            Section(s.outputFolderLabel) {
                if svc.files.isEmpty {
                    Text(s.dropFilesHint)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ForEach(svc.files) { file in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(file.url.lastPathComponent).lineLimit(1)
                                statusLabel(file.status)
                            }
                            Spacer()
                            Button { svc.removeFile(file.id) } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }.buttonStyle(.borderless)
                        }
                    }
                }
            }

            Section {
                HStack {
                    Button(s.addFilesButton) { openPanel() }
                    Spacer()
                    Button(s.clearButton) { svc.clearAll() }.disabled(svc.files.isEmpty)
                    Button(s.convertButton) { svc.convertAll() }
                        .disabled(svc.files.isEmpty || svc.isConverting)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func categoryLabel(_ cat: ConversionCategory) -> String {
        switch cat {
        case .audio: return s.categoryAudio
        case .image: return s.categoryImage
        case .video: return s.categoryVideo
        }
    }

    private func statusLabel(_ status: ConversionFile.ConversionStatus) -> some View {
        switch status {
        case .pending:   return Text(s.noFilesCaption).font(.caption).foregroundStyle(.secondary)
        case .converting: return Text(s.convertingLabel).font(.caption).foregroundStyle(.blue)
        case .done:       return Text(s.doneLabel).font(.caption).foregroundStyle(.green)
        case .failed(let msg): return Text(msg).font(.caption).foregroundStyle(.red)
        }
    }

    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if panel.runModal() == .OK { svc.addFiles(panel.urls) }
    }
}
