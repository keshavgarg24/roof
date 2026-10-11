// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit
import Foundation

struct MenuBarAppInfo: Identifiable, Equatable {
    let id = UUID()
    let bundleID: String
    let name: String
    let icon: NSImage?
    var isHidden: Bool
}

enum MenuBarTidySupport {
    // Discover menu bar extras via NSStatusBar (visible items only — hidden ones require Accessibility or private APIs)
    static func visibleMenuBarApps() -> [MenuBarAppInfo] {
        let running: [NSRunningApplication] = NSWorkspace.shared.runningApplications
        return running
            .filter { $0.activationPolicy == .accessory || $0.activationPolicy == .regular }
            .compactMap { app -> MenuBarAppInfo? in
                guard let bundleID = app.bundleIdentifier,
                      let name = app.localizedName else { return nil }
                let icon = app.icon
                return MenuBarAppInfo(bundleID: bundleID, name: name, icon: icon, isHidden: false)
            }
            .sorted { $0.name < $1.name }
    }

    // Show/hide a menu bar app by hiding or unhiding it
    static func toggleApp(_ app: MenuBarAppInfo) {
        let running: [NSRunningApplication] = NSWorkspace.shared.runningApplications
        let matches = running.filter { $0.bundleIdentifier == app.bundleID }
        if app.isHidden {
            matches.forEach { $0.unhide() }
        } else {
            matches.forEach { $0.hide() }
        }
    }

    static func quitApp(_ bundleID: String) {
        let running: [NSRunningApplication] = NSWorkspace.shared.runningApplications
        running.filter { $0.bundleIdentifier == bundleID }.forEach { $0.terminate() }
    }

    static func encode(_ hidden: [String]) -> Data {
        (try? JSONEncoder().encode(hidden)) ?? Data()
    }

    static func decode(_ data: Data?) -> [String] {
        guard let data, let ids = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return ids
    }
}
