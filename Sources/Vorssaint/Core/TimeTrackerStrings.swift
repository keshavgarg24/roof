// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct TimeTrackerStrings {
    let pageTitle: String
    let hubDescription: String
    let startButton: String
    let stopButton: String
    let newEntryButton: String
    let projectLabel: String
    let taskLabel: String
    let durationLabel: String
    let todayLabel: String
    let weekLabel: String
    let exportButton: String
    let noEntriesCaption: String
    let runningLabel: String
    let totalTodayLabel: String
    let totalWeekLabel: String
    let commandBarStart: String
    let commandBarStop: String

    static let enUS = TimeTrackerStrings(
        pageTitle: "Time Tracker",
        hubDescription: "Track time on any project from the menu bar — daily and weekly summaries built in.",
        startButton: "Start",
        stopButton: "Stop",
        newEntryButton: "New Entry",
        projectLabel: "Project",
        taskLabel: "Task",
        durationLabel: "Duration",
        todayLabel: "Today",
        weekLabel: "This Week",
        exportButton: "Export CSV",
        noEntriesCaption: "No time entries yet.",
        runningLabel: "Running",
        totalTodayLabel: "Today",
        totalWeekLabel: "This Week",
        commandBarStart: "Start Time Tracking",
        commandBarStop: "Stop Time Tracking"
    )
}

extension FeatureStrings {
    static func timeTracker(_ language: AppLanguage) -> TimeTrackerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
