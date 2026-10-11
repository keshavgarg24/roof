// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct EnvVariable: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let value: String
    let source: String   // "process", ".env path", "~/.zshrc", etc.
}

struct EnvFile: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    var variables: [EnvVariable]
    var name: String { url.lastPathComponent }
    var path: String { url.path }
}

enum EnvironmentManagerSupport {
    static func processEnvironment() -> [EnvVariable] {
        ProcessInfo.processInfo.environment.map { key, value in
            EnvVariable(key: key, value: value, source: "Process")
        }.sorted { $0.key < $1.key }
    }

    static func parseEnvFile(url: URL) -> [EnvVariable] {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        return content.components(separatedBy: "\n").compactMap { line -> EnvVariable? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#"),
                  let eq = trimmed.firstIndex(of: "=") else { return nil }
            var key = String(trimmed[trimmed.startIndex..<eq])
            if key.hasPrefix("export ") { key = String(key.dropFirst(7)) }
            key = key.trimmingCharacters(in: .whitespaces)
            var value = String(trimmed[trimmed.index(after: eq)...])
            if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
               (value.hasPrefix("'") && value.hasSuffix("'")) {
                value = String(value.dropFirst().dropLast())
            }
            return EnvVariable(key: key, value: value, source: url.path)
        }
    }

    static func findEnvFiles(in directories: [URL]) -> [EnvFile] {
        var files: [EnvFile] = []
        let fm = FileManager.default
        for dir in directories {
            guard let contents = try? fm.contentsOfDirectory(
                at: dir, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else { continue }
            let envURLs = contents.filter { $0.lastPathComponent.hasPrefix(".env") || $0.lastPathComponent == ".env" }
            for url in envURLs {
                let vars = parseEnvFile(url: url)
                files.append(EnvFile(url: url, variables: vars))
            }
        }
        return files
    }

    static func defaultScanPaths() -> [URL] {
        let home = NSHomeDirectory()
        return [
            URL(fileURLWithPath: home + "/Desktop"),
            URL(fileURLWithPath: home + "/Documents"),
            URL(fileURLWithPath: home + "/Developer"),
            URL(fileURLWithPath: home + "/Projects"),
            URL(fileURLWithPath: home + "/Code"),
        ].filter { FileManager.default.fileExists(atPath: $0.path) }
    }
}
