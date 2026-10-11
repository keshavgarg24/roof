// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct WiFiScannerStrings {
    let pageTitle: String
    let hubDescription: String
    let scanButton: String
    let scanningLabel: String
    let ssidLabel: String
    let signalLabel: String
    let channelLabel: String
    let securityLabel: String
    let noNetworksCaption: String
    let currentNetworkSection: String
    let nearbyNetworksSection: String
    let copySSIDButton: String
    let signalExcellent: String
    let signalGood: String
    let signalFair: String
    let signalWeak: String
    let permissionNote: String
}

extension WiFiScannerStrings {
    static let enUS = WiFiScannerStrings(
        pageTitle: "WiFi Scanner",
        hubDescription: "Scan nearby WiFi networks and view signal strength, channel, and security details.",
        scanButton: "Scan",
        scanningLabel: "Scanning…",
        ssidLabel: "Network",
        signalLabel: "Signal",
        channelLabel: "Channel",
        securityLabel: "Security",
        noNetworksCaption: "No networks found. Click Scan to start.",
        currentNetworkSection: "Current Network",
        nearbyNetworksSection: "Nearby Networks",
        copySSIDButton: "Copy SSID",
        signalExcellent: "Excellent",
        signalGood: "Good",
        signalFair: "Fair",
        signalWeak: "Weak",
        permissionNote: "Location access may be required to view SSID on macOS 14+."
    )
}

extension FeatureStrings {
    static func wifiScanner(_ language: AppLanguage) -> WiFiScannerStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
