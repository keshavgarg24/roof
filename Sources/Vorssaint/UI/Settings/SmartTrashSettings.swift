// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct SmartTrashSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = SmartTrashService.shared
    @State private var showSnapshotSection = false

    private var s: SmartTrashStrings { FeatureStrings.smartTrash(l10n.language) }

    var body: some View {
        Form {
            Section(s.trashSection) {
                HStack {
                    Text(s.trashSizeLabel).foregroundStyle(.secondary)
                    Spacer()
                    Text(SmartTrashSupport.formattedTotal).bold()
                }
                if svc.items.isEmpty {
                    Text(s.noTrashItems).foregroundStyle(.secondary)
                } else {
                    ForEach(svc.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name).lineLimit(1)
                                if let d = item.deletedDate {
                                    Text(d, style: .relative).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(item.sizeFormatted).foregroundStyle(.secondary)
                            Button(s.restoreButton) { svc.restore(item) }.buttonStyle(.borderless)
                        }
                    }
                }
                if !svc.items.isEmpty {
                    Button(s.emptyTrashButton, role: .destructive) {
                        try? SmartTrashSupport.emptyTrash()
                        svc.refresh()
                    }
                }
            }

            Section(s.snapshotSection) {
                Toggle(s.snapshotDate, isOn: $showSnapshotSection)
                if showSnapshotSection {
                    if svc.isLoadingSnapshots {
                        HStack { ProgressView(); Text(s.snapshotDate).foregroundStyle(.secondary) }
                    } else if svc.snapshots.isEmpty {
                        Text(s.noSnapshots).foregroundStyle(.secondary)
                    } else {
                        ForEach(svc.snapshots) { snap in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(snap.name).font(.caption.monospaced())
                                    if let d = snap.date {
                                        Text(d, style: .date).font(.caption2).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text(snap.volume).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .onChange(of: showSnapshotSection) { _, show in if show { svc.loadSnapshots() } }
        }
        .formStyle(.grouped)
        .onAppear { svc.refresh() }
    }
}

private extension SmartTrashSupport {
    static var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: trashSize(), countStyle: .file)
    }
}
