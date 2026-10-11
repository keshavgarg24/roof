// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct QRCodeGeneratorSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = QRCodeGeneratorService.shared

    private var s: QRCodeGeneratorStrings { FeatureStrings.qrCodeGenerator(l10n.language) }

    var body: some View {
        Form {
            Section(s.pageTitle) {
                TextField(s.inputPlaceholder, text: $svc.inputText, axis: .vertical)
                    .lineLimit(3...6)

                Picker(s.errorCorrectionLabel, selection: $svc.correction) {
                    ForEach(QRErrorCorrection.allCases) { c in
                        Text(c.label).tag(c)
                    }
                }

                Stepper(value: $svc.scale, in: 5...20) {
                    Text("\(s.scaleLabel): \(svc.scale)×")
                }

                Button(s.generateButton) { svc.generate() }
                    .disabled(svc.inputText.isEmpty)
            }

            if let img = svc.qrImage {
                Section {
                    Image(nsImage: img)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .frame(maxWidth: .infinity)

                    HStack {
                        Button(s.copyImageButton) { svc.copyImage() }
                        Button(s.saveImageButton) { svc.saveImage() }
                    }
                }
            } else {
                Section {
                    Text(s.emptyCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
        .formStyle(.grouped)
    }
}
