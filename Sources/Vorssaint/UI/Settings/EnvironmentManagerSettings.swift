// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct EnvironmentManagerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = EnvironmentManagerService.shared
    @State private var selectedTab = 0

    private var s: EnvironmentManagerStrings { FeatureStrings.environmentManager(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField(s.searchPlaceholder, text: $svc.searchQuery).textFieldStyle(.roundedBorder)
                    Button(s.refreshButton) { svc.refresh() }
                }
                Picker(s.sourceLabel, selection: $selectedTab) {
                    Text(s.shellEnvSection).tag(0)
                    Text(s.envFilesSection).tag(1)
                }
                .pickerStyle(.segmented)
            }

            if selectedTab == 0 {
                Section("\(s.shellEnvSection) (\(svc.filteredProcess.count))") {
                    ForEach(svc.filteredProcess) { v in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(v.key).font(.caption.monospaced()).fontWeight(.medium)
                                Text(v.value).font(.caption.monospaced()).foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(v.value, forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless).font(.caption)
                        }
                    }
                }
            } else {
                Section(s.envFilesSection) {
                    if svc.envFiles.isEmpty {
                        Text(s.noEnvFilesCaption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                    } else {
                        ForEach(svc.envFiles) { file in
                            DisclosureGroup(file.name) {
                                ForEach(file.variables) { v in
                                    HStack {
                                        Text(v.key).font(.caption.monospaced()).fontWeight(.medium)
                                        Spacer()
                                        Text(String(v.value.prefix(30))).font(.caption.monospaced()).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    Button(s.addPathButton) { addDirectory() }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { if svc.processVars.isEmpty { svc.refresh() } }
    }

    private func addDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK, let url = panel.url { svc.scanDirectory(url) }
    }
}
