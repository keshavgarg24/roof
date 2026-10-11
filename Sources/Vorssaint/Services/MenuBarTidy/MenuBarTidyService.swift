// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

final class MenuBarTidyService: ObservableObject {
    static let shared = MenuBarTidyService()
    private init() {}

    @Published private(set) var apps: [MenuBarAppInfo] = []

    func syncWithPreferences() {}

    func refresh() {
        apps = MenuBarTidySupport.visibleMenuBarApps()
    }

    func toggle(_ app: MenuBarAppInfo) {
        MenuBarTidySupport.toggleApp(app)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.refresh() }
    }

    func quit(_ app: MenuBarAppInfo) {
        MenuBarTidySupport.quitApp(app.bundleID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.refresh() }
    }
}
