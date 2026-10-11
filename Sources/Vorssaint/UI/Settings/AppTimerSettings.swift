// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct AppTimerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = AppTimerService.shared
    @State private var showAdd = false
    @State private var newApp: String = ""
    @State private var newLimit: Int = 60

    private var s: AppTimerStrings { FeatureStrings.appTimer(l10n.language) }

    var body: some View {
        Form {
            Section {
                Toggle(s.enabledLabel, isOn: $svc.enabled)
                    .onChange(of: svc.enabled) { _ in svc.syncWithPreferences() }
                Text(s.resetDailyLabel).font(.caption).foregroundStyle(.secondary)
            }

            Section(s.pageTitle) {
                if svc.limits.isEmpty {
                    Text(s.noLimitsCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                } else {
                    ForEach(svc.limits) { limit in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(limit.appName)
                                ProgressView(value: limit.progressFraction)
                                    .tint(limit.isOverLimit ? .red : .blue)
                                Text("\(s.usedTodayLabel): \(limit.usedMinutes) / \(limit.dailyLimitMinutes) \(s.minutesSuffix)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(s.deleteLimitButton, role: .destructive) { svc.remove(limit) }
                                .buttonStyle(.borderless)
                                .foregroundStyle(.red)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Button(s.addLimitButton) { showAdd = true }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showAdd) {
            addSheet
        }
    }

    private var addSheet: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(s.addLimitButton).font(.headline)

            Picker(s.appLabel, selection: $newApp) {
                ForEach(AppTimerSupport.runningApps(), id: \.bundleID) { app in
                    Text(app.name).tag(app.bundleID)
                }
            }

            Stepper(value: $newLimit, in: 5...480, step: 5) {
                Text("\(s.dailyLimitLabel): \(newLimit)")
            }

            HStack {
                Button("Cancel") { showAdd = false }
                Spacer()
                Button("Add") {
                    let apps = AppTimerSupport.runningApps()
                    if let app = apps.first(where: { $0.bundleID == newApp }) {
                        svc.addLimit(bundleID: app.bundleID, appName: app.name, dailyMinutes: newLimit)
                    }
                    showAdd = false
                }
                .disabled(newApp.isEmpty)
            }
        }
        .padding(20)
        .frame(minWidth: 320)
        .onAppear {
            newApp = AppTimerSupport.runningApps().first?.bundleID ?? ""
        }
    }
}
