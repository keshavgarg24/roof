// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

final class SmartTrashService: ObservableObject {
    static let shared = SmartTrashService()
    private init() {}

    @Published private(set) var items: [TrashItem] = []
    @Published private(set) var snapshots: [APFSSnapshot] = []
    @Published private(set) var isLoadingSnapshots = false
    @Published var lastError: String?

    func syncWithPreferences() {}

    func refresh() {
        items = SmartTrashSupport.trashItems()
    }

    func restore(_ item: TrashItem) {
        do { try SmartTrashSupport.restore(item: item); refresh() }
        catch { lastError = error.localizedDescription }
    }

    func delete(_ item: TrashItem) {
        do { try SmartTrashSupport.delete(item: item); refresh() }
        catch { lastError = error.localizedDescription }
    }

    func loadSnapshots() {
        isLoadingSnapshots = true
        SmartTrashSupport.listSnapshots { [weak self] result in
            self?.snapshots = result
            self?.isLoadingSnapshots = false
        }
    }

    var totalSize: String { SmartTrashSupport.formattedTotal }

    private static var formattedTotal: String { "" }
}

private extension SmartTrashSupport {
    static var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: trashSize(), countStyle: .file)
    }
}
