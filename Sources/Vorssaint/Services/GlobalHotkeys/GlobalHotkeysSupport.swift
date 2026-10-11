// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit
import Carbon.HIToolbox
import Foundation

enum HotkeyAction: Codable, Equatable {
    case launchApp(bundleID: String)
    case openURL(urlString: String)
    case runScript(script: String)
    case typeText(text: String)
}

struct HotkeyRule: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var keyCode: UInt16
    var modifiers: UInt32   // CGEventFlags raw value subset
    var action: HotkeyAction
    var isEnabled: Bool = true
    var label: String

    var displayString: String {
        var parts: [String] = []
        let flags = NSEvent.ModifierFlags(rawValue: UInt(modifiers))
        if flags.contains(.command)  { parts.append("⌘") }
        if flags.contains(.option)   { parts.append("⌥") }
        if flags.contains(.control)  { parts.append("⌃") }
        if flags.contains(.shift)    { parts.append("⇧") }
        let keyName = keyCodeToString(keyCode) ?? "Key(\(keyCode))"
        parts.append(keyName)
        return parts.joined()
    }

    private func keyCodeToString(_ code: UInt16) -> String? {
        let map: [UInt16: String] = [
            0:"A",1:"S",2:"D",3:"F",4:"H",5:"G",6:"Z",7:"X",8:"C",9:"V",
            11:"B",12:"Q",13:"W",14:"E",15:"R",16:"Y",17:"T",31:"O",32:"U",
            34:"I",35:"P",37:"L",38:"J",40:"K",45:"N",46:"M",
            36:"↩",48:"⇥",49:"Space",51:"⌫",53:"⎋",
            123:"←",124:"→",125:"↓",126:"↑"
        ]
        return map[code]
    }
}

enum GlobalHotkeysSupport {
    static func decode(_ data: Data?) -> [HotkeyRule] {
        guard let data, let rules = try? JSONDecoder().decode([HotkeyRule].self, from: data) else { return [] }
        return rules
    }

    static func encode(_ rules: [HotkeyRule]) -> Data {
        (try? JSONEncoder().encode(rules)) ?? Data()
    }

    static func execute(action: HotkeyAction) {
        switch action {
        case .launchApp(let bundleID):
            NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleID,
                                                  options: [], additionalEventParamDescriptor: nil, launchIdentifier: nil)
        case .openURL(let urlString):
            if let url = URL(string: urlString) { NSWorkspace.shared.open(url) }
        case .runScript(let script):
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/bin/sh")
            proc.arguments = ["-c", script]
            try? proc.run()
        case .typeText(let text):
            let src = CGEventSource(stateID: .hidSystemState)
            for char in text.unicodeScalars {
                let down = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: true)
                let up = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: false)
                down?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [UniChar(char.value)])
                up?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [UniChar(char.value)])
                down?.post(tap: .cghidEventTap)
                up?.post(tap: .cghidEventTap)
            }
        }
    }
}
