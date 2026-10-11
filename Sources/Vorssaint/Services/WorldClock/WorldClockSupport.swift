// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct WorldClockEntry: Codable, Identifiable, Equatable {
    var id: String { identifier }
    let identifier: String   // TimeZone identifier, e.g. "America/New_York"
    var label: String        // User-visible short name

    init(identifier: String, label: String? = nil) {
        self.identifier = identifier
        self.label = label ?? Self.defaultLabel(for: identifier)
    }

    private static func defaultLabel(for identifier: String) -> String {
        // "America/New_York" → "New York"
        identifier.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier
    }
}

enum WorldClockSupport {
    static func currentTime(for entry: WorldClockEntry) -> String {
        guard let tz = TimeZone(identifier: entry.identifier) else { return "—" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.timeZone = tz
        return formatter.string(from: Date())
    }

    static func offsetString(for entry: WorldClockEntry) -> String {
        guard let tz = TimeZone(identifier: entry.identifier) else { return "" }
        let offset = tz.secondsFromGMT(for: Date())
        let hours = offset / 3600
        let minutes = abs((offset % 3600) / 60)
        if minutes == 0 {
            return String(format: "UTC%+d", hours)
        } else {
            return String(format: "UTC%+d:%02d", hours, minutes)
        }
    }

    static func decode(_ data: Data?) -> [WorldClockEntry] {
        guard let data, !data.isEmpty,
              let entries = try? JSONDecoder().decode([WorldClockEntry].self, from: data) else {
            return []
        }
        return entries
    }

    static func encode(_ entries: [WorldClockEntry]) -> Data {
        (try? JSONEncoder().encode(entries)) ?? Data()
    }

    static func searchTimezones(_ query: String) -> [String] {
        let all = TimeZone.knownTimeZoneIdentifiers
        guard !query.isEmpty else { return all }
        let q = query.lowercased()
        return all.filter { $0.lowercased().contains(q) || $0.replacingOccurrences(of: "_", with: " ").lowercased().contains(q) }
    }
}
