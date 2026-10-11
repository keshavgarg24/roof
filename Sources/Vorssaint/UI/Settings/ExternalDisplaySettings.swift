// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct ExternalDisplaySettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = ExternalDisplayService.shared

    private var s: ExternalDisplayStrings { FeatureStrings.externalDisplay(l10n.language) }

    var body: some View {
        Form {
            if svc.displays.isEmpty {
                Section {
                    Text(s.noDisplaysCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 16)
                }
            } else {
                ForEach(svc.displays) { display in
                    Section(display.name) {
                        HStack {
                            Label(s.brightnessLabel, systemImage: "sun.max")
                            Slider(
                                value: Binding(
                                    get: { Double(display.brightness) },
                                    set: { svc.setBrightness(Float($0), for: display) }
                                ), in: 0...1
                            )
                            Text("\(Int(display.brightness * 100))%")
                                .frame(width: 36).foregroundStyle(.secondary)
                        }
                        if !display.isBuiltIn {
                            HStack {
                                Label(s.volumeLabel, systemImage: "speaker.wave.2")
                                Slider(
                                    value: Binding(
                                        get: { Double(display.volume) },
                                        set: { svc.setVolume(Int($0), for: display) }
                                    ), in: 0...100
                                )
                                Text("\(display.volume)%")
                                    .frame(width: 36).foregroundStyle(.secondary)
                            }
                            HStack {
                                Label(s.contrastLabel, systemImage: "circle.lefthalf.filled")
                                Slider(
                                    value: Binding(
                                        get: { Double(display.contrast) },
                                        set: { svc.setContrast(Int($0), for: display) }
                                    ), in: 0...100
                                )
                                Text("\(display.contrast)%")
                                    .frame(width: 36).foregroundStyle(.secondary)
                            }
                            if !display.supportsDDC {
                                Text(s.ddcNotSupported).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            Section {
                Button(s.syncBrightnessLabel) { svc.refresh() }
            }
        }
        .formStyle(.grouped)
        .onAppear { svc.refresh() }
    }
}
