// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit
import Foundation

struct SavedWindow: Codable, Equatable {
    let appBundleID: String
    let appName: String
    let frame: CGRect
    let isMinimized: Bool
    let title: String
}

struct WindowLayoutSession: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var savedAt: Date
    var windows: [SavedWindow]
    var appCount: Int { Set(windows.map(\.appBundleID)).count }
}

enum WindowSessionSupport {
    static func captureCurrentLayout() -> [SavedWindow] {
        var results: [SavedWindow] = []
        guard AXIsProcessTrusted() else { return [] }
        let options = CGWindowListOption([.optionOnScreenOnly, .excludeDesktopElements])
        guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else { return [] }
        for info in list {
            guard let pid = info[kCGWindowOwnerPID as String] as? Int32,
                  let bounds = info[kCGWindowBounds as String] as? [String: CGFloat],
                  let title = info[kCGWindowName as String] as? String else { continue }
            let app = NSRunningApplication(processIdentifier: pid)
            guard let bundleID = app?.bundleIdentifier, let appName = app?.localizedName else { continue }
            let frame = CGRect(x: bounds["X"] ?? 0, y: bounds["Y"] ?? 0, width: bounds["Width"] ?? 0, height: bounds["Height"] ?? 0)
            results.append(SavedWindow(appBundleID: bundleID, appName: appName, frame: frame, isMinimized: false, title: title))
        }
        return results
    }

    static func restoreLayout(_ session: WindowLayoutSession) {
        guard AXIsProcessTrusted() else { return }
        for window in session.windows {
            guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: window.appBundleID).first else { continue }
            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            var windowsRef: AnyObject?
            AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef)
            guard let axWindows = windowsRef as? [AXUIElement] else { continue }
            for axWin in axWindows {
                var titleRef: AnyObject?
                AXUIElementCopyAttributeValue(axWin, kAXTitleAttribute as CFString, &titleRef)
                if titleRef as? String == window.title {
                    var pos = window.frame.origin
                    var size = window.frame.size
                    if let posVal = AXValueCreate(.cgPoint, &pos),
                       let sizeVal = AXValueCreate(.cgSize, &size) {
                        AXUIElementSetAttributeValue(axWin, kAXPositionAttribute as CFString, posVal)
                        AXUIElementSetAttributeValue(axWin, kAXSizeAttribute as CFString, sizeVal)
                    }
                    break
                }
            }
        }
    }

    static func decode(_ data: Data?) -> [WindowLayoutSession] {
        guard let data, let sessions = try? JSONDecoder().decode([WindowLayoutSession].self, from: data) else { return [] }
        return sessions
    }

    static func encode(_ sessions: [WindowLayoutSession]) -> Data {
        (try? JSONEncoder().encode(sessions)) ?? Data()
    }
}
