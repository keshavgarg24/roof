// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct MenuBarTidySettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = MenuBarTidyService.shared

    private var s: MenuBarTidyStrings { FeatureStrings.menuBarTidy(l10n.language) }

    var body: some View {
        Form {
            Section(s.visibleSection) {
                if svc.apps.isEmpty {
                    Text(s.noItemsCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)
                } else {
                    ForEach(svc.apps) { app in
                        HStack(spacing: 10) {
                            if let icon = app.icon {
                                Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                            }
                            Text(app.name)
                            Spacer()
                            Button(s.hideButton) { svc.toggle(app) }
                                .buttonStyle(.borderless)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                Text(s.instructionsCaption).font(.caption).foregroundStyle(.secondary)
                Button(s.refreshButton) { svc.refresh() }
            }
        }
        .formStyle(.grouped)
        .onAppear { svc.refresh() }
    }
}
