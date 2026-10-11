// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import SwiftUI

final class WiFiScannerService: ObservableObject {
    static let shared = WiFiScannerService()
    private init() {}

    @Published private(set) var networks: [WiFiNetwork] = []
    @Published private(set) var currentNetwork: WiFiNetwork?
    @Published private(set) var isScanning: Bool = false

    func syncWithPreferences() {
        currentNetwork = WiFiScannerSupport.currentNetwork()
    }

    func scan() {
        guard !isScanning else { return }
        isScanning = true
        currentNetwork = WiFiScannerSupport.currentNetwork()
        Task {
            let found = await WiFiScannerSupport.scan()
            await MainActor.run {
                self.networks = found
                self.isScanning = false
            }
        }
    }
}
