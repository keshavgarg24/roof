// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

/// Reads network interface information on demand.
final class NetworkInfoService: ObservableObject {
    static let shared = NetworkInfoService()

    @Published private(set) var interfaces: [NetworkInterface] = []
    @Published private(set) var wifiSSID: String?
    @Published private(set) var isLoading = false

    private init() {}

    func syncWithPreferences() {}

    @MainActor
    func refresh() {
        isLoading = true
        Task.detached(priority: .userInitiated) {
            let ifaces = NetworkInfoSupport.currentInterfaces()
            let ssid = NetworkInfoSupport.wifiSSID()
            await MainActor.run { [weak self] in
                self?.interfaces = ifaces
                self?.wifiSSID = ssid
                self?.isLoading = false
            }
        }
    }

    var primaryIPv4: String? {
        interfaces.first(where: { $0.ipv4 != nil })?.ipv4
    }
}
