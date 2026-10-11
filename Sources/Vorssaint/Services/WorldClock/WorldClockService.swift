// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

final class WorldClockService: ObservableObject {
    static let shared = WorldClockService()

    @Published private(set) var entries: [WorldClockEntry] = []

    private init() {
        load()
    }

    func syncWithPreferences() {
        load()
    }

    func saveEntries(_ newEntries: [WorldClockEntry]) {
        entries = newEntries
        UserDefaults.standard.set(WorldClockSupport.encode(newEntries),
                                  forKey: DefaultsKey.worldClockEntries)
    }

    private func load() {
        let saved = WorldClockSupport.decode(
            UserDefaults.standard.data(forKey: DefaultsKey.worldClockEntries))
        entries = saved.isEmpty ? defaultEntries() : saved
    }

    private func defaultEntries() -> [WorldClockEntry] {
        ["America/New_York", "Europe/London", "Asia/Tokyo"].map { WorldClockEntry(identifier: $0) }
    }
}
