// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AppKit

/// Gates text transform command bar entries behind the feature availability
/// flag and provides the pasteboard read/write for transforms.
final class TextTransformerService: ObservableObject {
    static let shared = TextTransformerService()

    private init() {}

    func syncWithPreferences() {
        // No background work; the CommandBar reads availability on each build.
    }

    func transform(op: TextTransformerOp, completion: @escaping (Bool) -> Void) {
        GeneralPasteboardAccess.shared.async({
            NSPasteboard.general.string(forType: .string) ?? ""
        }, then: { [weak self] text in
            guard self != nil, !text.isEmpty else {
                completion(false)
                return
            }
            guard let result = op.apply(to: text) else {
                completion(false)
                return
            }
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.declareVorssaintSource()
            pasteboard.setString(result, forType: .string)
            completion(true)
        })
    }

    func clipboardText(completion: @escaping (String) -> Void) {
        GeneralPasteboardAccess.shared.async({
            NSPasteboard.general.string(forType: .string) ?? ""
        }, then: completion)
    }
}
