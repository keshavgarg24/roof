// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import CryptoKit
import Foundation

enum HashAlgorithm: String, CaseIterable, Identifiable {
    case md5    = "MD5"
    case sha1   = "SHA-1"
    case sha256 = "SHA-256"
    case sha512 = "SHA-512"

    var id: String { rawValue }
}

enum HashGeneratorSupport {
    static func hash(_ algorithm: HashAlgorithm, of data: Data) -> String {
        switch algorithm {
        case .md5:
            return Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
        case .sha1:
            return Insecure.SHA1.hash(data: data).map { String(format: "%02x", $0) }.joined()
        case .sha256:
            return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        case .sha512:
            return SHA512.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }
    }

    static func hash(_ algorithm: HashAlgorithm, of text: String) -> String {
        let data = Data(text.utf8)
        return hash(algorithm, of: data)
    }

    static func allHashes(of text: String) -> [(HashAlgorithm, String)] {
        HashAlgorithm.allCases.map { ($0, hash($0, of: text)) }
    }

    static func allHashes(of data: Data) -> [(HashAlgorithm, String)] {
        HashAlgorithm.allCases.map { ($0, hash($0, of: data)) }
    }
}
