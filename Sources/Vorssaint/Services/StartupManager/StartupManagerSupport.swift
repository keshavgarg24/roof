// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

/// One login item or Launch Agent entry shown in the Startup Manager.
struct StartupItem: Identifiable, Equatable {
    enum Kind {
        case loginItem
        case launchAgent(path: String)
    }

    let id: String
    let name: String
    let kind: Kind
    var isEnabled: Bool
    let detail: String

    static func == (lhs: StartupItem, rhs: StartupItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum StartupManagerSupport {
    static func launchAgentItems() -> [StartupItem] {
        let agentsURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: agentsURL, includingPropertiesForKeys: nil
        ) else { return [] }
        return contents.filter { $0.pathExtension == "plist" }.compactMap { url in
            guard let dict = NSDictionary(contentsOf: url),
                  let label = dict["Label"] as? String else { return nil }
            let disabled = isDisabled(label: label)
            let program = (dict["Program"] as? String)
                ?? (dict["ProgramArguments"] as? [String])?.first
                ?? label
            return StartupItem(
                id: label,
                name: label,
                kind: .launchAgent(path: url.path),
                isEnabled: !disabled,
                detail: program
            )
        }.sorted { $0.name < $1.name }
    }

    private static func isDisabled(label: String) -> Bool {
        let overridesURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["print", "gui/\(getuid())/\(label)"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try? task.run()
        task.waitUntilExit()
        _ = overridesURL
        return task.terminationStatus != 0
    }

    static func setEnabled(_ item: StartupItem, enabled: Bool) {
        guard case .launchAgent(let path) = item.kind else { return }
        let args: [String]
        if enabled {
            args = ["load", path]
        } else {
            args = ["unload", path]
        }
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = args
        try? task.run()
        task.waitUntilExit()
    }
}
