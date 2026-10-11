// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import Foundation

struct FormatConverterStrings {
    let pageTitle: String
    let hubDescription: String
    let addFilesButton: String
    let clearButton: String
    let convertButton: String
    let outputFormatLabel: String
    let outputFolderLabel: String
    let chooseOutputButton: String
    let sameAsFolderOption: String
    let convertingLabel: String
    let doneLabel: String
    let categoryAudio: String
    let categoryImage: String
    let categoryVideo: String
    let noFilesCaption: String
    let dropFilesHint: String
    let openOutputButton: String

    static let enUS = FormatConverterStrings(
        pageTitle: "Format Converter",
        hubDescription: "Convert audio, images and videos between formats locally — no uploads, no cloud.",
        addFilesButton: "Add Files…",
        clearButton: "Clear",
        convertButton: "Convert",
        outputFormatLabel: "Output Format",
        outputFolderLabel: "Save To",
        chooseOutputButton: "Choose…",
        sameAsFolderOption: "Same as source",
        convertingLabel: "Converting…",
        doneLabel: "Done",
        categoryAudio: "Audio",
        categoryImage: "Image",
        categoryVideo: "Video",
        noFilesCaption: "Add files to convert.",
        dropFilesHint: "Drag and drop files here, or click Add Files.",
        openOutputButton: "Show Output"
    )
}

extension FeatureStrings {
    static func formatConverter(_ language: AppLanguage) -> FormatConverterStrings {
        switch language {
        case .enUS, .ptBR, .tr, .ru, .es, .sk, .de, .fr, .it, .ja, .ko, .zhHans, .zhTW, .zhHK, .uk:
            return .enUS
        }
    }
}
