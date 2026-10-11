// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct TimeTrackerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = TimeTrackerService.shared
    @State private var project = ""
    @State private var task = ""

    private var s: TimeTrackerStrings { FeatureStrings.timeTracker(l10n.language) }

    var body: some View {
        Form {
            Section(s.runningLabel) {
                if let active = svc.activeEntry {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(active.project.isEmpty ? s.projectLabel : active.project).fontWeight(.medium)
                            Text(active.task.isEmpty ? s.taskLabel : active.task).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(active.formattedDuration).font(.title3.monospaced()).foregroundStyle(.green)
                        Button(s.stopButton, role: .destructive) { svc.stopActive() }
                    }
                } else {
                    HStack {
                        TextField(s.projectLabel, text: $project)
                        TextField(s.taskLabel, text: $task)
                        Button(s.startButton) {
                            svc.start(project: project, task: task)
                            project = ""; task = ""
                        }
                    }
                }
            }

            Section(s.totalTodayLabel) {
                HStack {
                    Text(s.todayLabel)
                    Spacer()
                    Text(TimeTrackerSupport.formatDuration(svc.todayTotal)).font(.caption.monospaced())
                }
                ForEach(svc.projectSummary.prefix(5), id: \.project) { item in
                    HStack {
                        Text(item.project.isEmpty ? s.projectLabel : item.project)
                        Spacer()
                        Text(TimeTrackerSupport.formatDuration(item.total)).font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                }
            }

            Section(s.pageTitle) {
                if svc.entries.isEmpty {
                    Text(s.noEntriesCaption).foregroundStyle(.secondary)
                } else {
                    ForEach(svc.entries.prefix(10)) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.project.isEmpty ? s.projectLabel : entry.project)
                                Text(entry.task.isEmpty ? s.taskLabel : entry.task).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(entry.formattedDuration).font(.caption.monospaced())
                            if entry.isRunning {
                                Image(systemName: "circle.fill").foregroundStyle(.green).font(.caption2)
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
