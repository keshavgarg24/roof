// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit
import Foundation

struct RelaunchableApp: Identifiable, Equatable {
    let id: String           // bundle identifier
    let name: String
    let bundleURL: URL
    let isFrontmost: Bool

    static func == (lhs: RelaunchableApp, rhs: RelaunchableApp) -> Bool {
        lhs.id == rhs.id
    }
}

enum AppRelauncherSupport {
    static func runningApps() -> [RelaunchableApp] {
        let frontmost = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        return NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> RelaunchableApp? in
                guard let bid = app.bundleIdentifier,
                      let url = app.bundleURL,
                      let name = app.localizedName else { return nil }
                return RelaunchableApp(id: bid, name: name, bundleURL: url,
                                       isFrontmost: bid == frontmost)
            }
            .sorted { $0.isFrontmost && !$1.isFrontmost || $0.name < $1.name }
    }

    /// Terminates all instances of the app then relaunches it.
    static func relaunch(_ app: RelaunchableApp, clearPrefs: Bool) {
        let bundleURL = app.bundleURL
        let bundleID = app.id
        let running = NSWorkspace.shared.runningApplications.filter {
            $0.bundleIdentifier == bundleID
        }
        for instance in running {
            instance.terminate()
        }
        if clearPrefs {
            deletePreferences(for: bundleID)
        }
        // Wait briefly for termination then relaunch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NSWorkspace.shared.openApplication(at: bundleURL,
                                               configuration: .init())
        }
    }

    private static func deletePreferences(for bundleID: String) {
        let prefsDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Preferences")
        let plist = prefsDir.appendingPathComponent("\(bundleID).plist")
        try? FileManager.default.removeItem(at: plist)
    }
}
