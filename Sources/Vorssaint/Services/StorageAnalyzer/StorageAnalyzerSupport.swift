// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

enum StorageCategory: String, CaseIterable, Identifiable {
    case apps, caches, documents, media, downloads, developer, system, other
    var id: String { rawValue }
}

struct StorageItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let category: StorageCategory
}

struct StorageSummary {
    let total: Int64
    let used: Int64
    var free: Int64 { total - used }
    let byCategory: [StorageCategory: Int64]
    let largest: [StorageItem]
    let recommendations: [String]
}

enum StorageAnalyzerSupport {
    static func volumeStats() -> (total: Int64, free: Int64) {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        let vals = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
        let total = Int64(vals?.volumeTotalCapacity ?? 0)
        let free = Int64(vals?.volumeAvailableCapacity ?? 0)
        return (total, free)
    }

    static func scanAsync(progress: @escaping (String) -> Void, completion: @escaping (StorageSummary) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let (total, free) = volumeStats()
            let used = total - free

            var byCategory: [StorageCategory: Int64] = [:]
            var largest: [StorageItem] = []

            // Applications
            let appsDir = URL(fileURLWithPath: "/Applications")
            let homeApps = URL(fileURLWithPath: NSHomeDirectory() + "/Applications")
            let appsSize = directorySize(appsDir) + directorySize(homeApps)
            byCategory[.apps] = appsSize
            progress("Scanning Applications…")

            // Caches
            let cachesDir = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches")
            let systemCaches = URL(fileURLWithPath: "/Library/Caches")
            let cachesSize = directorySize(cachesDir) + directorySize(systemCaches)
            byCategory[.caches] = cachesSize
            progress("Scanning Caches…")

            // Downloads
            let downloadsDir = URL(fileURLWithPath: NSHomeDirectory() + "/Downloads")
            let downloadsSize = directorySize(downloadsDir)
            byCategory[.downloads] = downloadsSize
            largest += topItems(in: downloadsDir, category: .downloads, limit: 5)
            progress("Scanning Downloads…")

            // Developer junk
            let devSize = developerJunkSize()
            byCategory[.developer] = devSize
            progress("Scanning Developer…")

            // Documents
            let docsDir = URL(fileURLWithPath: NSHomeDirectory() + "/Documents")
            let docsSize = directorySize(docsDir)
            byCategory[.documents] = docsSize
            progress("Scanning Documents…")

            // Media
            let mediaSize = directorySize(URL(fileURLWithPath: NSHomeDirectory() + "/Movies"))
                + directorySize(URL(fileURLWithPath: NSHomeDirectory() + "/Music"))
                + directorySize(URL(fileURLWithPath: NSHomeDirectory() + "/Pictures"))
            byCategory[.media] = mediaSize
            progress("Scanning Media…")

            // System
            byCategory[.system] = max(0, used - appsSize - cachesSize - downloadsSize - devSize - docsSize - mediaSize)
            byCategory[.other] = 0

            let recs = buildRecommendations(byCategory: byCategory)
            let summary = StorageSummary(total: total, used: used, byCategory: byCategory,
                                         largest: largest.sorted { $0.size > $1.size }.prefix(10).map { $0 },
                                         recommendations: recs)
            DispatchQueue.main.async { completion(summary) }
        }
    }

    static func developerJunkSize() -> Int64 {
        let paths = developerJunkPaths().map(\.url)
        return paths.reduce(0) { $0 + directorySize($1) }
    }

    static func developerJunkPaths() -> [(url: URL, label: String, category: String)] {
        let home = NSHomeDirectory()
        return [
            (URL(fileURLWithPath: home + "/Library/Developer/Xcode/DerivedData"), "Xcode DerivedData", "Xcode"),
            (URL(fileURLWithPath: home + "/Library/Developer/Xcode/Archives"), "Xcode Archives", "Xcode"),
            (URL(fileURLWithPath: home + "/Library/Developer/CoreSimulator/Devices"), "iOS Simulators", "Xcode"),
            (URL(fileURLWithPath: home + "/.npm/_npx"), "npm npx cache", "Node.js"),
            (URL(fileURLWithPath: home + "/.npm/_cacache"), "npm cache", "Node.js"),
            (URL(fileURLWithPath: home + "/Library/Caches/yarn"), "Yarn cache", "Node.js"),
            (URL(fileURLWithPath: home + "/Library/Caches/node-gyp"), "node-gyp cache", "Node.js"),
            (URL(fileURLWithPath: home + "/Library/Caches/pip"), "pip cache", "Python"),
            (URL(fileURLWithPath: home + "/.pyenv/versions"), "pyenv versions", "Python"),
            (URL(fileURLWithPath: home + "/Library/Caches/CocoaPods"), "CocoaPods cache", "Ruby"),
            (URL(fileURLWithPath: home + "/.gradle/caches"), "Gradle cache", "Other"),
            (URL(fileURLWithPath: home + "/Library/Caches/go/pkg/mod"), "Go module cache", "Go"),
        ]
    }

    static func formatSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private static func directorySize(_ url: URL) -> Int64 {
        guard FileManager.default.fileExists(atPath: url.path) else { return 0 }
        let result = try? Process.run(URL(fileURLWithPath: "/usr/bin/du"),
                                      arguments: ["-sk", url.path])
        _ = result
        // Use FileManager recursive for correctness
        var size: Int64 = 0
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return 0 }
        for case let fileURL as URL in enumerator {
            size += Int64((try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
            if size > 50_000_000_000 { break } // safety cap 50GB per category
        }
        return size
    }

    private static func topItems(in url: URL, category: StorageCategory, limit: Int) -> [StorageItem] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey], options: []) else { return [] }
        return contents.compactMap { child -> StorageItem? in
            let vals = try? child.resourceValues(forKeys: [.fileSizeKey])
            let sz = Int64(vals?.fileSize ?? 0)
            guard sz > 0 else { return nil }
            return StorageItem(url: child, name: child.lastPathComponent, size: sz, category: category)
        }
        .sorted { $0.size > $1.size }
        .prefix(limit)
        .map { $0 }
    }

    private static func buildRecommendations(byCategory: [StorageCategory: Int64]) -> [String] {
        var recs: [String] = []
        if (byCategory[.caches] ?? 0) > 1_000_000_000 {
            recs.append("Your caches are over 1 GB — consider clearing old app caches.")
        }
        if (byCategory[.developer] ?? 0) > 2_000_000_000 {
            recs.append("Developer junk is over 2 GB — use Developer Cleaner to reclaim space.")
        }
        if (byCategory[.downloads] ?? 0) > 5_000_000_000 {
            recs.append("Downloads folder is over 5 GB — review old downloaded files.")
        }
        return recs
    }
}
