// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit
import Foundation

final class ColorConverterService: ObservableObject {
    static let shared = ColorConverterService()

    @Published var hexInput = "#3A86FF"
    @Published private(set) var rgb = RGBColor(r: 58, g: 134, b: 255, a: 1)
    @Published private(set) var hsl = HSLColor(h: 217.8, s: 100, l: 61.4, a: 1)
    @Published private(set) var hsb = HSBColor(h: 217.8, s: 77.3, b: 100, a: 1)

    private init() { applyHex(hexInput) }

    func syncWithPreferences() {}

    func applyHex(_ hex: String) {
        guard let parsed = ColorConverterSupport.parseHex(hex) else { return }
        rgb = parsed
        hsl = ColorConverterSupport.rgbToHSL(parsed)
        hsb = ColorConverterSupport.rgbToHSB(parsed)
        hexInput = ColorConverterSupport.toHex(parsed)
    }

    func applyRGB(_ newRGB: RGBColor) {
        rgb = newRGB
        hsl = ColorConverterSupport.rgbToHSL(newRGB)
        hsb = ColorConverterSupport.rgbToHSB(newRGB)
        hexInput = ColorConverterSupport.toHex(newRGB)
    }

    func applyHSL(_ newHSL: HSLColor) {
        hsl = newHSL
        rgb = ColorConverterSupport.hslToRGB(newHSL)
        hsb = ColorConverterSupport.rgbToHSB(rgb)
        hexInput = ColorConverterSupport.toHex(rgb)
    }

    func applyHSB(_ newHSB: HSBColor) {
        hsb = newHSB
        rgb = ColorConverterSupport.hsbToRGB(newHSB)
        hsl = ColorConverterSupport.rgbToHSL(rgb)
        hexInput = ColorConverterSupport.toHex(rgb)
    }

    var swiftUIString: String { ColorConverterSupport.toSwiftUI(rgb) }
    var cssRGBAString: String { ColorConverterSupport.toCSSRGBA(rgb) }

    func copyHex() {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(hexInput, forType: .string)
    }

    func copySwiftUI() {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(swiftUIString, forType: .string)
    }

    func pasteHexFromClipboard() {
        GeneralPasteboardAccess.shared.async({
            NSPasteboard.general.string(forType: .string) ?? ""
        }, then: { [weak self] text in
            self?.applyHex(text.trimmingCharacters(in: .whitespaces))
        })
    }
}
