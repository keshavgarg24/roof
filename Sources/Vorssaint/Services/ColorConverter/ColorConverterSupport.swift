// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct RGBColor: Equatable {
    var r: Double  // 0–255
    var g: Double
    var b: Double
    var a: Double  // 0–1
}

struct HSLColor: Equatable {
    var h: Double  // 0–360
    var s: Double  // 0–100
    var l: Double  // 0–100
    var a: Double  // 0–1
}

struct HSBColor: Equatable {
    var h: Double  // 0–360
    var s: Double  // 0–100
    var b: Double  // 0–100
    var a: Double  // 0–1
}

enum ColorConverterSupport {
    // MARK: - HEX parsing

    static func parseHex(_ hex: String) -> RGBColor? {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s = String(s.dropFirst()) }
        switch s.count {
        case 3:
            s = s.map { "\($0)\($0)" }.joined()
        case 4:
            let chars = Array(s)
            s = String(chars[0]) + String(chars[0]) + String(chars[1]) + String(chars[1]) + String(chars[2]) + String(chars[2]) + String(chars[3]) + String(chars[3])
        case 6:
            s += "ff"
        case 8:
            break
        default:
            return nil
        }
        guard let value = UInt64(s, radix: 16) else { return nil }
        return RGBColor(
            r: Double((value >> 24) & 0xff),
            g: Double((value >> 16) & 0xff),
            b: Double((value >> 8) & 0xff),
            a: Double(value & 0xff) / 255.0
        )
    }

    static func toHex(_ rgb: RGBColor) -> String {
        let r = Int(rgb.r.clamped(to: 0...255))
        let g = Int(rgb.g.clamped(to: 0...255))
        let b = Int(rgb.b.clamped(to: 0...255))
        let a = Int((rgb.a.clamped(to: 0...1) * 255).rounded())
        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }

    // MARK: - RGB ↔ HSL

    static func rgbToHSL(_ rgb: RGBColor) -> HSLColor {
        let r = rgb.r / 255, g = rgb.g / 255, b = rgb.b / 255
        let maxC = max(r, g, b), minC = min(r, g, b)
        let l = (maxC + minC) / 2
        guard maxC != minC else {
            return HSLColor(h: 0, s: 0, l: l * 100, a: rgb.a)
        }
        let d = maxC - minC
        let s = l > 0.5 ? d / (2 - maxC - minC) : d / (maxC + minC)
        var h: Double
        switch maxC {
        case r: h = (g - b) / d + (g < b ? 6 : 0)
        case g: h = (b - r) / d + 2
        default: h = (r - g) / d + 4
        }
        return HSLColor(h: h / 6 * 360, s: s * 100, l: l * 100, a: rgb.a)
    }

    static func hslToRGB(_ hsl: HSLColor) -> RGBColor {
        let h = hsl.h / 360, s = hsl.s / 100, l = hsl.l / 100
        guard s != 0 else {
            let v = l * 255
            return RGBColor(r: v, g: v, b: v, a: hsl.a)
        }
        func hue2rgb(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }; if t > 1 { t -= 1 }
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        return RGBColor(
            r: hue2rgb(p, q, h + 1/3) * 255,
            g: hue2rgb(p, q, h) * 255,
            b: hue2rgb(p, q, h - 1/3) * 255,
            a: hsl.a
        )
    }

    // MARK: - RGB ↔ HSB

    static func rgbToHSB(_ rgb: RGBColor) -> HSBColor {
        let r = rgb.r / 255, g = rgb.g / 255, b = rgb.b / 255
        let maxC = max(r, g, b), minC = min(r, g, b)
        let bv = maxC
        let d = maxC - minC
        let s = maxC == 0 ? 0.0 : d / maxC
        var h = 0.0
        if maxC != minC {
            switch maxC {
            case r: h = (g - b) / d + (g < b ? 6 : 0)
            case g: h = (b - r) / d + 2
            default: h = (r - g) / d + 4
            }
            h /= 6
        }
        return HSBColor(h: h * 360, s: s * 100, b: bv * 100, a: rgb.a)
    }

    static func hsbToRGB(_ hsb: HSBColor) -> RGBColor {
        let h = hsb.h / 360, s = hsb.s / 100, v = hsb.b / 100
        guard s != 0 else {
            let c = v * 255
            return RGBColor(r: c, g: c, b: c, a: hsb.a)
        }
        let i = Int(h * 6)
        let f = h * 6 - Double(i)
        let p = v * (1 - s), q = v * (1 - f * s), t = v * (1 - (1 - f) * s)
        let (r, g, b): (Double, Double, Double)
        switch i % 6 {
        case 0: (r, g, b) = (v, t, p)
        case 1: (r, g, b) = (q, v, p)
        case 2: (r, g, b) = (p, v, t)
        case 3: (r, g, b) = (p, q, v)
        case 4: (r, g, b) = (t, p, v)
        default: (r, g, b) = (v, p, q)
        }
        return RGBColor(r: r * 255, g: g * 255, b: b * 255, a: hsb.a)
    }

    // MARK: - Format strings

    static func toSwiftUI(_ rgb: RGBColor) -> String {
        String(format: "Color(red: %.3f, green: %.3f, blue: %.3f, opacity: %.3f)",
               rgb.r / 255, rgb.g / 255, rgb.b / 255, rgb.a)
    }

    static func toCSSRGBA(_ rgb: RGBColor) -> String {
        String(format: "rgba(%d, %d, %d, %.2f)",
               Int(rgb.r.rounded()), Int(rgb.g.rounded()), Int(rgb.b.rounded()), rgb.a)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
