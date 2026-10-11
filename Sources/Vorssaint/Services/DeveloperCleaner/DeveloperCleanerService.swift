// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

final class DeveloperCleanerService: ObservableObject {
    static let shared = DeveloperCleanerService()
    private init() {}

    @Published private(set) var items: [DevJunkItem] = []
    @Published private(set) var isScanning = false
    @Published private(set) var isCleaning = false
    @Published var lastError: String?
    @Published var lastCleanedBytes: Int64 = 0

    func syncWithPreferences() {}

    func scan() {
        guard !isScanning else { return }
        isScanning = true
        DeveloperCleanerSupport.scan { [weak self] result in
            self?.items = result
            self?.isScanning = false
        }
    }

    func clean() {
        let selected = items.filter(\.isSelected)
        guard !selected.isEmpty, !isCleaning else { return }
        isCleaning = true
        lastCleanedBytes = DeveloperCleanerSupport.totalSize(items)
        DeveloperCleanerSupport.delete(items: selected) { [weak self] error in
            self?.isCleaning = false
            self?.lastError = error?.localizedDescription
            self?.scan()
        }
    }

    var totalSelected: String { DeveloperCleanerSupport.formattedTotal(items) }

    func toggleSelection(id: UUID) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items[idx].isSelected.toggle()
        }
    }
}
