// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

enum FocusPhase: String, Equatable {
    case work
    case shortBreak
    case longBreak
}

enum FocusSessionSupport {
    static func phaseTitle(_ phase: FocusPhase, strings: FocusSessionStrings) -> String {
        switch phase {
        case .work: return strings.workPhaseTitle
        case .shortBreak: return strings.shortBreakTitle
        case .longBreak: return strings.longBreakTitle
        }
    }

    static func nextPhase(after phase: FocusPhase,
                           cyclesCompleted: Int,
                           cyclesBeforeLongBreak: Int) -> FocusPhase {
        switch phase {
        case .work:
            return cyclesCompleted > 0 && cyclesCompleted % cyclesBeforeLongBreak == 0
                ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            return .work
        }
    }

    static func duration(for phase: FocusPhase,
                          workMinutes: Int,
                          shortBreakMinutes: Int,
                          longBreakMinutes: Int) -> TimeInterval {
        switch phase {
        case .work: return TimeInterval(workMinutes * 60)
        case .shortBreak: return TimeInterval(shortBreakMinutes * 60)
        case .longBreak: return TimeInterval(longBreakMinutes * 60)
        }
    }

    static func formatCountdown(_ seconds: Int) -> String {
        let m = max(0, seconds) / 60
        let s = max(0, seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
