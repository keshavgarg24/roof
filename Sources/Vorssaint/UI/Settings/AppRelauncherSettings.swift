// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct AppRelauncherSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var service = AppRelauncherService.shared
    @State private var showingConfirm = false
    @State private var pendingApp: RelaunchableApp?

    var body: some View {
        let s = FeatureStrings.appRelauncher(l10n.language)
        Form {
            Section {
                HStack {
                    Text(s.pageTitle).font(.headline)
                    Spacer()
                    Button {
                        Task { service.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
                }
                Toggle(s.clearPrefsToggle, isOn: $service.clearPrefsOnRelaunch)
                Text(s.clearPrefsCaption).font(.caption).foregroundStyle(.secondary)
            }

            Section(s.runningAppsTitle) {
                if service.isLoading {
                    HStack {
                        ProgressView().scaleEffect(0.7)
                        Text("Loading…").foregroundStyle(.secondary)
                    }
                } else if service.apps.isEmpty {
                    Text(s.noRunningApps).font(.caption).foregroundStyle(.secondary)
                } else {
                    ForEach(service.apps) { app in
                        appRow(app, s: s)
                    }
                }
                Text(s.runningAppsCaption).font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .task {
            service.refresh()
        }
        .confirmationDialog(s.confirmClearPrefs,
                            isPresented: $showingConfirm,
                            titleVisibility: .visible) {
            Button("Relaunch", role: .destructive) {
                if let app = pendingApp { service.relaunch(app) }
                pendingApp = nil
            }
            Button("Cancel", role: .cancel) { pendingApp = nil }
        }
    }

    private func appRow(_ app: RelaunchableApp, s: AppRelauncherStrings) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(app.name).font(.body)
                    if app.isFrontmost {
                        Text(s.frontmostLabel)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(app.id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button(s.relaunchButton) {
                if service.clearPrefsOnRelaunch {
                    pendingApp = app
                    showingConfirm = true
                } else {
                    service.relaunch(app)
                }
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
    }
}
