// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct UnitConverterSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = UnitConverterService.shared

    private var s: UnitConverterStrings { FeatureStrings.unitConverter(l10n.language) }

    private func categoryName(_ cat: UnitCategory) -> String {
        switch cat {
        case .length:      return s.categoryLength
        case .mass:        return s.categoryMass
        case .temperature: return s.categoryTemperature
        case .area:        return s.categoryArea
        case .speed:       return s.categorySpeed
        case .volume:      return s.categoryVolume
        }
    }

    var body: some View {
        Form {
            Section(s.pageTitle) {
                Picker(s.categoryLabel, selection: $svc.category) {
                    ForEach(UnitCategory.allCases) { cat in
                        Text(categoryName(cat)).tag(cat)
                    }
                }
                .onChange(of: svc.category) { svc.updateCategory($0) }

                HStack {
                    Picker(s.fromLabel, selection: $svc.fromUnit) {
                        ForEach(svc.category.units, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: svc.fromUnit) { _ in svc.recalculate() }

                    Button { svc.swap() } label: {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                    .buttonStyle(.borderless)

                    Picker(s.toLabel, selection: $svc.toUnit) {
                        ForEach(svc.category.units, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: svc.toUnit) { _ in svc.recalculate() }
                }

                HStack {
                    TextField(s.valueLabel, text: $svc.inputValue)
                        .onChange(of: svc.inputValue) { _ in svc.recalculate() }
                    Text("→")
                    if let r = svc.result {
                        Text(formatResult(r))
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    } else {
                        Text("—").foregroundStyle(.secondary)
                    }
                    Text(svc.toUnit).foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func formatResult(_ v: Double) -> String {
        if abs(v) >= 1e6 || (abs(v) < 0.001 && v != 0) {
            return String(format: "%.4e", v)
        }
        return String(format: "%.6g", v)
    }
}
