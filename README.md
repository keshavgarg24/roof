<div align="center">
  <img src="Resources/Brand/AppIcon-Default.png" width="128" height="128" alt="Roof icon" />
  <h1>Roof</h1>
  <p><strong>The all-in-one macOS menu bar utility</strong><br/>
  Every tool you reach for, one click away.</p>

  <p>
    <a href="https://github.com/keshavgarg24/roof/releases/latest">
      <img src="https://img.shields.io/github/v/release/keshavgarg24/roof?label=Download&style=flat-square" alt="Latest release" />
    </a>
    <img src="https://img.shields.io/badge/macOS-14%2B-blue?style=flat-square" alt="macOS 14+" />
    <img src="https://img.shields.io/badge/Swift-6-orange?style=flat-square" alt="Swift 6" />
    <img src="https://img.shields.io/badge/license-GPL--3.0-green?style=flat-square" alt="GPL-3.0" />
  </p>

  <p>
    <a href="https://github.com/keshavgarg24/roof/releases">Download</a> ·
    <a href="https://github.com/keshavgarg24/roof/issues">Report a Bug</a> ·
    <a href="https://roof.place">Website</a> ·
    <a href="https://x.com/roof_place">Follow on X</a>
  </p>
</div>

---

## Overview

**Roof** is a free, open-source macOS menu bar utility that consolidates over 100 essential tools — system monitoring, clipboard management, window layout, media controls, file utilities, developer tools, and much more — under a single, elegant menu bar icon.

Built on top of [vorssaint-utils](https://github.com/vorssaint/vorssaint-utils) as the foundational base, Roof significantly enhances and extends every tool category with new features, improved UI, and deeper macOS integration. The tools are not just repackaged — they are rebuilt and refined.

> **Attribution**: Roof is derived from [vorssaint-utils](https://github.com/vorssaint/vorssaint-utils) (GPL-3.0). The original codebase provided the architecture and core tool implementations. Roof adds extensive UI improvements, new tools, bug fixes, and a fresh identity on top of that base.

---

## Download

**[→ Download the latest release (.dmg)](https://github.com/keshavgarg24/roof/releases/latest)**

Requires **macOS 14 Sonoma or later** on Apple Silicon or Intel.

1. Download `Roof.dmg` from the releases page
2. Open the DMG and drag `Roof.app` to your Applications folder
3. Launch Roof — it will appear in your menu bar immediately
4. Grant requested permissions (Accessibility, Screen Recording) for full functionality

---

## What's Inside

Roof brings 100+ tools across 10 categories, all accessible from one menu bar icon.

### System Monitoring
Real-time CPU, memory, disk, network, battery, and fan metrics in a compact panel. CPU core matrix, per-process usage, and sparkline history — no separate app needed.

### Clipboard Manager
Persistent clipboard history with full-text search, image thumbnails, and a quick-panel for instant access. Pin frequently used items and clear sensitive entries with one click.

### Window Layout
Snap, resize, and arrange windows using keyboard shortcuts or the quick-panel grid. Multi-monitor aware. Supports custom layout presets you define once and trigger anywhere.

### Volume Mixer
Per-app volume sliders that let you independently control every audio source on your Mac. Mute one app without touching others. Integrates with the Dynamic Island-style notch bar.

### Keep Awake
Prevent your Mac from sleeping on demand — set a duration, tie it to a specific app staying open, or keep it permanent until you turn it off. Full menu bar icon feedback.

### Media Controls
Now Playing controls with artwork, skip/pause, volume — without switching apps. Supports Spotify, Apple Music, and any media app using the system now-playing API.

### Dynamic Island / Notch Bar
A notification-bar style overlay at the top of your screen showing now-playing music, quick toggle controls, and live metrics. Completely optional and fully configurable.

### Developer Tools
- **QR Code Generator** — instant QR from any text or URL
- **JSON Formatter** — format, validate, and copy JSON
- **Color Converter** — HEX, RGB, HSL, HSB, SwiftUI, CSS — all in one place
- **Unit Converter** — length, weight, temperature, data size, and more
- **Command Bar** — run any shell command from the menu bar
- **Port Manager** — see what's running on which ports
- **WiFi Scanner** — nearby networks with signal strength

### File & App Utilities
- **Storage Analyzer** — visual disk usage breakdown
- **Uninstaller** — remove apps and their leftover files cleanly
- **File Tag Manager** — bulk-tag Finder files
- **Format Converter** — convert images and documents
- **Homebrew Manager** — update, install, and audit packages from the menu bar

### Privacy & Security
- **Screen Recording Controls** — start/stop recordings with system audio included
- **Secret Vault** — encrypted local notes (no cloud, no sync)
- **URL Cleaner** — strip tracking parameters from links instantly
- **Camera Preview** — quick webcam check without launching any app

### Productivity
- **Snippet Library** — text snippets triggered by short codes
- **Time Tracker** — simple per-project time tracking from the menu bar
- **App Relauncher** — quick-kill and relaunch any running app
- **Package Tracker** — track shipments inline

---

## Building from Source

### Requirements

- macOS 14.0+
- Xcode 16+ (for the Swift toolchain)
- No additional dependencies — fully self-contained

### Steps

```bash
git clone https://github.com/keshavgarg24/roof.git
cd roof
./build.sh --install
```

This compiles the app, generates icons, and installs `Roof.app` to `/Applications`.

To build the Developer variant (auto-updates disabled, console logging on):

```bash
./build.sh --install --developer
```

To run the test suite:

```bash
./build.sh --test
```

### Code Structure

```
Sources/Vorssaint/       # App source (module name kept from upstream for ABI compat)
  Core/                  # App lifecycle, preferences, feature catalog
  Services/              # Per-tool business logic (one sub-folder per tool)
  UI/                    # SwiftUI + AppKit views
    MenuPanel/           # Dropdown panel (the main UI surface)
    Settings/            # Per-tool settings pages
    Notch/               # Dynamic Island overlay
Resources/               # Icons, localizations, embedded assets
Tests/                   # Automated tests (1000+ checks)
Tools/                   # Build tools: icon generator, DMG maker, notarizer
```

---

## Permissions

Roof requests only what each tool actually needs:

| Permission | Used for |
|---|---|
| Accessibility | Window layout, command bar, global hotkeys |
| Screen Recording | Screen recorder, notch bar, external display controls |
| Automation | File operations, media app control |
| Bluetooth | Peripheral battery levels |
| Microphone | Camera preview audio (optional) |

All data stays on your Mac. Nothing is transmitted anywhere.

---

## Contributing

Bug reports and feature requests are welcome via [GitHub Issues](https://github.com/keshavgarg24/roof/issues).

For pull requests, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

GPL-3.0 — see [LICENSE](LICENSE).

Roof is derived from [vorssaint-utils](https://github.com/vorssaint/vorssaint-utils) which is also GPL-3.0.
The `libVorssaintNowPlaying.dylib` binary adapter is part of the upstream codebase and retains its original identifier for ABI compatibility.

---

<div align="center">
  Made by <a href="https://github.com/keshavgarg24">keshavgarg24</a> · <a href="https://roof.place">roof.place</a>
</div>
