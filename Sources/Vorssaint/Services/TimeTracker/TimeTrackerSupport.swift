// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct TimeEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var project: String
    var task: String
    var startDate: Date
    var endDate: Date?
    var duration: TimeInterval { (endDate ?? Date()).timeIntervalSince(startDate) }
    var isRunning: Bool { endDate == nil }

    init(project: String = "", task: String = "", startDate: Date = Date()) {
        self.id = UUID()
        self.project = project
        self.task = task
        self.startDate = startDate
    }

    var formattedDuration: String { TimeTrackerSupport.formatDuration(duration) }
}

enum TimeTrackerSupport {
    static func decode(_ data: Data?) -> [TimeEntry] {
        guard let data, let entries = try? JSONDecoder().decode([TimeEntry].self, from: data) else { return [] }
        return entries
    }

    static func encode(_ entries: [TimeEntry]) -> Data {
        (try? JSONEncoder().encode(entries)) ?? Data()
    }

    static func formatDuration(_ interval: TimeInterval) -> String {
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        let s = Int(interval) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    static func totalDuration(entries: [TimeEntry], since: Date) -> TimeInterval {
        entries.filter { $0.startDate >= since }.reduce(0) { $0 + $1.duration }
    }

    static func projectSummary(entries: [TimeEntry]) -> [(project: String, total: TimeInterval)] {
        var totals: [String: TimeInterval] = [:]
        for entry in entries { totals[entry.project, default: 0] += entry.duration }
        return totals.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
    }

    static func exportCSV(_ entries: [TimeEntry]) -> String {
        var lines = ["Project,Task,Start,End,Duration"]
        let fmt = ISO8601DateFormatter()
        for entry in entries {
            let end = entry.endDate.map { fmt.string(from: $0) } ?? "running"
            lines.append("\"\(entry.project)\",\"\(entry.task)\",\(fmt.string(from: entry.startDate)),\(end),\(formatDuration(entry.duration))")
        }
        return lines.joined(separator: "\n")
    }
}
