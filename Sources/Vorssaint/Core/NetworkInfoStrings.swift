// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct NetworkInfoStrings {
    let pageTitle: String
    let hubDescription: String
    let refreshButton: String
    let copyButton: String
    let copiedLabel: String
    let interfacesTitle: String
    let wifiTitle: String
    let ssidLabel: String
    let signalLabel: String
    let channelLabel: String
    let ipv4Label: String
    let ipv6Label: String
    let macLabel: String
    let noWifi: String
    let loadingLabel: String
    let externalIPLabel: String
    let noInterface: String

    static let enUS = NetworkInfoStrings(
        pageTitle: "Network Info",
        hubDescription: "See your IP addresses and Wi-Fi details at a glance, copy with one click.",
        refreshButton: "Refresh",
        copyButton: "Copy",
        copiedLabel: "Copied",
        interfacesTitle: "Interfaces",
        wifiTitle: "Wi-Fi",
        ssidLabel: "Network",
        signalLabel: "Signal",
        channelLabel: "Channel",
        ipv4Label: "IPv4",
        ipv6Label: "IPv6",
        macLabel: "MAC",
        noWifi: "Not connected",
        loadingLabel: "Loading…",
        externalIPLabel: "External IP",
        noInterface: "No active interfaces"
    )
}

extension FeatureStrings {
    static func networkInfo(_ language: AppLanguage) -> NetworkInfoStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
