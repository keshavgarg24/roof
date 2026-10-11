// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct NotificationHistorySettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = NotificationHistoryService.shared
    @State private var searchQuery = ""

    private var s: NotificationHistoryStrings { FeatureStrings.notificationHistory(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField(s.searchPlaceholder, text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                    Button(s.clearAllButton, role: .destructive) { svc.clear() }
                        .disabled(svc.records.isEmpty)
                }
            }

            if svc.records.isEmpty {
                Section {
                    Text(s.noNotificationsCaption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
                }
            } else {
                ForEach(filteredGroups, id: \.label) { group in
                    Section(group.label) {
                        ForEach(group.records) { rec in
                            HStack(alignment: .top, spacing: 10) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(rec.title).fontWeight(.medium).lineLimit(1)
                                    Text(rec.body).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                    Text(rec.appName).font(.caption2).foregroundStyle(.tertiary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(rec.date, style: .time).font(.caption2).foregroundStyle(.secondary)
                                    Button { svc.delete(id: rec.id) } label: {
                                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                                    }.buttonStyle(.borderless)
                                }
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private var filteredGroups: [(label: String, records: [NotificationRecord])] {
        guard !searchQuery.isEmpty else { return svc.grouped }
        let filtered = svc.records.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.body.localizedCaseInsensitiveContains(searchQuery) ||
            $0.appName.localizedCaseInsensitiveContains(searchQuery)
        }
        return NotificationHistorySupport.groupedByDay(filtered)
    }
}
