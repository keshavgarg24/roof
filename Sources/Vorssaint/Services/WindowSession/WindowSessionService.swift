// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import SwiftUI

final class WindowSessionService: ObservableObject {
    static let shared = WindowSessionService()
    private init() {}

    @AppStorage("windowSession.sessions") private var sessionsData: Data = Data()
    @Published private(set) var sessions: [WindowLayoutSession] = []

    func syncWithPreferences() {
        sessions = WindowSessionSupport.decode(sessionsData.isEmpty ? nil : sessionsData)
    }

    func saveCurrentLayout(name: String) {
        let windows = WindowSessionSupport.captureCurrentLayout()
        let session = WindowLayoutSession(name: name.isEmpty ? "Layout \(sessions.count + 1)" : name,
                                          savedAt: Date(), windows: windows)
        sessions.insert(session, at: 0)
        save()
    }

    func restore(_ session: WindowLayoutSession) {
        WindowSessionSupport.restoreLayout(session)
    }

    func delete(id: UUID) {
        sessions.removeAll { $0.id == id }
        save()
    }

    private func save() { sessionsData = WindowSessionSupport.encode(sessions) }
}
