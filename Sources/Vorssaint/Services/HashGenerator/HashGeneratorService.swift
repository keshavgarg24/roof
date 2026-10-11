// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import AppKit
import Foundation

final class HashGeneratorService: ObservableObject {
    static let shared = HashGeneratorService()

    @Published var inputText = ""
    @Published private(set) var hashes: [(HashAlgorithm, String)] = []
    @Published var selectedFile: URL?

    private init() {}

    func syncWithPreferences() {}

    func compute() {
        if let file = selectedFile, let data = try? Data(contentsOf: file) {
            hashes = HashGeneratorSupport.allHashes(of: data)
        } else if !inputText.isEmpty {
            hashes = HashGeneratorSupport.allHashes(of: inputText)
        } else {
            hashes = []
        }
    }

    func pasteFromClipboard() {
        GeneralPasteboardAccess.shared.async({
            NSPasteboard.general.string(forType: .string) ?? ""
        }, then: { [weak self] text in
            self?.inputText = text
            self?.selectedFile = nil
            self?.compute()
        })
    }

    func hash(_ algorithm: HashAlgorithm) -> String {
        hashes.first(where: { $0.0 == algorithm })?.1 ?? ""
    }
}
