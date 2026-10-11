// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation
import SwiftUI

final class TimeTrackerService: ObservableObject {
    static let shared = TimeTrackerService()
    private init() {}

    @AppStorage("timeTracker.entries") private var entriesData: Data = Data()
    @Published private(set) var entries: [TimeEntry] = []
    @Published private(set) var activeEntry: TimeEntry?
    private var ticker: Timer?

    func syncWithPreferences() {
        entries = TimeTrackerSupport.decode(entriesData.isEmpty ? nil : entriesData)
        activeEntry = entries.first(where: \.isRunning)
        if activeEntry != nil { startTicker() }
    }

    func start(project: String, task: String) {
        stopActive()
        let entry = TimeEntry(project: project, task: task)
        entries.insert(entry, at: 0)
        activeEntry = entries.first
        save()
        startTicker()
    }

    func stopActive() {
        guard let active = activeEntry else { return }
        if let idx = entries.firstIndex(where: { $0.id == active.id }) {
            entries[idx].endDate = Date()
        }
        activeEntry = nil
        ticker?.invalidate(); ticker = nil
        save()
    }

    func delete(id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    private func save() {
        entriesData = TimeTrackerSupport.encode(entries)
    }

    var projectSummary: [(project: String, total: TimeInterval)] {
        TimeTrackerSupport.projectSummary(entries: entries)
    }

    var todayTotal: TimeInterval {
        let start = Calendar.current.startOfDay(for: Date())
        return TimeTrackerSupport.totalDuration(entries: entries, since: start)
    }
}
