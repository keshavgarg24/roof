// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI

struct NetworkInfoSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var service = NetworkInfoService.shared
    @State private var copied: String?

    var body: some View {
        let s = FeatureStrings.networkInfo(l10n.language)
        Form {
            Section {
                HStack {
                    Text(s.pageTitle).font(.headline)
                    Spacer()
                    Button(s.refreshButton) {
                        Task { service.refresh() }
                    }
                    .buttonStyle(.borderless)
                }
                if let ssid = service.wifiSSID, !ssid.isEmpty {
                    LabeledContent(s.ssidLabel) {
                        Text(ssid).foregroundStyle(.secondary)
                    }
                }
            }

            if service.isLoading {
                Section {
                    HStack {
                        ProgressView().scaleEffect(0.7)
                        Text(s.loadingLabel).foregroundStyle(.secondary)
                    }
                }
            } else if service.interfaces.isEmpty {
                Section {
                    Text(s.noInterface).font(.caption).foregroundStyle(.secondary)
                }
            } else {
                ForEach(service.interfaces) { iface in
                    Section(iface.displayName) {
                        if let ipv4 = iface.ipv4 {
                            infoRow(label: s.ipv4Label, value: ipv4, s: s)
                        }
                        if let ipv6 = iface.ipv6 {
                            infoRow(label: s.ipv6Label, value: ipv6, s: s)
                        }
                        if let mac = iface.macAddress {
                            infoRow(label: s.macLabel, value: mac, s: s)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .task {
            service.refresh()
        }
    }

    private func infoRow(label: String, value: String,
                          s: NetworkInfoStrings) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(copied == value ? s.copiedLabel : value)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(copied == value ? .green : .primary)
            Button(s.copyButton) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(value, forType: .string)
                copied = value
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if copied == value { copied = nil }
                }
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
    }
}
