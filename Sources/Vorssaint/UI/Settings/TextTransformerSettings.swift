// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct TextTransformerSettings: View {
    @ObservedObject private var l10n = L10n.shared

    var body: some View {
        let s = FeatureStrings.textTransformer(l10n.language)
        Form {
            Section {
                Text(s.subtitle)
                    .font(.headline)
                Text(s.hubDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Case") {
                opRow(title: s.opUppercase, icon: "textformat.abc")
                opRow(title: s.opLowercase, icon: "textformat.abc")
                opRow(title: s.opTitleCase, icon: "textformat.abc")
                opRow(title: s.opCamelCase, icon: "textformat")
                opRow(title: s.opSnakeCase, icon: "textformat")
                opRow(title: s.opKebabCase, icon: "textformat")
            }
            Section("Encoding") {
                opRow(title: s.opBase64Encode, icon: "lock.doc")
                opRow(title: s.opBase64Decode, icon: "lock.open.doc")
                opRow(title: s.opURLEncode, icon: "link")
                opRow(title: s.opURLDecode, icon: "link")
            }
            Section("JSON") {
                opRow(title: s.opJSONPrettify, icon: "curlybraces")
                opRow(title: s.opJSONMinify, icon: "curlybraces")
            }
            Section("Utilities") {
                opRow(title: s.opGenerateUUID, icon: "number")
                opRow(title: s.opReverse, icon: "arrow.left.arrow.right")
                opRow(title: s.opSortLines, icon: "list.number")
                opRow(title: s.opDeduplicateLines, icon: "list.bullet.indent")
                opRow(title: s.opTrimWhitespace, icon: "space")
                opRow(title: s.opWordCount, icon: "textformat.123")
                opRow(title: s.opCharCount, icon: "character.cursor.ibeam")
                opRow(title: s.opLineCount, icon: "list.number")
            }
            Section {
                Text("All transforms read from and write back to the clipboard. Use them via the Command Bar.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func opRow(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(.secondary)
            Text(title)
        }
    }
}
