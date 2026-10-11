// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct ColorConverterSettings: View {
    @ObservedObject private var service = ColorConverterService.shared
    @ObservedObject private var l10n = L10n.shared

    private var s: ColorConverterStrings { FeatureStrings.colorConverter(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: service.rgb.r / 255, green: service.rgb.g / 255, blue: service.rgb.b / 255, opacity: service.rgb.a))
                        .frame(width: 60, height: 60)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.3)))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(s.hexLabel)
                                .foregroundStyle(.secondary)
                                .frame(width: 50, alignment: .leading)
                            TextField(s.hexLabel, text: $service.hexInput)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                                .onSubmit { service.applyHex(service.hexInput) }
                            Button {
                                service.pasteHexFromClipboard()
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            .buttonStyle(.plain)
                            Button {
                                service.copyHex()
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } header: {
                Text(s.colorSection)
            }

            Section {
                rgbRow
                hslRow
                hsbRow
            } header: {
                Text(s.formatsSection)
            }

            Section {
                HStack {
                    Text(s.swiftUILabel)
                        .foregroundStyle(.secondary)
                        .frame(width: 70, alignment: .leading)
                    Text(service.swiftUIString)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        service.copySwiftUI()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                }
                HStack {
                    Text(s.cssRGBALabel)
                        .foregroundStyle(.secondary)
                        .frame(width: 70, alignment: .leading)
                    Text(service.cssRGBAString)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                    Spacer()
                    Button {
                        NSPasteboard.general.declareTypes([.string], owner: nil)
                        NSPasteboard.general.setString(service.cssRGBAString, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text(s.codeSection)
            }
        }
        .formStyle(.grouped)
    }

    private var rgbRow: some View {
        HStack {
            Text(s.rgbLabel)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            Text("\(Int(service.rgb.r.rounded())), \(Int(service.rgb.g.rounded())), \(Int(service.rgb.b.rounded()))")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private var hslRow: some View {
        HStack {
            Text(s.hslLabel)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            Text("\(service.hsl.h.formatted(.number.precision(.fractionLength(1))))°, \(service.hsl.s.formatted(.number.precision(.fractionLength(1))))%, \(service.hsl.l.formatted(.number.precision(.fractionLength(1))))%")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private var hsbRow: some View {
        HStack {
            Text(s.hsbLabel)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            Text("\(service.hsb.h.formatted(.number.precision(.fractionLength(1))))°, \(service.hsb.s.formatted(.number.precision(.fractionLength(1))))%, \(service.hsb.b.formatted(.number.precision(.fractionLength(1))))%")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
    }
}
