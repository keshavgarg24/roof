// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

/// Manages user-defined window size presets and applies them to the focused window.
final class WindowResizerService: ObservableObject {
    static let shared = WindowResizerService()

    @Published private(set) var customPresets: [WindowResizerPreset] = []

    var allPresets: [WindowResizerPreset] {
        WindowResizerSupport.builtInPresets + customPresets
    }

    private init() {
        load()
    }

    func syncWithPreferences() {
        load()
    }

    private func load() {
        customPresets = WindowResizerSupport.decode(
            UserDefaults.standard.data(forKey: DefaultsKey.windowResizerCustomPresets))
    }

    func saveCustomPresets(_ presets: [WindowResizerPreset]) {
        customPresets = presets
        UserDefaults.standard.set(WindowResizerSupport.encode(presets),
                                  forKey: DefaultsKey.windowResizerCustomPresets)
    }

    @discardableResult
    func apply(preset: WindowResizerPreset) -> Bool {
        WindowResizerSupport.resizeFrontmostWindow(width: preset.width, height: preset.height)
    }

    @discardableResult
    func apply(width: Int, height: Int) -> Bool {
        WindowResizerSupport.resizeFrontmostWindow(width: width, height: height)
    }
}
