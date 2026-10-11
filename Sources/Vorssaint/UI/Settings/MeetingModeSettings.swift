// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct MeetingModeSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var service = MeetingModeService.shared
    @AppStorage(DefaultsKey.meetingModeEnabled) private var enabled = false
    @AppStorage(DefaultsKey.meetingModeAutoMute) private var autoMute = true
    @State private var draftBundleID = ""

    var body: some View {
        let s = FeatureStrings.meetingMode(l10n.language)
        Form {
            Section {
                Toggle(s.enableToggle, isOn: $enabled)
                    .onChange(of: enabled) { _, _ in
                        MeetingModeService.shared.syncWithPreferences()
                    }
                Text(s.enableCaption).font(.caption).foregroundStyle(.secondary)
                if enabled {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(service.isMeetingActive ? Color.green : Color.secondary.opacity(0.4))
                            .frame(width: 8, height: 8)
                        Text(service.isMeetingActive ? s.statusActive : s.statusIdle)
                            .font(.caption)
                            .foregroundStyle(service.isMeetingActive ? .primary : .secondary)
                    }
                }
            }

            Section {
                Toggle(s.autoMuteToggle, isOn: $autoMute)
                Text(s.autoMuteCaption).font(.caption).foregroundStyle(.secondary)
            }

            Section(s.watchedAppsTitle) {
                if service.watchedBundleIDs.isEmpty {
                    Text(s.noWatchedApps).font(.caption).foregroundStyle(.secondary)
                } else {
                    ForEach(service.watchedBundleIDs, id: \.self) { bundleID in
                        HStack {
                            Text(bundleID).font(.system(.body, design: .monospaced))
                            Spacer()
                            if service.isMeetingActive,
                               MeetingModeSupport.runningMeetingApp(bundleIDs: [bundleID]) != nil {
                                Text(s.detectedAppLabel)
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        var updated = service.watchedBundleIDs
                        updated.remove(atOffsets: indexSet)
                        service.saveWatchedBundleIDs(updated)
                    }
                }
                Text(s.watchedAppsCaption).font(.caption).foregroundStyle(.secondary)
            }

            Section(s.addAppButton) {
                TextField(s.appBundleIDPlaceholder, text: $draftBundleID)
                    .textFieldStyle(.roundedBorder)
                Button(s.addAppButton) { addApp() }
                    .disabled(draftBundleID.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .formStyle(.grouped)
    }

    private func addApp() {
        let bid = draftBundleID.trimmingCharacters(in: .whitespaces)
        guard !bid.isEmpty, !service.watchedBundleIDs.contains(bid) else { return }
        service.saveWatchedBundleIDs(service.watchedBundleIDs + [bid])
        draftBundleID = ""
    }
}
