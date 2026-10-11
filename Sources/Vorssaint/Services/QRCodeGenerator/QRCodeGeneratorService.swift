// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import SwiftUI
import AppKit

final class QRCodeGeneratorService: ObservableObject {
    static let shared = QRCodeGeneratorService()
    private init() {}

    @Published var inputText: String = ""
    @Published var qrImage: NSImage?
    @Published var correction: QRErrorCorrection = .medium
    @Published var scale: Int = 10

    func syncWithPreferences() {}

    func generate() {
        qrImage = QRCodeGeneratorSupport.generate(text: inputText, correction: correction, scale: scale)
    }

    func copyImage() {
        guard let img = qrImage else { return }
        QRCodeGeneratorSupport.copyToPasteboard(img)
    }

    func saveImage() {
        guard let img = qrImage else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "qr-code.png"
        if panel.runModal() == .OK, let url = panel.url {
            try? QRCodeGeneratorSupport.save(img, to: url)
        }
    }
}
