// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation

enum TextTransformerOp: String, CaseIterable {
    case uppercase
    case lowercase
    case titleCase
    case camelCase
    case snakeCase
    case kebabCase
    case base64Encode
    case base64Decode
    case urlEncode
    case urlDecode
    case jsonPrettify
    case jsonMinify
    case generateUUID
    case reverse
    case sortLines
    case deduplicateLines
    case trimWhitespace
    case wordCount
    case charCount
    case lineCount

    func apply(to text: String) -> String? {
        switch self {
        case .uppercase:
            return text.uppercased()
        case .lowercase:
            return text.lowercased()
        case .titleCase:
            return text.capitalized
        case .camelCase:
            return TextTransformerSupport.toCamelCase(text)
        case .snakeCase:
            return TextTransformerSupport.toSnakeCase(text)
        case .kebabCase:
            return TextTransformerSupport.toKebabCase(text)
        case .base64Encode:
            return Data(text.utf8).base64EncodedString()
        case .base64Decode:
            guard let data = Data(base64Encoded: text.trimmingCharacters(in: .whitespaces)),
                  let decoded = String(data: data, encoding: .utf8) else { return nil }
            return decoded
        case .urlEncode:
            return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        case .urlDecode:
            return text.removingPercentEncoding
        case .jsonPrettify:
            return TextTransformerSupport.prettifyJSON(text)
        case .jsonMinify:
            return TextTransformerSupport.minifyJSON(text)
        case .generateUUID:
            return UUID().uuidString
        case .reverse:
            return String(text.reversed())
        case .sortLines:
            return text.components(separatedBy: "\n").sorted().joined(separator: "\n")
        case .deduplicateLines:
            var seen = Set<String>()
            return text.components(separatedBy: "\n").filter { seen.insert($0).inserted }.joined(separator: "\n")
        case .trimWhitespace:
            return text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
        case .wordCount:
            let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            return "\(words.count) words"
        case .charCount:
            return "\(text.count) characters"
        case .lineCount:
            let lines = text.components(separatedBy: "\n")
            return "\(lines.count) lines"
        }
    }
}

enum TextTransformerSupport {
    static func toCamelCase(_ text: String) -> String {
        let words = text.components(separatedBy: .init(charactersIn: " _-"))
            .filter { !$0.isEmpty }
        guard !words.isEmpty else { return text }
        let first = words[0].lowercased()
        let rest = words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
        return ([first] + rest).joined()
    }

    static func toSnakeCase(_ text: String) -> String {
        text.components(separatedBy: .init(charactersIn: " -"))
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
            .joined(separator: "_")
    }

    static func toKebabCase(_ text: String) -> String {
        text.components(separatedBy: .init(charactersIn: " _"))
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
            .joined(separator: "-")
    }

    static func prettifyJSON(_ text: String) -> String? {
        guard let data = text.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let result = String(data: pretty, encoding: .utf8) else { return nil }
        return result
    }

    static func minifyJSON(_ text: String) -> String? {
        guard let data = text.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let minified = try? JSONSerialization.data(withJSONObject: obj),
              let result = String(data: minified, encoding: .utf8) else { return nil }
        return result
    }
}
