// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

/// System events that can trigger a scripting hook.
enum ScriptingHookEvent: String, CaseIterable, Codable {
    case wake
    case sleep
    case displayConnect
    case displayDisconnect
    case powerConnect
    case powerDisconnect
    case appLaunch
    case appQuit

    func title(_ s: ScriptingHooksStrings) -> String {
        switch self {
        case .wake: return s.eventWake
        case .sleep: return s.eventSleep
        case .displayConnect: return s.eventDisplayConnect
        case .displayDisconnect: return s.eventDisplayDisconnect
        case .powerConnect: return s.eventPowerConnect
        case .powerDisconnect: return s.eventPowerDisconnect
        case .appLaunch: return s.eventAppLaunch
        case .appQuit: return s.eventAppQuit
        }
    }
}

enum ScriptingHookType: String, CaseIterable, Codable {
    case shell
    case appleScript

    func title(_ s: ScriptingHooksStrings) -> String {
        switch self {
        case .shell: return s.scriptTypeShell
        case .appleScript: return s.scriptTypeAppleScript
        }
    }
}

/// One scripting hook: fires `script` of `type` when `event` occurs.
struct ScriptingHook: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var event: ScriptingHookEvent
    var scriptType: ScriptingHookType
    var script: String
    var isEnabled: Bool

    init(id: UUID = UUID(),
         name: String = "",
         event: ScriptingHookEvent = .wake,
         scriptType: ScriptingHookType = .shell,
         script: String = "",
         isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.event = event
        self.scriptType = scriptType
        self.script = script
        self.isEnabled = isEnabled
    }
}

enum ScriptingHooksSupport {
    static func decode(_ data: Data?) -> [ScriptingHook] {
        guard let data, !data.isEmpty,
              let hooks = try? JSONDecoder().decode([ScriptingHook].self, from: data) else {
            return []
        }
        return hooks
    }

    static func encode(_ hooks: [ScriptingHook]) -> Data {
        (try? JSONEncoder().encode(hooks)) ?? Data()
    }

    static func run(_ hook: ScriptingHook) {
        guard hook.isEnabled, !hook.script.isEmpty else { return }
        switch hook.scriptType {
        case .shell:
            runShell(hook.script)
        case .appleScript:
            runAppleScript(hook.script)
        }
    }

    private static func runShell(_ script: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", script]
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice
        try? task.run()
    }

    private static func runAppleScript(_ source: String) {
        guard let script = NSAppleScript(source: source) else { return }
        var error: NSDictionary?
        script.executeAndReturnError(&error)
    }
}
