// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit

/// Watches for video call apps and auto-mutes the mic when one is running.
final class MeetingModeService: ObservableObject {
    static let shared = MeetingModeService()

    @Published private(set) var isMeetingActive = false
    @Published private(set) var watchedBundleIDs: [String] = []

    private var observers: [Any] = []

    private init() {}

    func syncWithPreferences() {
        let enabled = AppFeature.meetingMode.isAvailable
            && UserDefaults.standard.bool(forKey: DefaultsKey.meetingModeEnabled)
        let savedIDs = MeetingModeSupport.decodeBundleIDs(
            UserDefaults.standard.data(forKey: DefaultsKey.meetingModeWatchedApps))
        watchedBundleIDs = savedIDs.isEmpty ? MeetingModeSupport.defaultWatchedBundleIDs : savedIDs
        if enabled {
            startObserving()
            checkNow()
        } else {
            stopObserving()
            isMeetingActive = false
        }
    }

    func saveWatchedBundleIDs(_ ids: [String]) {
        watchedBundleIDs = ids
        UserDefaults.standard.set(MeetingModeSupport.encodeBundleIDs(ids),
                                  forKey: DefaultsKey.meetingModeWatchedApps)
    }

    private func startObserving() {
        guard observers.isEmpty else { return }
        let workspace = NSWorkspace.shared.notificationCenter
        observers.append(workspace.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil, queue: .main) { [weak self] _ in self?.checkNow() })
        observers.append(workspace.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil, queue: .main) { [weak self] _ in self?.checkNow() })
    }

    private func stopObserving() {
        observers.forEach {
            if let o = $0 as? NSObjectProtocol {
                NSWorkspace.shared.notificationCenter.removeObserver(o)
            }
        }
        observers.removeAll()
    }

    private func checkNow() {
        let autoMute = UserDefaults.standard.bool(forKey: DefaultsKey.meetingModeAutoMute)
        let active = MeetingModeSupport.isMeetingActive(bundleIDs: watchedBundleIDs)
        let wasActive = isMeetingActive
        isMeetingActive = active
        if autoMute, active != wasActive {
            MeetingModeSupport.setMicMuted(active)
        }
    }
}
