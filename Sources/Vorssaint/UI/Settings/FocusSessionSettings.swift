// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct FocusSessionSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var session = FocusSessionService.shared
    @AppStorage(DefaultsKey.focusSessionWorkMinutes) private var workMinutes = 25
    @AppStorage(DefaultsKey.focusSessionShortBreakMinutes) private var shortBreak = 5
    @AppStorage(DefaultsKey.focusSessionLongBreakMinutes) private var longBreak = 15
    @AppStorage(DefaultsKey.focusSessionCyclesBeforeLong) private var cyclesBeforeLong = 4
    @AppStorage(DefaultsKey.focusSessionNotifyOnComplete) private var notifyOnComplete = true

    var body: some View {
        let s = FeatureStrings.focusSession(l10n.language)
        Form {
            Section {
                timerDisplay(s: s)
                controlButtons(s: s)
            }

            if let phase = session.currentPhase {
                Section {
                    LabeledContent(s.sessionsCompletedLabel) {
                        Text("\(session.cyclesCompleted)").foregroundStyle(.secondary)
                    }
                    LabeledContent("Phase") {
                        Text(FocusSessionSupport.phaseTitle(phase, strings: s))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section(s.configTitle) {
                Stepper(value: $workMinutes, in: 1...120) {
                    LabeledContent(s.workDurationLabel) {
                        Text("\(workMinutes) \(s.minutesSuffix)").foregroundStyle(.secondary)
                    }
                }
                Stepper(value: $shortBreak, in: 1...60) {
                    LabeledContent(s.shortBreakLabel) {
                        Text("\(shortBreak) \(s.minutesSuffix)").foregroundStyle(.secondary)
                    }
                }
                Stepper(value: $longBreak, in: 1...60) {
                    LabeledContent(s.longBreakLabel) {
                        Text("\(longBreak) \(s.minutesSuffix)").foregroundStyle(.secondary)
                    }
                }
                Stepper(value: $cyclesBeforeLong, in: 1...10) {
                    LabeledContent(s.cyclesBeforeLongBreak) {
                        Text("\(cyclesBeforeLong)").foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Toggle(s.notifyOnCompleteToggle, isOn: $notifyOnComplete)
                Text(s.notifyOnCompleteCaption).font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    @ViewBuilder
    private func timerDisplay(s: FocusSessionStrings) -> some View {
        HStack {
            Spacer()
            Text(session.countdownString)
                .font(.system(size: 48, weight: .thin, design: .monospaced))
                .foregroundStyle(timerColor)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func controlButtons(s: FocusSessionStrings) -> some View {
        HStack(spacing: 12) {
            Spacer()
            if case .idle = session.state {
                Button(s.startButton) { session.start() }
                    .buttonStyle(.borderedProminent)
            } else {
                if session.isRunning {
                    Button(s.pauseButton) { session.pause() }
                        .buttonStyle(.bordered)
                } else {
                    Button(s.resumeButton) { session.resume() }
                        .buttonStyle(.bordered)
                }
                Button(s.stopButton) { session.stop() }
                    .buttonStyle(.bordered)
                    .tint(.red)
            }
            Spacer()
        }
    }

    private var timerColor: Color {
        guard let phase = session.currentPhase else { return .secondary }
        switch phase {
        case .work: return .primary
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}
