// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct NotificationHistoryStrings {
    let pageTitle: String
    let hubDescription: String
    let clearAllButton: String
    let filterAllLabel: String
    let searchPlaceholder: String
    let noNotificationsCaption: String
    let permissionNeeded: String
    let requestPermissionButton: String
    let todayLabel: String
    let yesterdayLabel: String
    let copyTextButton: String
    let pinButton: String
    let pinnedSection: String
    let recentSection: String

    static let enUS = NotificationHistoryStrings(
        pageTitle: "Notification History",
        hubDescription: "A persistent log of every notification so nothing gets lost, searchable and filterable.",
        clearAllButton: "Clear All",
        filterAllLabel: "All Apps",
        searchPlaceholder: "Search notifications…",
        noNotificationsCaption: "No notifications recorded yet.",
        permissionNeeded: "Notification access is required.",
        requestPermissionButton: "Allow Notifications",
        todayLabel: "Today",
        yesterdayLabel: "Yesterday",
        copyTextButton: "Copy Text",
        pinButton: "Pin",
        pinnedSection: "Pinned",
        recentSection: "Recent"
    )
}

extension FeatureStrings {
    static func notificationHistory(_ language: AppLanguage) -> NotificationHistoryStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
