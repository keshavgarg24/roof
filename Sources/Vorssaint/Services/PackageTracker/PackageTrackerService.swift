// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

final class PackageTrackerService: ObservableObject {
    static let shared = PackageTrackerService()
    private init() {}

    @Published private(set) var packages: [PackageInfo] = []
    @Published private(set) var isFetching = false
    @Published var selectedSource: PackageSource = .homebrew

    func syncWithPreferences() {}

    func fetch() {
        guard !isFetching else { return }
        isFetching = true
        packages = []
        let group = DispatchGroup()

        group.enter()
        PackageTrackerSupport.fetchHomebrew { [weak self] items in
            self?.packages.append(contentsOf: items)
            group.leave()
        }
        group.enter()
        PackageTrackerSupport.fetchNpm { [weak self] items in
            self?.packages.append(contentsOf: items)
            group.leave()
        }
        group.enter()
        PackageTrackerSupport.fetchPip { [weak self] items in
            self?.packages.append(contentsOf: items)
            group.leave()
        }
        group.enter()
        PackageTrackerSupport.fetchGem { [weak self] items in
            self?.packages.append(contentsOf: items)
            group.leave()
        }
        group.notify(queue: .main) { self.isFetching = false }
    }

    var filteredPackages: [PackageInfo] {
        packages.filter { $0.source == selectedSource }.sorted { $0.name < $1.name }
    }
}
