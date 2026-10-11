// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

enum UnitCategory: String, CaseIterable, Identifiable {
    case length, mass, temperature, area, speed, volume
    var id: String { rawValue }

    var units: [String] {
        switch self {
        case .length: return ["Meters", "Kilometers", "Centimeters", "Millimeters", "Inches", "Feet", "Yards", "Miles"]
        case .mass: return ["Kilograms", "Grams", "Milligrams", "Pounds", "Ounces", "Tonnes"]
        case .temperature: return ["Celsius", "Fahrenheit", "Kelvin"]
        case .area: return ["Square Meters", "Square Kilometers", "Square Feet", "Square Inches", "Acres", "Hectares"]
        case .speed: return ["m/s", "km/h", "mph", "knots", "ft/s"]
        case .volume: return ["Liters", "Milliliters", "Cubic Meters", "US Gallons", "US Pints", "Fluid Ounces"]
        }
    }
}

enum UnitConverterSupport {
    static func convert(value: Double, from: String, to: String, category: UnitCategory) -> Double? {
        if from == to { return value }
        switch category {
        case .length:   return convertLength(value, from: from, to: to)
        case .mass:     return convertMass(value, from: from, to: to)
        case .temperature: return convertTemperature(value, from: from, to: to)
        case .area:     return convertArea(value, from: from, to: to)
        case .speed:    return convertSpeed(value, from: from, to: to)
        case .volume:   return convertVolume(value, from: from, to: to)
        }
    }

    private static let lengthToMeters: [String: Double] = [
        "Meters": 1, "Kilometers": 1000, "Centimeters": 0.01, "Millimeters": 0.001,
        "Inches": 0.0254, "Feet": 0.3048, "Yards": 0.9144, "Miles": 1609.344
    ]
    private static let massToKg: [String: Double] = [
        "Kilograms": 1, "Grams": 0.001, "Milligrams": 1e-6, "Pounds": 0.453592, "Ounces": 0.0283495, "Tonnes": 1000
    ]
    private static let areaToM2: [String: Double] = [
        "Square Meters": 1, "Square Kilometers": 1e6, "Square Feet": 0.092903, "Square Inches": 0.00064516, "Acres": 4046.86, "Hectares": 10000
    ]
    private static let speedToMS: [String: Double] = [
        "m/s": 1, "km/h": 1.0/3.6, "mph": 0.44704, "knots": 0.514444, "ft/s": 0.3048
    ]
    private static let volumeToLiter: [String: Double] = [
        "Liters": 1, "Milliliters": 0.001, "Cubic Meters": 1000, "US Gallons": 3.78541, "US Pints": 0.473176, "Fluid Ounces": 0.0295735
    ]

    private static func linearConvert(_ v: Double, _ table: [String: Double], from: String, to: String) -> Double? {
        guard let fFactor = table[from], let tFactor = table[to] else { return nil }
        return v * fFactor / tFactor
    }

    private static func convertLength(_ v: Double, from: String, to: String) -> Double? {
        linearConvert(v, lengthToMeters, from: from, to: to)
    }
    private static func convertMass(_ v: Double, from: String, to: String) -> Double? {
        linearConvert(v, massToKg, from: from, to: to)
    }
    private static func convertArea(_ v: Double, from: String, to: String) -> Double? {
        linearConvert(v, areaToM2, from: from, to: to)
    }
    private static func convertSpeed(_ v: Double, from: String, to: String) -> Double? {
        linearConvert(v, speedToMS, from: from, to: to)
    }
    private static func convertVolume(_ v: Double, from: String, to: String) -> Double? {
        linearConvert(v, volumeToLiter, from: from, to: to)
    }

    private static func convertTemperature(_ v: Double, from: String, to: String) -> Double? {
        let celsius: Double
        switch from {
        case "Celsius":    celsius = v
        case "Fahrenheit": celsius = (v - 32) * 5/9
        case "Kelvin":     celsius = v - 273.15
        default: return nil
        }
        switch to {
        case "Celsius":    return celsius
        case "Fahrenheit": return celsius * 9/5 + 32
        case "Kelvin":     return celsius + 273.15
        default: return nil
        }
    }
}
