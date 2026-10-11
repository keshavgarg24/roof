// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit
import Foundation
import UserNotifications

struct NotificationRecord: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    let appBundleID: String
    let appName: String
    let date: Date
    var isPinned: Bool = false
}

enum NotificationHistorySupport {
    static func decode(_ data: Data?) -> [NotificationRecord] {
        guard let data, let records = try? JSONDecoder().decode([NotificationRecord].self, from: data) else { return [] }
        return records
    }

    static func encode(_ records: [NotificationRecord]) -> Data {
        (try? JSONEncoder().encode(records)) ?? Data()
    }

    static func appName(for bundleID: String) -> String {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)?
            .deletingPathExtension().lastPathComponent ?? bundleID
    }

    static func groupedByDay(_ records: [NotificationRecord]) -> [(label: String, records: [NotificationRecord])] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        var groups: [(Date, [NotificationRecord])] = []
        for record in records.sorted(by: { $0.date > $1.date }) {
            let day = calendar.startOfDay(for: record.date)
            if let idx = groups.firstIndex(where: { calendar.isDate($0.0, inSameDayAs: day) }) {
                groups[idx].1.append(record)
            } else {
                groups.append((day, [record]))
            }
        }
        return groups.map { (day, recs) in
            let label: String
            if calendar.isDateInToday(day) { label = "Today" }
            else if calendar.isDateInYesterday(day) { label = "Yesterday" }
            else { label = formatter.string(from: day) }
            return (label, recs)
        }
    }
}
