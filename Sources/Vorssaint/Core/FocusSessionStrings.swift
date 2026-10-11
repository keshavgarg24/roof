// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct FocusSessionStrings {
    let pageTitle: String
    let hubDescription: String
    let startButton: String
    let stopButton: String
    let pauseButton: String
    let resumeButton: String
    let workDurationLabel: String
    let shortBreakLabel: String
    let longBreakLabel: String
    let cyclesBeforeLongBreak: String
    let workPhaseTitle: String
    let shortBreakTitle: String
    let longBreakTitle: String
    let sessionsCompletedLabel: String
    let statusIdle: String
    let minutesSuffix: String
    let configTitle: String
    let notifyOnCompleteToggle: String
    let notifyOnCompleteCaption: String

    static let enUS = FocusSessionStrings(
        pageTitle: "Focus Session",
        hubDescription: "Pomodoro-style focus timer with work and break cycles.",
        startButton: "Start Session",
        stopButton: "Stop",
        pauseButton: "Pause",
        resumeButton: "Resume",
        workDurationLabel: "Work duration",
        shortBreakLabel: "Short break",
        longBreakLabel: "Long break",
        cyclesBeforeLongBreak: "Cycles before long break",
        workPhaseTitle: "Focus",
        shortBreakTitle: "Short Break",
        longBreakTitle: "Long Break",
        sessionsCompletedLabel: "Sessions completed",
        statusIdle: "Ready to focus",
        minutesSuffix: "min",
        configTitle: "Configuration",
        notifyOnCompleteToggle: "Notify on phase completion",
        notifyOnCompleteCaption: "Show a notification when a work or break phase ends."
    )
}

extension FeatureStrings {
    static func focusSession(_ language: AppLanguage) -> FocusSessionStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
