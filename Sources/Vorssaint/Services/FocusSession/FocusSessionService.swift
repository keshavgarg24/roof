// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit
import UserNotifications

/// Manages a Pomodoro-style focus timer with work and break cycles.
final class FocusSessionService: ObservableObject {
    static let shared = FocusSessionService()

    enum State: Equatable {
        case idle
        case running(phase: FocusPhase, secondsRemaining: Int)
        case paused(phase: FocusPhase, secondsRemaining: Int)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var cyclesCompleted = 0

    private var timer: Timer?

    private var workMinutes: Int { UserDefaults.standard.integer(forKey: DefaultsKey.focusSessionWorkMinutes).nonZero(fallback: 25) }
    private var shortBreakMinutes: Int { UserDefaults.standard.integer(forKey: DefaultsKey.focusSessionShortBreakMinutes).nonZero(fallback: 5) }
    private var longBreakMinutes: Int { UserDefaults.standard.integer(forKey: DefaultsKey.focusSessionLongBreakMinutes).nonZero(fallback: 15) }
    private var cyclesBeforeLongBreak: Int { UserDefaults.standard.integer(forKey: DefaultsKey.focusSessionCyclesBeforeLong).nonZero(fallback: 4) }

    private init() {}

    func syncWithPreferences() {}

    func start() {
        guard case .idle = state else { return }
        cyclesCompleted = 0
        beginPhase(.work)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        state = .idle
    }

    func pause() {
        guard case .running(let phase, let secs) = state else { return }
        timer?.invalidate()
        timer = nil
        state = .paused(phase: phase, secondsRemaining: secs)
    }

    func resume() {
        guard case .paused(let phase, let secs) = state else { return }
        state = .running(phase: phase, secondsRemaining: secs)
        scheduleTimer()
    }

    private func beginPhase(_ phase: FocusPhase) {
        let secs = Int(FocusSessionSupport.duration(
            for: phase,
            workMinutes: workMinutes,
            shortBreakMinutes: shortBreakMinutes,
            longBreakMinutes: longBreakMinutes))
        state = .running(phase: phase, secondsRemaining: secs)
        scheduleTimer()
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard case .running(let phase, let secs) = state else { return }
        if secs <= 1 {
            phaseCompleted(phase)
        } else {
            state = .running(phase: phase, secondsRemaining: secs - 1)
        }
    }

    private func phaseCompleted(_ phase: FocusPhase) {
        timer?.invalidate()
        timer = nil
        if phase == .work { cyclesCompleted += 1 }
        let notify = UserDefaults.standard.bool(forKey: DefaultsKey.focusSessionNotifyOnComplete)
        if notify { sendNotification(for: phase) }
        let next = FocusSessionSupport.nextPhase(after: phase,
                                                  cyclesCompleted: cyclesCompleted,
                                                  cyclesBeforeLongBreak: cyclesBeforeLongBreak)
        beginPhase(next)
    }

    private func sendNotification(for completedPhase: FocusPhase) {
        let content = UNMutableNotificationContent()
        let s = FeatureStrings.focusSession(L10n.shared.language)
        switch completedPhase {
        case .work:
            content.title = s.workPhaseTitle
            content.body = "Time for a break!"
        case .shortBreak, .longBreak:
            content.title = completedPhase == .shortBreak ? s.shortBreakTitle : s.longBreakTitle
            content.body = "Break over — back to focus."
        }
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                             content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    var countdownString: String {
        switch state {
        case .idle: return "00:00"
        case .running(_, let secs), .paused(_, let secs):
            return FocusSessionSupport.formatCountdown(secs)
        }
    }

    var currentPhase: FocusPhase? {
        switch state {
        case .idle: return nil
        case .running(let p, _), .paused(let p, _): return p
        }
    }

    var isRunning: Bool {
        if case .running = state { return true }
        return false
    }

    var isPaused: Bool {
        if case .paused = state { return true }
        return false
    }
}

private extension Int {
    func nonZero(fallback: Int) -> Int { self <= 0 ? fallback : self }
}
