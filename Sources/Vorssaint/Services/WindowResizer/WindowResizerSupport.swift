// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit
import Foundation

struct WindowResizerPreset: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var width: Int
    var height: Int

    init(id: UUID = UUID(), name: String, width: Int, height: Int) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
    }
}

enum WindowResizerSupport {
    static let builtInPresets: [WindowResizerPreset] = [
        WindowResizerPreset(name: "iPhone SE (375×667)", width: 375, height: 667),
        WindowResizerPreset(name: "iPhone 15 Pro (393×852)", width: 393, height: 852),
        WindowResizerPreset(name: "iPad (768×1024)", width: 768, height: 1024),
        WindowResizerPreset(name: "HD (1280×720)", width: 1280, height: 720),
        WindowResizerPreset(name: "Full HD (1920×1080)", width: 1920, height: 1080),
        WindowResizerPreset(name: "MacBook Air 13\" (1440×900)", width: 1440, height: 900),
    ]

    /// Resize the frontmost application's focused window using AXUIElement.
    /// Returns true on success.
    @discardableResult
    static func resizeFrontmostWindow(width: Int, height: Int) -> Bool {
        guard let app = NSWorkspace.shared.frontmostApplication else { return false }
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        var focusedWindow: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString,
                                             &focusedWindow) == .success,
              let window = focusedWindow else { return false }

        var size = CGSize(width: width, height: height)
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window as! AXUIElement,
                                         kAXSizeAttribute as CFString, sizeValue)
        }
        return true
    }

    static func decode(_ data: Data?) -> [WindowResizerPreset] {
        guard let data, !data.isEmpty,
              let presets = try? JSONDecoder().decode([WindowResizerPreset].self, from: data) else {
            return []
        }
        return presets
    }

    static func encode(_ presets: [WindowResizerPreset]) -> Data {
        (try? JSONEncoder().encode(presets)) ?? Data()
    }
}
