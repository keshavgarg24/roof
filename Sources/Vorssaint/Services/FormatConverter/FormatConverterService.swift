// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

final class FormatConverterService: ObservableObject {
    static let shared = FormatConverterService()
    private init() {}

    @Published var files: [ConversionFile] = []
    @Published var selectedCategory: ConversionCategory = .image
    @Published var audioFormat: AudioOutputFormat = .aac
    @Published var imageFormat: ImageOutputFormat = .jpeg
    @Published var videoFormat: VideoOutputFormat = .mp4
    @Published var outputDirectory: URL?
    @Published private(set) var isConverting = false

    func syncWithPreferences() {}

    func addFiles(_ urls: [URL]) {
        let new = urls.map { ConversionFile(url: $0) }
        files.append(contentsOf: new)
    }

    func removeFile(_ id: UUID) {
        files.removeAll { $0.id == id }
    }

    func clearAll() { files.removeAll() }

    func convertAll() {
        guard !isConverting else { return }
        isConverting = true
        let group = DispatchGroup()
        for idx in files.indices {
            guard files[idx].status == .pending else { continue }
            files[idx].status = .converting
            let file = files[idx]
            let outDir = FormatConverterSupport.effectiveOutputDir(for: file.url, userChoice: outputDirectory)
            switch file.category {
            case .image:
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    let result = FormatConverterSupport.convertImage(from: file.url, to: outDir, format: self.imageFormat)
                    DispatchQueue.main.async {
                        if let i = self.files.firstIndex(where: { $0.id == file.id }) {
                            self.files[i].status = result != nil ? .done : .failed("Conversion failed")
                            self.files[i].outputURL = result
                        }
                        group.leave()
                    }
                }
            case .audio:
                group.enter()
                FormatConverterSupport.convertAudio(from: file.url, to: outDir, format: audioFormat) { result in
                    if let i = self.files.firstIndex(where: { $0.id == file.id }) {
                        self.files[i].status = result != nil ? .done : .failed("Conversion failed")
                        self.files[i].outputURL = result
                    }
                    group.leave()
                }
            case .video:
                group.enter()
                FormatConverterSupport.convertVideo(from: file.url, to: outDir, format: videoFormat) { result in
                    if let i = self.files.firstIndex(where: { $0.id == file.id }) {
                        self.files[i].status = result != nil ? .done : .failed("Conversion failed")
                        self.files[i].outputURL = result
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { self.isConverting = false }
    }
}
