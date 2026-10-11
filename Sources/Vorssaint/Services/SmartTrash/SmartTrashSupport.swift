// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation
import AppKit

struct TrashItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let deletedDate: Date?
    var sizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct APFSSnapshot: Identifiable {
    let id = UUID()
    let name: String
    let date: Date?
    let volume: String
}

enum SmartTrashSupport {
    static let trashURL: URL = {
        FileManager.default.urls(for: .trashDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory() + "/.Trash")
    }()

    static func trashItems() -> [TrashItem] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: trashURL, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: []) else { return [] }
        return contents.map { url in
            let vals = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            return TrashItem(url: url, name: url.lastPathComponent,
                             size: Int64(vals?.fileSize ?? 0),
                             deletedDate: vals?.contentModificationDate)
        }
    }

    static func trashSize() -> Int64 {
        trashItems().reduce(0) { $0 + $1.size }
    }

    static func restore(item: TrashItem) throws {
        let dest = URL(fileURLWithPath: NSHomeDirectory() + "/" + item.name)
        try FileManager.default.moveItem(at: item.url, to: dest)
    }

    static func delete(item: TrashItem) throws {
        try FileManager.default.removeItem(at: item.url)
    }

    static func emptyTrash() throws {
        let items = trashItems()
        for item in items {
            try FileManager.default.removeItem(at: item.url)
        }
    }

    // List APFS snapshots via `tmutil listlocalsnapshotdates`
    static func listSnapshots(completion: @escaping ([APFSSnapshot]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/tmutil")
            proc.arguments = ["listlocalsnapshotdates", "/"]
            let pipe = Pipe()
            proc.standardOutput = pipe
            proc.standardError = Pipe()
            do {
                try proc.run()
                proc.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                let lines = output.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HHmmss"
                let snapshots = lines.dropFirst().compactMap { line -> APFSSnapshot? in
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return nil }
                    let date = formatter.date(from: trimmed)
                    return APFSSnapshot(name: trimmed, date: date, volume: "/")
                }
                DispatchQueue.main.async { completion(snapshots) }
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }
    }

    // Restore from snapshot via tmutil (requires user confirmation in terminal)
    static func restoreFromSnapshot(_ snapshot: APFSSnapshot, filePath: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/tmutil")
            proc.arguments = ["restore", "-v", filePath, "--snapshot", snapshot.name]
            proc.standardOutput = Pipe()
            proc.standardError = Pipe()
            do {
                try proc.run()
                proc.waitUntilExit()
                DispatchQueue.main.async { completion(proc.terminationStatus == 0) }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
}
