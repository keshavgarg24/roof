// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct SystemHealthStrings {
    let pageTitle: String
    let hubDescription: String
    let refreshButton: String
    let cpuSection: String
    let memorySection: String
    let batterySection: String
    let diskSection: String
    let temperatureLabel: String
    let pressureLabel: String
    let cycleCountLabel: String
    let batteryHealthLabel: String
    let smartStatusLabel: String
    let smartPassedLabel: String
    let smartFailingLabel: String
    let overallLabel: String
    let goodLabel: String
    let warningLabel: String
    let criticalLabel: String
    let commandBarTitle: String

    static let enUS = SystemHealthStrings(
        pageTitle: "System Health",
        hubDescription: "CPU temperature, memory pressure, battery cycle count and S.M.A.R.T. disk health at a glance.",
        refreshButton: "Refresh",
        cpuSection: "CPU",
        memorySection: "Memory",
        batterySection: "Battery",
        diskSection: "Disk",
        temperatureLabel: "Temperature",
        pressureLabel: "Pressure",
        cycleCountLabel: "Cycle Count",
        batteryHealthLabel: "Capacity",
        smartStatusLabel: "S.M.A.R.T.",
        smartPassedLabel: "Passed",
        smartFailingLabel: "Failing",
        overallLabel: "Overall",
        goodLabel: "Good",
        warningLabel: "Warning",
        criticalLabel: "Critical",
        commandBarTitle: "Check System Health"
    )
}

extension FeatureStrings {
    static func systemHealth(_ language: AppLanguage) -> SystemHealthStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
