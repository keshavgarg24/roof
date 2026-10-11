// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct LinkRouterStrings {
    let pageTitle: String
    let hubDescription: String
    let enableToggle: String
    let enableCaption: String
    let rulesTitle: String
    let rulesCaption: String
    let addRuleTitle: String
    let ruleNamePlaceholder: String
    let rulePatternPlaceholder: String
    let ruleBrowserPlaceholder: String
    let addButton: String
    let removeButton: String
    let noRulesCaption: String
    let openURLTitle: String
    let openURLSubtitle: String
    let patternLabel: String
    let browserLabel: String
    let nameLabel: String
    let installedBrowsersLabel: String

    static let enUS = LinkRouterStrings(
        pageTitle: "Link Router",
        hubDescription: "Open URLs in the right browser automatically based on domain rules.",
        enableToggle: "Enable Link Router",
        enableCaption: "Automatically route URLs based on the rules below when opened from the Command Bar.",
        rulesTitle: "Routing Rules",
        rulesCaption: "Add domain patterns (e.g. \"github.com\") and choose which browser opens those URLs.",
        addRuleTitle: "Add Rule",
        ruleNamePlaceholder: "Rule name",
        rulePatternPlaceholder: "Domain pattern (e.g. github.com)",
        ruleBrowserPlaceholder: "Browser bundle ID",
        addButton: "Add",
        removeButton: "Remove",
        noRulesCaption: "No routing rules yet. Add one above.",
        openURLTitle: "Open URL in…",
        openURLSubtitle: "Link Router",
        patternLabel: "Pattern",
        browserLabel: "Browser",
        nameLabel: "Name",
        installedBrowsersLabel: "Installed Browsers"
    )
}

extension FeatureStrings {
    static func linkRouter(_ language: AppLanguage) -> LinkRouterStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
