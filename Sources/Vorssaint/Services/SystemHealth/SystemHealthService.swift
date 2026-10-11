// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

final class SystemHealthService: ObservableObject {
    static let shared = SystemHealthService()
    private init() {}

    @Published private(set) var snapshot: SystemHealthSnapshot?
    @Published private(set) var isRefreshing = false
    private var autoRefreshTimer: Timer?

    func syncWithPreferences() { refresh() }

    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let snap = SystemHealthSupport.snapshot()
            DispatchQueue.main.async {
                self.snapshot = snap
                self.isRefreshing = false
            }
        }
    }

    func startAutoRefresh(interval: TimeInterval = 30) {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
}
