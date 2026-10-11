// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit
import Foundation
import SwiftUI

final class GlobalHotkeysService: ObservableObject {
    static let shared = GlobalHotkeysService()
    private init() {}

    @AppStorage("globalHotkeys.rules") private var rulesData: Data = Data()
    @Published private(set) var rules: [HotkeyRule] = []
    private var eventTap: CFMachPort?

    func syncWithPreferences() {
        rules = GlobalHotkeysSupport.decode(rulesData.isEmpty ? nil : rulesData)
        restartTap()
    }

    func addRule(_ rule: HotkeyRule) {
        rules.append(rule)
        save()
        restartTap()
    }

    func deleteRule(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
        save()
        restartTap()
    }

    func toggleRule(id: UUID) {
        if let idx = rules.firstIndex(where: { $0.id == id }) {
            rules[idx].isEnabled.toggle()
            save()
        }
    }

    private func save() {
        rulesData = GlobalHotkeysSupport.encode(rules)
    }

    private func restartTap() {
        stopTap()
        guard !rules.isEmpty else { return }
        guard CGPreflightListenEventAccess() else { return }
        let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue
        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: mask, callback: { _, type, event, refcon -> Unmanaged<CGEvent>? in
                guard type == .keyDown, let refcon else { return Unmanaged.passRetained(event) }
                let svc = Unmanaged<GlobalHotkeysService>.fromOpaque(refcon).takeUnretainedValue()
                return svc.handleEvent(event)
            }, userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        guard let tap = eventTap else { return }
        let src = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func stopTap() {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false); eventTap = nil }
    }

    private func handleEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = UInt32(event.flags.rawValue)
        for rule in rules where rule.isEnabled && rule.keyCode == keyCode && rule.modifiers == flags {
            GlobalHotkeysSupport.execute(action: rule.action)
            return nil  // consume event
        }
        return Unmanaged.passRetained(event)
    }
}
