// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import AppKit

struct AppLimit: Codable, Identifiable {
    let id: UUID
    var bundleID: String
    var appName: String
    var dailyLimitMinutes: Int
    var usedSeconds: Int
    var lastResetDate: String

    var usedMinutes: Int { usedSeconds / 60 }
    var isOverLimit: Bool { usedMinutes >= dailyLimitMinutes }
    var progressFraction: Double {
        guard dailyLimitMinutes > 0 else { return 0 }
        return min(1.0, Double(usedMinutes) / Double(dailyLimitMinutes))
    }
}

enum AppTimerSupport {
    static let todayKey: String = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }()

    static func runningApps() -> [(bundleID: String, name: String)] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app in
                guard let id = app.bundleIdentifier,
                      let name = app.localizedName else { return nil }
                return (id, name)
            }
    }

    static func encode(_ limits: [AppLimit]) -> Data {
        (try? JSONEncoder().encode(limits)) ?? Data()
    }

    static func decode(_ data: Data) -> [AppLimit] {
        (try? JSONDecoder().decode([AppLimit].self, from: data)) ?? []
    }
}
