// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct StartupManagerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var manager = StartupManagerService.shared

    var body: some View {
        let s = FeatureStrings.startupManager(l10n.language)
        Form {
            Section {
                HStack {
                    Text(s.pageTitle)
                        .font(.headline)
                    Spacer()
                    Button(s.refreshButton) {
                        Task { manager.refresh() }
                    }
                    .buttonStyle(.borderless)
                }
                Text(s.hubDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if manager.isLoading {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text(s.loadingLabel)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Section(s.launchAgentsTitle) {
                    if manager.items.isEmpty {
                        Text(s.noItemsCaption)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(manager.items) { item in
                            startupItemRow(item, s: s)
                        }
                    }
                    Text(s.launchAgentsCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .task {
            manager.refresh()
        }
    }

    private func startupItemRow(_ item: StartupItem, s: StartupManagerStrings) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .lineLimit(1)
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Group {
                if item.isEnabled {
                    Text(s.loadedLabel)
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text(s.notLoadedLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 60, alignment: .trailing)
            Toggle("", isOn: Binding(
                get: { item.isEnabled },
                set: { newVal in manager.setEnabled(item, enabled: newVal) }
            ))
            .labelsHidden()
            .controlSize(.small)
        }
    }
}
