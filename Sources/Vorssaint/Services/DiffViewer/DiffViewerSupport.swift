// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

enum DiffLineType {
    case unchanged, added, removed
}

struct DiffLine: Identifiable {
    let id = UUID()
    let type: DiffLineType
    let lineNumber: Int?   // original line number (nil for added lines)
    let newLineNumber: Int? // new line number (nil for removed lines)
    let text: String
}

enum DiffViewerSupport {
    static func diff(original: String, modified: String) -> [DiffLine] {
        let originalLines = original.components(separatedBy: "\n")
        let modifiedLines = modified.components(separatedBy: "\n")
        return lcs(originalLines, modifiedLines)
    }

    // Simple LCS-based line diff
    private static func lcs(_ a: [String], _ b: [String]) -> [DiffLine] {
        let n = a.count, m = b.count
        var dp = [[Int]](repeating: [Int](repeating: 0, count: m + 1), count: n + 1)
        for i in 1...max(n, 1) where i <= n {
            for j in 1...max(m, 1) where j <= m {
                if a[i - 1] == b[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        var result: [DiffLine] = []
        var i = n, j = m
        var origLine = n, newLine = m

        while i > 0 || j > 0 {
            if i > 0 && j > 0 && a[i - 1] == b[j - 1] {
                result.append(DiffLine(type: .unchanged, lineNumber: i, newLineNumber: j, text: a[i - 1]))
                i -= 1; j -= 1
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                result.append(DiffLine(type: .added, lineNumber: nil, newLineNumber: j, text: b[j - 1]))
                j -= 1
            } else {
                result.append(DiffLine(type: .removed, lineNumber: i, newLineNumber: nil, text: a[i - 1]))
                i -= 1
            }
        }

        return result.reversed()
    }

    static func addedCount(_ lines: [DiffLine]) -> Int {
        lines.filter { $0.type == .added }.count
    }

    static func removedCount(_ lines: [DiffLine]) -> Int {
        lines.filter { $0.type == .removed }.count
    }
}
