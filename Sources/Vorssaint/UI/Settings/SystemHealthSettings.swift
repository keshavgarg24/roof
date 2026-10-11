// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct SystemHealthSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = SystemHealthService.shared

    private var s: SystemHealthStrings { FeatureStrings.systemHealth(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    if let snap = svc.snapshot {
                        healthBadge(snap.overallLevel)
                    }
                    Spacer()
                    Button(s.refreshButton) { svc.refresh() }.disabled(svc.isRefreshing)
                    if svc.isRefreshing { ProgressView().scaleEffect(0.7) }
                }
            }

            if let snap = svc.snapshot {
                Section(s.cpuSection) {
                    if let temp = snap.cpuTemperature {
                        row(s.temperatureLabel, value: "\(temp.formatted(.number.precision(.fractionLength(1))))°C")
                    } else {
                        row(s.temperatureLabel, value: "—")
                    }
                }

                Section(s.memorySection) {
                    row(s.overallLabel, value: "\(snap.memoryUsedGB.formatted(.number.precision(.fractionLength(1)))) / \(snap.memoryTotalGB.formatted(.number.precision(.fractionLength(1)))) GB")
                    row(s.pressureLabel, value: pressureLabel(snap.memoryPressureLevel))
                }

                Section(s.batterySection) {
                    row(s.cycleCountLabel, value: snap.batteryCycleCount.map { "\($0)" } ?? "—")
                    row(s.batteryHealthLabel, value: snap.batteryCapacityPercent.map { "\($0)%" } ?? "—")
                }

                Section(s.diskSection) {
                    row(s.overallLabel, value: "\(snap.diskFreeGB.formatted(.number.precision(.fractionLength(1)))) GB free / \(snap.diskTotalGB.formatted(.number.precision(.fractionLength(1)))) GB total")
                    row(s.smartStatusLabel, value: snap.diskSmartPassed.map { $0 ? s.smartPassedLabel : s.smartFailingLabel } ?? "—")
                }
            } else if !svc.isRefreshing {
                Section {
                    Text(s.overallLabel).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 16)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { svc.refresh() }
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }

    private func healthBadge(_ level: SystemHealthSnapshot.HealthLevel) -> some View {
        let (color, text): (Color, String) = switch level {
        case .good: (.green, s.goodLabel)
        case .warning: (.orange, s.warningLabel)
        case .critical: (.red, s.criticalLabel)
        }
        return Label(text, systemImage: "heart.fill").foregroundStyle(color)
    }

    private func pressureLabel(_ level: Int) -> String {
        switch level {
        case 0: return s.goodLabel
        case 1: return s.warningLabel
        default: return s.criticalLabel
        }
    }
}
