// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct WorldClockSettings: View {
    @ObservedObject private var service = WorldClockService.shared
    @ObservedObject private var l10n = L10n.shared

    @State private var searchQuery = ""
    @State private var showingSearch = false
    @State private var tick = 0
    @State private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var s: WorldClockStrings { FeatureStrings.worldClock(l10n.language) }

    var body: some View {
        Form {
            Section {
                if service.entries.isEmpty {
                    Text(s.noClocks)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                } else {
                    ForEach(service.entries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.label)
                                    .fontWeight(.medium)
                                Text(WorldClockSupport.offsetString(for: entry))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(WorldClockSupport.currentTime(for: entry))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .onMove { from, to in
                        var updated = service.entries
                        updated.move(fromOffsets: from, toOffset: to)
                        service.saveEntries(updated)
                    }
                    .onDelete { idx in
                        var updated = service.entries
                        updated.remove(atOffsets: idx)
                        service.saveEntries(updated)
                    }
                }
            } header: {
                HStack {
                    Text(s.clocksSection)
                    Spacer()
                    Button {
                        showingSearch = true
                    } label: {
                        Label(s.addButton, systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .formStyle(.grouped)
        .onReceive(timer) { _ in tick += 1 }
        .sheet(isPresented: $showingSearch) {
            TimezonePickerSheet(s: s) { identifier, label in
                var updated = service.entries
                updated.append(WorldClockEntry(identifier: identifier, label: label))
                service.saveEntries(updated)
            }
        }
    }
}

private struct TimezonePickerSheet: View {
    let s: WorldClockStrings
    let onAdd: (String, String) -> Void

    @State private var query = ""
    @State private var customLabel = ""
    @State private var selected: String?
    @Environment(\.dismiss) private var dismiss

    private var results: [String] {
        WorldClockSupport.searchTimezones(query)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(s.searchPlaceholder)
                    .font(.headline)
                Spacer()
                Button(s.cancelButton) { dismiss() }
                    .buttonStyle(.plain)
            }
            .padding()

            TextField(s.searchPlaceholder, text: $query)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List(results, id: \.self, selection: $selected) { tz in
                Text(tz)
            }
            .frame(height: 200)

            if let sel = selected {
                HStack {
                    TextField(s.customLabelPlaceholder, text: $customLabel)
                        .textFieldStyle(.roundedBorder)
                    Button(s.addButton) {
                        let label = customLabel.isEmpty
                            ? sel.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? sel
                            : customLabel
                        onAdd(sel, label)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sel.isEmpty)
                }
                .padding()
            }
        }
        .frame(width: 360, height: 360)
    }
}
