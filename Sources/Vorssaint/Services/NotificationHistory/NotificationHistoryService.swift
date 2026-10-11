// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import SwiftUI
import UserNotifications

final class NotificationHistoryService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHistoryService()
    private override init() { super.init() }

    @AppStorage("notificationHistory.records") private var recordsData: Data = Data()
    @Published private(set) var records: [NotificationRecord] = []

    func syncWithPreferences() {
        records = NotificationHistorySupport.decode(recordsData.isEmpty ? nil : recordsData)
        UNUserNotificationCenter.current().delegate = self
        requestPermission()
    }

    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        record(notification.request)
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        record(response.notification.request)
        completionHandler()
    }

    private func record(_ request: UNNotificationRequest) {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.vorssaint.utils"
        let rec = NotificationRecord(
            id: request.identifier,
            title: request.content.title,
            body: request.content.body,
            appBundleID: bundleID,
            appName: NotificationHistorySupport.appName(for: bundleID),
            date: Date()
        )
        DispatchQueue.main.async {
            self.records.insert(rec, at: 0)
            if self.records.count > 500 { self.records = Array(self.records.prefix(500)) }
            self.recordsData = NotificationHistorySupport.encode(self.records)
        }
    }

    func clear() {
        records.removeAll()
        recordsData = Data()
    }

    func delete(id: String) {
        records.removeAll { $0.id == id }
        recordsData = NotificationHistorySupport.encode(records)
    }

    var grouped: [(label: String, records: [NotificationRecord])] {
        NotificationHistorySupport.groupedByDay(records)
    }
}
