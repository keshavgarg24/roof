// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation
import CoreWLAN

struct WiFiNetwork: Identifiable {
    let id = UUID()
    let ssid: String
    let bssid: String
    let rssi: Int
    let channel: Int
    let security: String
    var isCurrent: Bool = false

    var signalStrength: WiFiSignalStrength {
        if rssi >= -50 { return .excellent }
        if rssi >= -65 { return .good }
        if rssi >= -75 { return .fair }
        return .weak
    }

    var signalBars: Int {
        switch signalStrength {
        case .excellent: return 4
        case .good: return 3
        case .fair: return 2
        case .weak: return 1
        }
    }
}

enum WiFiSignalStrength {
    case excellent, good, fair, weak
}

enum WiFiScannerSupport {
    static func scan() async -> [WiFiNetwork] {
        guard let iface = CWWiFiClient.shared().interface() else { return [] }
        let currentSSID = iface.ssid()
        let networks = (try? await iface.scanForNetworks(withName: nil)) ?? []
        return networks.compactMap { n -> WiFiNetwork? in
            guard let ssid = n.ssid, !ssid.isEmpty else { return nil }
            let channel = n.wlanChannel?.channelNumber ?? 0
            let security: String
            if n.supportsSecurity(.wpa3Personal) || n.supportsSecurity(.wpa3Transition) {
                security = "WPA3"
            } else if n.supportsSecurity(.wpa2Personal) {
                security = "WPA2"
            } else if n.supportsSecurity(.wpaPersonal) || n.supportsSecurity(.wpaPersonalMixed) {
                security = "WPA"
            } else if n.supportsSecurity(.wpaEnterprise) || n.supportsSecurity(.wpa2Enterprise) {
                security = "Enterprise"
            } else if n.supportsSecurity(.WEP) {
                security = "WEP"
            } else {
                security = "Open"
            }
            return WiFiNetwork(
                ssid: ssid,
                bssid: n.bssid ?? "",
                rssi: n.rssiValue,
                channel: channel,
                security: security,
                isCurrent: ssid == currentSSID
            )
        }
        .sorted { $0.rssi > $1.rssi }
    }

    static func currentNetwork() -> WiFiNetwork? {
        guard let iface = CWWiFiClient.shared().interface(),
              let ssid = iface.ssid() else { return nil }
        let channel = iface.wlanChannel()?.channelNumber ?? 0
        return WiFiNetwork(
            ssid: ssid,
            bssid: iface.bssid() ?? "",
            rssi: iface.rssiValue(),
            channel: channel,
            security: "—",
            isCurrent: true
        )
    }
}
