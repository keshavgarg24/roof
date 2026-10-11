// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation
import SwiftUI

final class UnitConverterService: ObservableObject {
    static let shared = UnitConverterService()
    private init() {}

    @Published var category: UnitCategory = .length
    @Published var fromUnit: String = "Meters"
    @Published var toUnit: String = "Feet"
    @Published var inputValue: String = "1"
    @Published var result: Double? = nil

    func syncWithPreferences() {}

    func updateCategory(_ cat: UnitCategory) {
        category = cat
        fromUnit = cat.units[0]
        toUnit = cat.units.count > 1 ? cat.units[1] : cat.units[0]
        recalculate()
    }

    func swap() {
        let tmp = fromUnit
        fromUnit = toUnit
        toUnit = tmp
        recalculate()
    }

    func recalculate() {
        guard let v = Double(inputValue) else { result = nil; return }
        result = UnitConverterSupport.convert(value: v, from: fromUnit, to: toUnit, category: category)
    }
}
