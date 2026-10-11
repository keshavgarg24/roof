// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Canopy

import SwiftUI
import AppKit

struct WiFiScannerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = WiFiScannerService.shared

    private var s: WiFiScannerStrings { FeatureStrings.wifiScanner(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    Button(svc.isScanning ? s.scanningLabel : s.scanButton) { svc.scan() }
                        .disabled(svc.isScanning)
                    if svc.isScanning { ProgressView().scaleEffect(0.7) }
                    Spacer()
                    Text(s.permissionNote).font(.caption).foregroundStyle(.secondary)
                }
            }

            if let current = svc.currentNetwork {
                Section(s.currentNetworkSection) {
                    networkRow(current)
                }
            }

            if !svc.networks.isEmpty {
                Section(s.nearbyNetworksSection) {
                    ForEach(svc.networks.filter { !$0.isCurrent }) { net in
                        networkRow(net)
                    }
                }
            } else if !svc.isScanning {
                Section {
                    Text(s.noNetworksCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { svc.syncWithPreferences() }
    }

    private func networkRow(_ net: WiFiNetwork) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "wifi", variableValue: Double(net.signalBars) / 4.0)
                .foregroundStyle(signalColor(net.signalStrength))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(net.ssid).fontWeight(net.isCurrent ? .semibold : .regular)
                HStack(spacing: 6) {
                    Text("Ch \(net.channel)").font(.caption).foregroundStyle(.secondary)
                    Text(net.security).font(.caption).foregroundStyle(.secondary)
                    Text("\(net.rssi) dBm").font(.caption).foregroundStyle(.secondary)
                }
            }

            Spacer()
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(net.ssid, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 2)
    }

    private func signalColor(_ strength: WiFiSignalStrength) -> Color {
        switch strength {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .weak: return .red
        }
    }
}
