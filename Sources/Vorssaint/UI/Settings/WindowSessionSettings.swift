// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct WindowSessionSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = WindowSessionService.shared
    @State private var newName = ""

    private var s: WindowSessionStrings { FeatureStrings.windowSession(l10n.language) }

    var body: some View {
        Form {
            Section {
                if !AXIsProcessTrusted() {
                    Label(s.accessibilityNeeded, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            Section(s.saveCurrentButton) {
                HStack {
                    TextField(s.sessionNameLabel, text: $newName)
                    Button(s.saveButton) {
                        svc.saveCurrentLayout(name: newName.isEmpty ? s.newSessionName : newName)
                        newName = ""
                    }
                }
            }

            Section(s.pageTitle) {
                if svc.sessions.isEmpty {
                    Text(s.noSessionsCaption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                } else {
                    ForEach(svc.sessions) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.name)
                                Text("\(session.appCount) \(s.appsLabel) · " + session.savedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(s.restoreButton) { svc.restore(session) }.buttonStyle(.borderless)
                            Button(s.deleteButton, role: .destructive) { svc.delete(id: session.id) }
                                .buttonStyle(.borderless).foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
