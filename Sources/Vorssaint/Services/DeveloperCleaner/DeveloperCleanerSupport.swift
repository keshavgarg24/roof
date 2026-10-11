// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

struct DevJunkItem: Identifiable {
    let id = UUID()
    let url: URL
    let label: String
    let category: String
    var size: Int64
    var isSelected: Bool = true

    var sizeFormatted: String {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f.string(fromByteCount: size)
    }
}

enum DeveloperCleanerSupport {
    static func scan(completion: @escaping ([DevJunkItem]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let items = StorageAnalyzerSupport.developerJunkPaths().compactMap { entry -> DevJunkItem? in
                let fm = FileManager.default
                guard fm.fileExists(atPath: entry.url.path) else { return nil }
                let size = directorySize(entry.url)
                guard size > 0 else { return nil }
                return DevJunkItem(url: entry.url, label: entry.label, category: entry.category, size: size)
            }
            DispatchQueue.main.async { completion(items) }
        }
    }

    static func delete(items: [DevJunkItem], completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var lastError: Error?
            for item in items {
                do {
                    try FileManager.default.removeItem(at: item.url)
                } catch {
                    lastError = error
                }
            }
            DispatchQueue.main.async { completion(lastError) }
        }
    }

    static func totalSize(_ items: [DevJunkItem]) -> Int64 {
        items.filter(\.isSelected).reduce(0) { $0 + $1.size }
    }

    static func formattedTotal(_ items: [DevJunkItem]) -> String {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f.string(fromByteCount: totalSize(items))
    }

    private static func directorySize(_ url: URL) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) else { return 0 }
        var size: Int64 = 0
        for case let fileURL as URL in enumerator {
            size += Int64((try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
            if size > 20_000_000_000 { break }
        }
        return size
    }
}
