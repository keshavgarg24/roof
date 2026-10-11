// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import SwiftUI
import AppKit

final class JSONFormatterService: ObservableObject {
    static let shared = JSONFormatterService()
    private init() {}

    @Published var input: String = ""
    @Published var output: String = ""
    @Published var isValid: Bool? = nil
    @Published var sortKeys: Bool = false

    func syncWithPreferences() {}

    func format() {
        process(minify: false)
    }

    func minify() {
        process(minify: true)
    }

    func validate() {
        guard !input.isEmpty else { isValid = nil; return }
        isValid = (try? JSONSerialization.jsonObject(with: Data(input.utf8))) != nil
    }

    func pasteFromClipboard() {
        input = NSPasteboard.general.string(forType: .string) ?? input
        validate()
    }

    func copyOutput() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(output, forType: .string)
    }

    private func process(minify: Bool) {
        guard !input.isEmpty,
              let data = input.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) else {
            isValid = false
            return
        }
        isValid = true
        var options: JSONSerialization.WritingOptions = minify ? [] : [.prettyPrinted]
        if sortKeys { options.insert(.sortedKeys) }
        if let result = try? JSONSerialization.data(withJSONObject: obj, options: options),
           let str = String(data: result, encoding: .utf8) {
            output = str
        }
    }
}
