// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct PackageTrackerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = PackageTrackerService.shared
    @State private var searchQuery = ""

    private var s: PackageTrackerStrings { FeatureStrings.packageTracker(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    Picker(s.versionLabel, selection: $svc.selectedSource) {
                        ForEach(PackageSource.allCases) { src in
                            Text(src.rawValue).tag(src)
                        }
                    }
                    .pickerStyle(.segmented)
                    Button(s.refreshButton) { svc.fetch() }.disabled(svc.isFetching)
                }
                TextField(s.searchPlaceholder, text: $searchQuery).textFieldStyle(.roundedBorder)
            }

            if svc.isFetching {
                Section {
                    HStack { ProgressView(); Text(s.loadingLabel).foregroundStyle(.secondary) }
                }
            } else {
                Section("\(s.pageTitle) (\(filtered.count))") {
                    if filtered.isEmpty {
                        Text(s.noPackagesCaption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                    } else {
                        ForEach(filtered) { pkg in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pkg.name)
                                    Text(pkg.source.rawValue).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if pkg.hasUpdate {
                                    Label(s.updateAvailableLabel, systemImage: "arrow.up.circle.fill")
                                        .font(.caption).foregroundStyle(.orange)
                                }
                                Text(pkg.installedVersion).font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { if svc.packages.isEmpty { svc.fetch() } }
    }

    private var filtered: [PackageInfo] {
        guard !searchQuery.isEmpty else { return svc.filteredPackages }
        return svc.filteredPackages.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }
}
