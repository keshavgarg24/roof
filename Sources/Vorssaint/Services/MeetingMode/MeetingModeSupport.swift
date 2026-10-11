// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit
import CoreAudio
import Foundation

enum MeetingModeSupport {
    static let defaultWatchedBundleIDs: [String] = [
        "us.zoom.xos",
        "com.microsoft.teams",
        "com.google.Chrome",          // Google Meet runs in Chrome
        "com.apple.FaceTime",
        "com.cisco.webexmeetingsapp",
        "com.loom.desktop",
        "com.whereby.desktop",
        "com.discord",
    ]

    /// Returns true if any app with a bundle ID in `bundleIDs` is currently running.
    static func isMeetingActive(bundleIDs: [String]) -> Bool {
        let running = NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier)
        return bundleIDs.contains(where: { running.contains($0) })
    }

    static func runningMeetingApp(bundleIDs: [String]) -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first {
            guard let bid = $0.bundleIdentifier else { return false }
            return bundleIDs.contains(bid)
        }
    }

    /// Mute / unmute the default input device using CoreAudio.
    static func setMicMuted(_ muted: Bool) {
        var defaultInputID = AudioObjectID(kAudioObjectUnknown)
        var propertySize = UInt32(MemoryLayout<AudioObjectID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                   &address, 0, nil, &propertySize, &defaultInputID)
        guard defaultInputID != kAudioObjectUnknown else { return }
        var muteVal: UInt32 = muted ? 1 : 0
        var muteAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain)
        AudioObjectSetPropertyData(defaultInputID, &muteAddress, 0, nil,
                                   UInt32(MemoryLayout<UInt32>.size), &muteVal)
    }

    static func decodeBundleIDs(_ data: Data?) -> [String] {
        guard let data, !data.isEmpty,
              let ids = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return ids
    }

    static func encodeBundleIDs(_ ids: [String]) -> Data {
        (try? JSONEncoder().encode(ids)) ?? Data()
    }
}
