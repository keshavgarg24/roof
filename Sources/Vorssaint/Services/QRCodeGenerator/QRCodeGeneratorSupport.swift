// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import Foundation
import CoreImage
import AppKit

enum QRErrorCorrection: String, CaseIterable, Identifiable {
    case low = "L", medium = "M", quartile = "Q", high = "H"
    var id: String { rawValue }
    var label: String {
        switch self {
        case .low: return "Low (7%)"
        case .medium: return "Medium (15%)"
        case .quartile: return "Quartile (25%)"
        case .high: return "High (30%)"
        }
    }
}

enum QRCodeGeneratorSupport {
    static func generate(text: String, correction: QRErrorCorrection, scale: Int) -> NSImage? {
        guard !text.isEmpty,
              let data = text.data(using: .utf8) else { return nil }

        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue(correction.rawValue, forKey: "inputCorrectionLevel")

        guard let ciImage = filter?.outputImage else { return nil }

        let transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        let scaled = ciImage.transformed(by: transform)

        let rep = NSCIImageRep(ciImage: scaled)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }

    static func copyToPasteboard(_ image: NSImage) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([image])
    }

    static func save(_ image: NSImage, to url: URL) throws {
        guard let tiff = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiff),
              let png = bitmapRep.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try png.write(to: url)
    }
}
