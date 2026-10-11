// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit

/// Lists running regular apps and relaunches them on demand.
final class AppRelauncherService: ObservableObject {
    static let shared = AppRelauncherService()

    @Published private(set) var apps: [RelaunchableApp] = []
    @Published private(set) var isLoading = false
    @Published var clearPrefsOnRelaunch = false

    private init() {}

    func syncWithPreferences() {}

    @MainActor
    func refresh() {
        isLoading = true
        Task.detached(priority: .userInitiated) {
            let list = AppRelauncherSupport.runningApps()
            await MainActor.run { [weak self] in
                self?.apps = list
                self?.isLoading = false
            }
        }
    }

    func relaunch(_ app: RelaunchableApp) {
        AppRelauncherSupport.relaunch(app, clearPrefs: clearPrefsOnRelaunch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.refresh()
        }
    }

    func relaunchFrontmost() {
        guard let app = apps.first(where: \.isFrontmost) else { return }
        relaunch(app)
    }
}
