// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct MeetingModeStrings {
    let pageTitle: String
    let hubDescription: String
    let enableToggle: String
    let enableCaption: String
    let watchedAppsTitle: String
    let watchedAppsCaption: String
    let addAppButton: String
    let removeButton: String
    let appBundleIDPlaceholder: String
    let autoMuteToggle: String
    let autoMuteCaption: String
    let statusActive: String
    let statusIdle: String
    let detectedAppLabel: String
    let noWatchedApps: String

    static let enUS = MeetingModeStrings(
        pageTitle: "Meeting Mode",
        hubDescription: "Auto-mute your mic when a video call app is running.",
        enableToggle: "Enable Meeting Mode",
        enableCaption: "Automatically mute the microphone when any watched app is active.",
        watchedAppsTitle: "Watched Apps",
        watchedAppsCaption: "Meeting Mode activates when any of these apps is running.",
        addAppButton: "Add App",
        removeButton: "Remove",
        appBundleIDPlaceholder: "Bundle ID (e.g. us.zoom.xos)",
        autoMuteToggle: "Mute microphone automatically",
        autoMuteCaption: "The mic is muted as soon as a watched app starts and unmuted when none remain.",
        statusActive: "Meeting in progress",
        statusIdle: "No meeting detected",
        detectedAppLabel: "Active",
        noWatchedApps: "No apps configured. Add a video call app above."
    )
}

extension FeatureStrings {
    static func meetingMode(_ language: AppLanguage) -> MeetingModeStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
