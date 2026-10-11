// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit
import IOKit.ps

/// Listens for system events and runs user-configured scripts when they fire.
final class ScriptingHooksService: ObservableObject {
    static let shared = ScriptingHooksService()

    @Published private(set) var hooks: [ScriptingHook] = []

    private var observers: [Any] = []
    private var powerSourceRunLoopSource: CFRunLoopSource?
    private var wasOnBattery = false

    private init() {}

    func syncWithPreferences() {
        let enabled = AppFeature.scriptingHooks.isAvailable
            && UserDefaults.standard.bool(forKey: DefaultsKey.scriptingHooksEnabled)
        hooks = ScriptingHooksSupport.decode(
            UserDefaults.standard.data(forKey: DefaultsKey.scriptingHooksConfig))
        if enabled {
            startObserving()
        } else {
            stopObserving()
        }
    }

    func saveHooks(_ newHooks: [ScriptingHook]) {
        hooks = newHooks
        UserDefaults.standard.set(ScriptingHooksSupport.encode(newHooks),
                                  forKey: DefaultsKey.scriptingHooksConfig)
    }

    func testHook(_ hook: ScriptingHook) {
        ScriptingHooksSupport.run(hook)
    }

    private func startObserving() {
        guard observers.isEmpty else { return }
        let workspace = NSWorkspace.shared.notificationCenter
        let center = NotificationCenter.default

        observers.append(workspace.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil, queue: .main) { [weak self] _ in
                self?.fire(event: .wake)
        })
        observers.append(workspace.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil, queue: .main) { [weak self] _ in
                self?.fire(event: .sleep)
        })
        observers.append(center.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main) { [weak self] _ in
                self?.handleScreenChange()
        })
        observers.append(workspace.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil, queue: .main) { [weak self] _ in
                self?.fire(event: .appLaunch)
        })
        observers.append(workspace.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil, queue: .main) { [weak self] _ in
                self?.fire(event: .appQuit)
        })
        startPowerSourceObserver()
    }

    private func stopObserving() {
        for observer in observers {
            if let o = observer as? NSObjectProtocol {
                NotificationCenter.default.removeObserver(o)
                NSWorkspace.shared.notificationCenter.removeObserver(o)
            }
        }
        observers.removeAll()
        if let source = powerSourceRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .defaultMode)
            powerSourceRunLoopSource = nil
        }
    }

    private func handleScreenChange() {
        let screens = NSScreen.screens
        if screens.count > 1 {
            fire(event: .displayConnect)
        } else {
            fire(event: .displayDisconnect)
        }
    }

    private func startPowerSourceObserver() {
        wasOnBattery = currentlyOnBattery()
        let context = UnsafeMutableRawPointer(
            Unmanaged.passUnretained(self).toOpaque())
        let source = IOPSNotificationCreateRunLoopSource({ context in
            guard let ctx = context else { return }
            let service = Unmanaged<ScriptingHooksService>.fromOpaque(ctx).takeUnretainedValue()
            service.handlePowerSourceChange()
        }, context)
        guard let source else { return }
        let retainedSource: CFRunLoopSource = source.takeRetainedValue()
        CFRunLoopAddSource(CFRunLoopGetMain(), retainedSource, .defaultMode)
        powerSourceRunLoopSource = retainedSource
    }

    private func handlePowerSourceChange() {
        let onBattery = currentlyOnBattery()
        if onBattery != wasOnBattery {
            fire(event: onBattery ? .powerDisconnect : .powerConnect)
            wasOnBattery = onBattery
        }
    }

    private func currentlyOnBattery() -> Bool {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else {
            return false
        }
        return list.contains { source in
            guard let desc = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue()
                    as? [String: Any] else { return false }
            return (desc[kIOPSPowerSourceStateKey] as? String) == kIOPSBatteryPowerValue
        }
    }

    private func fire(event: ScriptingHookEvent) {
        let matching = hooks.filter { $0.event == event && $0.isEnabled }
        for hook in matching {
            ScriptingHooksSupport.run(hook)
        }
    }
}
