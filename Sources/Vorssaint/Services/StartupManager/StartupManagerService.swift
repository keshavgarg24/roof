// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit

/// Manages the list of startup items (Launch Agents). On-demand tool:
/// no background work runs; data is loaded when the Settings page opens.
final class StartupManagerService: ObservableObject {
    static let shared = StartupManagerService()

    @Published private(set) var items: [StartupItem] = []
    @Published private(set) var isLoading = false

    private init() {}

    func syncWithPreferences() {
        // No background services to start or stop.
    }

    @MainActor
    func refresh() {
        isLoading = true
        Task.detached(priority: .userInitiated) { [weak self] in
            let agents = StartupManagerSupport.launchAgentItems()
            await MainActor.run {
                self?.items = agents
                self?.isLoading = false
            }
        }
    }

    func setEnabled(_ item: StartupItem, enabled: Bool) {
        StartupManagerSupport.setEnabled(item, enabled: enabled)
        if let index = items.firstIndex(of: item) {
            items[index].isEnabled = enabled
        }
    }
}
