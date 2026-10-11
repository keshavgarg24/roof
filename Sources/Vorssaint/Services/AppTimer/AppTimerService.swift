// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation
import SwiftUI
import AppKit
import UserNotifications

final class AppTimerService: ObservableObject {
    static let shared = AppTimerService()
    private init() {}

    @AppStorage("appTimer.enabled") var enabled: Bool = false
    @AppStorage("appTimer.limits") private var limitsData: Data = Data()
    @Published private(set) var limits: [AppLimit] = []

    private var timer: Timer?
    private var notifiedIDs: Set<String> = []

    func syncWithPreferences() {
        limits = AppTimerSupport.decode(limitsData)
        resetStaleEntries()
        if enabled { startTracking() } else { stopTracking() }
    }

    func addLimit(bundleID: String, appName: String, dailyMinutes: Int) {
        guard !limits.contains(where: { $0.bundleID == bundleID }) else { return }
        limits.append(AppLimit(
            id: UUID(), bundleID: bundleID, appName: appName,
            dailyLimitMinutes: dailyMinutes, usedSeconds: 0,
            lastResetDate: AppTimerSupport.todayKey
        ))
        save()
    }

    func remove(_ limit: AppLimit) {
        limits.removeAll { $0.id == limit.id }
        save()
    }

    private func startTracking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTracking() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let today = AppTimerSupport.todayKey
        let active = Set(NSWorkspace.shared.runningApplications
            .filter { $0.isActive }
            .compactMap { $0.bundleIdentifier })

        for i in limits.indices {
            if limits[i].lastResetDate != today {
                limits[i].usedSeconds = 0
                limits[i].lastResetDate = today
                notifiedIDs.remove(limits[i].bundleID)
            }
            if active.contains(limits[i].bundleID) {
                limits[i].usedSeconds += 60
            }
            if limits[i].isOverLimit && !notifiedIDs.contains(limits[i].bundleID) {
                notifiedIDs.insert(limits[i].bundleID)
                notify(limits[i])
            }
        }
        save()
    }

    private func notify(_ limit: AppLimit) {
        let content = UNMutableNotificationContent()
        let s = FeatureStrings.appTimer(L10n.shared.language)
        content.title = s.limitReachedTitle
        content.body = String(format: s.limitReachedBody, limit.appName)
        let req = UNNotificationRequest(identifier: "appTimer.\(limit.bundleID)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }

    private func resetStaleEntries() {
        let today = AppTimerSupport.todayKey
        for i in limits.indices where limits[i].lastResetDate != today {
            limits[i].usedSeconds = 0
            limits[i].lastResetDate = today
        }
        save()
    }

    private func save() {
        limitsData = AppTimerSupport.encode(limits)
    }
}
