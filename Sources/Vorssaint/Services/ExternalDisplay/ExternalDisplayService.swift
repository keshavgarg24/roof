// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

final class ExternalDisplayService: ObservableObject {
    static let shared = ExternalDisplayService()
    private init() {}

    @Published private(set) var displays: [DisplayInfo] = []

    func syncWithPreferences() {}

    func refresh() {
        displays = ExternalDisplaySupport.connectedDisplays()
    }

    func setBrightness(_ value: Float, for display: DisplayInfo) {
        if !display.isBuiltIn {
            ExternalDisplaySupport.setBrightness(value, for: display.id)
        }
        if let idx = displays.firstIndex(where: { $0.id == display.id }) {
            displays[idx].brightness = value
        }
    }

    func setVolume(_ value: Int, for display: DisplayInfo) {
        ExternalDisplaySupport.setVolume(value, for: display.id)
        if let idx = displays.firstIndex(where: { $0.id == display.id }) {
            displays[idx].volume = value
        }
    }

    func setContrast(_ value: Int, for display: DisplayInfo) {
        ExternalDisplaySupport.setContrast(value, for: display.id)
        if let idx = displays.firstIndex(where: { $0.id == display.id }) {
            displays[idx].contrast = value
        }
    }
}
