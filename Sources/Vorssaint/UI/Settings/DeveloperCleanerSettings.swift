// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct DeveloperCleanerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = DeveloperCleanerService.shared

    private var s: DeveloperCleanerStrings { FeatureStrings.developerCleaner(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(s.pageTitle).font(.headline)
                    Spacer()
                    Button(s.scanButton) { svc.scan() }.disabled(svc.isScanning)
                }
            }

            if svc.isScanning {
                Section {
                    HStack {
                        ProgressView()
                        Text(s.scanningLabel).foregroundStyle(.secondary)
                    }
                }
            } else if svc.items.isEmpty {
                Section {
                    Text(s.noJunkFound).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                }
            } else {
                Section("\(s.totalReclaimable): \(svc.totalSelected)") {
                    ForEach(svc.items) { item in
                        HStack {
                            Toggle(isOn: Binding(
                                get: { item.isSelected },
                                set: { _ in svc.toggleSelection(id: item.id) }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.label)
                                    Text(item.category).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(item.sizeFormatted).foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Button(s.deleteSelectedButton, role: .destructive) { svc.clean() }
                        .disabled(svc.isCleaning || svc.items.filter(\.isSelected).isEmpty)
                        .frame(maxWidth: .infinity)
                    Text(s.deleteWarning).font(.caption).foregroundStyle(.secondary)
                    if let err = svc.lastError {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { if svc.items.isEmpty { svc.scan() } }
    }
}
