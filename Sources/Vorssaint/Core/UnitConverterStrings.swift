// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct UnitConverterStrings {
    let pageTitle: String
    let hubDescription: String
    let categoryLabel: String
    let fromLabel: String
    let toLabel: String
    let valueLabel: String
    let resultLabel: String
    let swapButton: String
    let categoryLength: String
    let categoryMass: String
    let categoryTemperature: String
    let categoryArea: String
    let categorySpeed: String
    let categoryVolume: String
}

extension UnitConverterStrings {
    static let enUS = UnitConverterStrings(
        pageTitle: "Unit Converter",
        hubDescription: "Convert between units of length, mass, temperature, area, speed, and volume instantly.",
        categoryLabel: "Category",
        fromLabel: "From",
        toLabel: "To",
        valueLabel: "Value",
        resultLabel: "Result",
        swapButton: "Swap",
        categoryLength: "Length",
        categoryMass: "Mass",
        categoryTemperature: "Temperature",
        categoryArea: "Area",
        categorySpeed: "Speed",
        categoryVolume: "Volume"
    )
}

extension FeatureStrings {
    static func unitConverter(_ language: AppLanguage) -> UnitConverterStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
