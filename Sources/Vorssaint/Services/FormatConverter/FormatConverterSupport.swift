// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import AVFoundation
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ConversionCategory: String, CaseIterable, Identifiable {
    case audio, image, video
    var id: String { rawValue }
}

enum AudioOutputFormat: String, CaseIterable, Identifiable {
    case mp3 = "MP3"
    case aac = "AAC (M4A)"
    case wav = "WAV"
    case flac = "FLAC"
    case aiff = "AIFF"
    var id: String { rawValue }
    var fileExtension: String {
        switch self { case .mp3: return "mp3"; case .aac: return "m4a"; case .wav: return "wav"; case .flac: return "flac"; case .aiff: return "aiff" }
    }
    var avPreset: String? {
        switch self { case .aac: return AVAssetExportPresetAppleM4A; default: return nil }
    }
}

enum ImageOutputFormat: String, CaseIterable, Identifiable {
    case jpeg = "JPEG"
    case png = "PNG"
    case heic = "HEIC"
    case webp = "WebP"
    case tiff = "TIFF"
    case bmp = "BMP"
    var id: String { rawValue }
    var fileExtension: String {
        switch self { case .jpeg: return "jpg"; case .png: return "png"; case .heic: return "heic"; case .webp: return "webp"; case .tiff: return "tiff"; case .bmp: return "bmp" }
    }
    var utType: UTType {
        switch self { case .jpeg: return .jpeg; case .png: return .png; case .heic: return .heic; case .webp: return .webP; case .tiff: return .tiff; case .bmp: return .bmp }
    }
}

enum VideoOutputFormat: String, CaseIterable, Identifiable {
    case mp4 = "MP4"
    case mov = "MOV"
    case m4v = "M4V"
    var id: String { rawValue }
    var fileExtension: String {
        switch self { case .mp4: return "mp4"; case .mov: return "mov"; case .m4v: return "m4v" }
    }
    var avPreset: String {
        switch self { case .mp4, .m4v: return AVAssetExportPresetHighestQuality; case .mov: return AVAssetExportPresetHighestQuality }
    }
    var fileType: AVFileType {
        switch self { case .mp4: return .mp4; case .mov: return .mov; case .m4v: return .m4v }
    }
}

struct ConversionFile: Identifiable {
    let id = UUID()
    let url: URL
    var status: ConversionStatus = .pending
    var outputURL: URL?
    enum ConversionStatus: Equatable { case pending, converting, done, failed(String) }
    var category: ConversionCategory {
        let ext = url.pathExtension.lowercased()
        if ["mp3","m4a","wav","aac","flac","aiff","ogg","opus"].contains(ext) { return .audio }
        if ["jpg","jpeg","png","heic","webp","tiff","bmp","gif"].contains(ext) { return .image }
        return .video
    }
}

enum FormatConverterSupport {
    static func convertImage(from input: URL, to outputDir: URL, format: ImageOutputFormat) -> URL? {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        let outputURL = outputDir.appendingPathComponent(input.deletingPathExtension().lastPathComponent + "." + format.fileExtension)
        guard let dest = CGImageDestinationCreateWithURL(outputURL as CFURL, format.utType.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(dest, image, nil)
        return CGImageDestinationFinalize(dest) ? outputURL : nil
    }

    static func convertAudio(from input: URL, to outputDir: URL, format: AudioOutputFormat, completion: @escaping (URL?) -> Void) {
        guard let preset = format.avPreset else {
            // For non-AVFoundation formats, fall back gracefully
            completion(nil)
            return
        }
        let asset = AVURLAsset(url: input)
        let outputURL = outputDir.appendingPathComponent(input.deletingPathExtension().lastPathComponent + "." + format.fileExtension)
        try? FileManager.default.removeItem(at: outputURL)
        guard let session = AVAssetExportSession(asset: asset, presetName: preset) else { completion(nil); return }
        session.outputURL = outputURL
        session.outputFileType = .m4a
        session.exportAsynchronously { completion(session.status == .completed ? outputURL : nil) }
    }

    static func convertVideo(from input: URL, to outputDir: URL, format: VideoOutputFormat, completion: @escaping (URL?) -> Void) {
        let asset = AVURLAsset(url: input)
        let outputURL = outputDir.appendingPathComponent(input.deletingPathExtension().lastPathComponent + "." + format.fileExtension)
        try? FileManager.default.removeItem(at: outputURL)
        guard let session = AVAssetExportSession(asset: asset, presetName: format.avPreset) else { completion(nil); return }
        session.outputURL = outputURL
        session.outputFileType = format.fileType
        session.exportAsynchronously { completion(session.status == .completed ? outputURL : nil) }
    }

    static func effectiveOutputDir(for input: URL, userChoice: URL?) -> URL {
        userChoice ?? input.deletingLastPathComponent()
    }
}
