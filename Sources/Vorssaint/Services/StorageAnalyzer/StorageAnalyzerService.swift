// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

final class StorageAnalyzerService: ObservableObject {
    static let shared = StorageAnalyzerService()
    private init() {}

    @Published private(set) var summary: StorageSummary?
    @Published private(set) var isScanning = false
    @Published private(set) var scanProgress = ""

    func syncWithPreferences() {}

    func scan() {
        guard !isScanning else { return }
        isScanning = true
        summary = nil
        StorageAnalyzerSupport.scanAsync(progress: { [weak self] msg in
            DispatchQueue.main.async { self?.scanProgress = msg }
        }) { [weak self] result in
            self?.summary = result
            self?.isScanning = false
            self?.scanProgress = ""
        }
    }
}
