// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

enum PackageSource: String, CaseIterable, Identifiable {
    case homebrew, npm, pip, gem
    var id: String { rawValue }
}

struct PackageInfo: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let installedVersion: String
    let latestVersion: String?
    let source: PackageSource
    var hasUpdate: Bool { latestVersion != nil && latestVersion != installedVersion }
}

enum PackageTrackerSupport {
    static func fetchHomebrew(completion: @escaping ([PackageInfo]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let output = runCommand("/opt/homebrew/bin/brew", args: ["list", "--versions"]).components(separatedBy: "\n")
            let packages = output.compactMap { line -> PackageInfo? in
                let parts = line.split(separator: " ", maxSplits: 1)
                guard parts.count == 2 else { return nil }
                return PackageInfo(name: String(parts[0]), installedVersion: String(parts[1]), latestVersion: nil, source: .homebrew)
            }
            DispatchQueue.main.async { completion(packages) }
        }
    }

    static func fetchNpm(completion: @escaping ([PackageInfo]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let output = runCommand("/usr/local/bin/npm", args: ["list", "-g", "--depth=0", "--json"])
            guard let data = output.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let deps = json["dependencies"] as? [String: [String: Any]] else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let packages = deps.map { name, info -> PackageInfo in
                let version = info["version"] as? String ?? "unknown"
                return PackageInfo(name: name, installedVersion: version, latestVersion: nil, source: .npm)
            }
            DispatchQueue.main.async { completion(packages.sorted { $0.name < $1.name }) }
        }
    }

    static func fetchPip(completion: @escaping ([PackageInfo]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let output = runCommand("/usr/bin/python3", args: ["-m", "pip", "list", "--format=json"])
            guard let data = output.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let packages = json.compactMap { item -> PackageInfo? in
                guard let name = item["name"], let version = item["version"] else { return nil }
                return PackageInfo(name: name, installedVersion: version, latestVersion: nil, source: .pip)
            }
            DispatchQueue.main.async { completion(packages) }
        }
    }

    static func fetchGem(completion: @escaping ([PackageInfo]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let output = runCommand("/usr/bin/gem", args: ["list"]).components(separatedBy: "\n")
            let packages = output.compactMap { line -> PackageInfo? in
                guard !line.isEmpty, let lparen = line.firstIndex(of: "("), let rparen = line.firstIndex(of: ")") else { return nil }
                let name = String(line[line.startIndex..<lparen]).trimmingCharacters(in: .whitespaces)
                let version = String(line[line.index(after: lparen)..<rparen]).split(separator: ",").first.map(String.init) ?? ""
                return PackageInfo(name: name, installedVersion: version, latestVersion: nil, source: .gem)
            }
            DispatchQueue.main.async { completion(packages) }
        }
    }

    private static func runCommand(_ path: String, args: [String]) -> String {
        guard FileManager.default.fileExists(atPath: path) else { return "" }
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: path)
        proc.arguments = args
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try? proc.run()
        proc.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }
}
