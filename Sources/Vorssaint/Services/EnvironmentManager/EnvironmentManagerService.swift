// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

final class EnvironmentManagerService: ObservableObject {
    static let shared = EnvironmentManagerService()
    private init() {}

    @Published private(set) var processVars: [EnvVariable] = []
    @Published private(set) var envFiles: [EnvFile] = []
    @Published var searchQuery = ""

    func syncWithPreferences() { refresh() }

    func refresh() {
        processVars = EnvironmentManagerSupport.processEnvironment()
        envFiles = EnvironmentManagerSupport.findEnvFiles(in: EnvironmentManagerSupport.defaultScanPaths())
    }

    func scanDirectory(_ url: URL) {
        let found = EnvironmentManagerSupport.findEnvFiles(in: [url])
        for file in found where !envFiles.contains(file) {
            envFiles.append(file)
        }
    }

    var filteredProcess: [EnvVariable] {
        guard !searchQuery.isEmpty else { return processVars }
        return processVars.filter { $0.key.localizedCaseInsensitiveContains(searchQuery) || $0.value.localizedCaseInsensitiveContains(searchQuery) }
    }
}
