// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit

/// Routes URLs to browsers based on user-configured domain rules.
/// Rules are evaluated in order; the first match wins.
final class LinkRouterService: ObservableObject {
    static let shared = LinkRouterService()

    @Published private(set) var rules: [LinkRouterRule] = []
    @Published private(set) var isEnabled = false

    private init() {
        load()
    }

    func syncWithPreferences() {
        load()
    }

    private func load() {
        let defaults = UserDefaults.standard
        isEnabled = AppFeature.linkRouter.isAvailable
            && defaults.bool(forKey: DefaultsKey.linkRouterEnabled)
        rules = LinkRouterSupport.decode(defaults.data(forKey: DefaultsKey.linkRouterRules))
    }

    func saveRules(_ newRules: [LinkRouterRule]) {
        rules = newRules
        UserDefaults.standard.set(LinkRouterSupport.encode(newRules),
                                  forKey: DefaultsKey.linkRouterRules)
    }

    /// Opens `url` using the first matching rule, or falls back to the default browser.
    func open(_ url: URL) {
        let bundleID = LinkRouterSupport.matchingBrowser(for: url, rules: rules)
        if let bundleID,
           let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            let config = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config)
        } else {
            NSWorkspace.shared.open(url)
        }
    }

    /// Returns the browser bundle ID for the URL if a rule matches, nil otherwise.
    func matchingBrowser(for url: URL) -> String? {
        LinkRouterSupport.matchingBrowser(for: url, rules: rules)
    }

    /// List of installed browsers (app bundle IDs) for the settings picker.
    func installedBrowsers() -> [(bundleID: String, name: String)] {
        let candidates = ["com.apple.Safari",
                          "com.google.Chrome",
                          "org.mozilla.firefox",
                          "com.microsoft.edgemac",
                          "com.brave.Browser",
                          "com.operasoftware.Opera",
                          "com.vivaldi.Vivaldi",
                          "com.arc.app",
                          "company.thebrowser.Browser"]
        return candidates.compactMap { bundleID -> (String, String)? in
            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
                return nil
            }
            let name = (url.lastPathComponent as NSString).deletingPathExtension
            return (bundleID, name)
        }
    }
}
