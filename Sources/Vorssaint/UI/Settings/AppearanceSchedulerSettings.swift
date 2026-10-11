// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct AppearanceSchedulerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var appearance = AppAppearanceController.shared
    @AppStorage(DefaultsKey.appearanceSchedulerEnabled) private var enabled = false
    @AppStorage(DefaultsKey.appearanceSchedulerLightModeTime) private var lightTime = "07:00"
    @AppStorage(DefaultsKey.appearanceSchedulerDarkModeTime) private var darkTime = "20:00"

    var body: some View {
        let s = FeatureStrings.appearanceScheduler(l10n.language)
        Form {
            Section {
                Toggle(s.enableToggle, isOn: $enabled)
                    .onChange(of: enabled) { _, _ in
                        AppearanceSchedulerService.shared.syncWithPreferences()
                    }
                Text(s.enableCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if enabled {
                Section(s.scheduleTitle) {
                    LabeledContent(s.lightModeTimeLabel) {
                        TextField("", text: $lightTime,
                                  prompt: Text("07:00"))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .onChange(of: lightTime) { _, _ in
                                AppearanceSchedulerService.shared.syncWithPreferences()
                            }
                    }
                    Text(s.lightModeCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    LabeledContent(s.darkModeTimeLabel) {
                        TextField("", text: $darkTime,
                                  prompt: Text("20:00"))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .onChange(of: darkTime) { _, _ in
                                AppearanceSchedulerService.shared.syncWithPreferences()
                            }
                    }
                    Text(s.darkModeCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    HStack {
                        Text(s.currentModeLabel)
                        Spacer()
                        Text(currentModeLabel(s))
                            .foregroundStyle(.secondary)
                    }
                    Button(s.switchNowButton) {
                        let current = AppAppearanceController.shared.appearance
                        AppAppearanceController.shared.appearance = current == .light ? .dark : .light
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func currentModeLabel(_ s: AppearanceSchedulerStrings) -> String {
        switch appearance.appearance {
        case .light: return s.lightModeTitle
        case .dark: return s.darkModeTitle
        case .system: return s.systemModeTitle
        }
    }
}
