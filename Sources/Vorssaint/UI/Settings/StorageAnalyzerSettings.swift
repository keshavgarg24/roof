// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Roof

import SwiftUI

struct StorageAnalyzerSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var svc = StorageAnalyzerService.shared

    private var s: StorageAnalyzerStrings { FeatureStrings.storageAnalyzer(l10n.language) }

    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.pageTitle).font(.headline)
                        if svc.isScanning {
                            Text(svc.scanProgress.isEmpty ? s.scanningLabel : svc.scanProgress)
                                .foregroundStyle(.secondary).font(.caption)
                        } else if let sum = svc.summary {
                            Text("\(s.usedLabel): \(StorageAnalyzerSupport.formatSize(sum.used)) / \(StorageAnalyzerSupport.formatSize(sum.total))")
                                .foregroundStyle(.secondary).font(.caption)
                        }
                    }
                    Spacer()
                    Button(s.scanButton) { svc.scan() }
                        .disabled(svc.isScanning)
                }
            }

            if let sum = svc.summary {
                Section(s.noDataCaption.isEmpty ? "" : "") {
                    ForEach(StorageCategory.allCases, id: \.self) { cat in
                        let bytes = sum.byCategory[cat] ?? 0
                        HStack {
                            Label(categoryLabel(cat, s: s), systemImage: categoryIcon(cat))
                            Spacer()
                            Text(StorageAnalyzerSupport.formatSize(bytes))
                                .foregroundStyle(.secondary)
                            let frac = sum.used > 0 ? Double(bytes) / Double(sum.used) : 0
                            ProgressView(value: frac)
                                .frame(width: 60)
                        }
                    }
                }

                if !sum.recommendations.isEmpty {
                    Section(s.recommendationsTitle) {
                        ForEach(sum.recommendations, id: \.self) { rec in
                            Label(rec, systemImage: "lightbulb.fill").foregroundStyle(.orange)
                        }
                    }
                }

                if !sum.largest.isEmpty {
                    Section(s.largestFilesTitle) {
                        ForEach(sum.largest) { item in
                            HStack {
                                Text(item.name).lineLimit(1)
                                Spacer()
                                Text(StorageAnalyzerSupport.formatSize(item.size)).foregroundStyle(.secondary)
                                Button(s.openInFinderButton) {
                                    NSWorkspace.shared.activateFileViewerSelecting([item.url])
                                }
                                .buttonStyle(.borderless)
                                .font(.caption)
                            }
                        }
                    }
                }
            } else if !svc.isScanning {
                Section {
                    Text(s.noDataCaption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func categoryLabel(_ cat: StorageCategory, s: StorageAnalyzerStrings) -> String {
        switch cat {
        case .apps: return s.categoryApps
        case .caches: return s.categoryCaches
        case .documents: return s.categoryDocuments
        case .media: return s.categoryMedia
        case .downloads: return s.categoryDownloads
        case .developer: return s.categoryDeveloper
        case .system: return s.categorySystem
        case .other: return s.categoryOther
        }
    }

    private func categoryIcon(_ cat: StorageCategory) -> String {
        switch cat {
        case .apps: return "app.fill"
        case .caches: return "cylinder.split.1x2.fill"
        case .documents: return "doc.fill"
        case .media: return "photo.fill"
        case .downloads: return "arrow.down.circle.fill"
        case .developer: return "hammer.fill"
        case .system: return "gearshape.fill"
        case .other: return "folder.fill"
        }
    }
}
