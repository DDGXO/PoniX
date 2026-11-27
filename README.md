# PoniX for Linux

![Wayland](https://img.shields.io/badge/Wayland-Layer%20Shell-1f2937?style=flat-square)
![Hyprland](https://img.shields.io/badge/Hyprland-Compatible-0a84ff?style=flat-square)
![Quickshell](https://img.shields.io/badge/Quickshell-QML%20%2F%20JS-38bdf8?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Linux-22c55e?style=flat-square)

A Dynamic Island shell for Hyprland and Wayland desktops, built in pure Quickshell (QML and JavaScript) with zero compilation required.

---

## Overview

PoniX anchors at the top edge of your active monitor (or follows your cursor across multi-monitor setups) as a compact, interactive pill. When resting, it displays the clock, battery indicators, live audio lyrics, active timers, or cursor-tracking companion eyes. Clicking or hovering expands it into a modular workspace hub.

## Highlights

- **Real-Time Liquid Glass Shader**: Captures the active Hyprland toplevel behind the island at 60fps via `ScreencopyView` and applies Snell's law refraction and chromatic dispersion (`shaders/liquid_glass.frag`), with compositor blur fallback.
- **31 Built-in Themes**: Includes `Classic`, `Liquid`, `Diorama`, `Glass`, `Pill`, `Pixel Art`, `ASCII`, 10 terminal palettes (`Tokyo Night`, `Catppuccin`, `Kanagawa`, `Dracula`, `Nord`, `Gruvbox`, `Rose Pine`, `Solarized`, `Monokai`, `Everforest`), 6 CRT/Retro themes, and 8 atmospheric vibes.
- **Live Visual Engines**:
  - **Diorama**: 200 animated canvas scenes across `Scenery`, `Cosmic`, `City`, and `Game`.
  - **Pixel Art**: 50 dedicated aesthetic pixel-art scenes rendered on a crisp 2px grid.
- **Music & Word-by-Word Karaoke Lyrics**:
  - MPRIS2 integration (`playerctl`) with YouTube thumbnail extraction (`i.ytimg.com`) and iTunes/Deezer artwork fallback.
  - 16-band real-time `cava` audio spectrum visualizer.
  - Synced lyrics via LRCLIB with 20Hz word-by-word highlighting, click-to-seek, and optional CJK/Japanese romanization.
- **Modular Add-ons**:
  - **Agent Terminal**: Embedded PTY terminal for `agy` (Antigravity) and `claude` (Claude Code) with `Normal`, `Plan`, and `Dangerously` launch modes, `-c` continue toggle, and one-click exit.
  - **Server & Homelab Watch**: Periodic `HTTP`, `TCP`, and `PING` uptime/latency checks with quick `SSH` terminal launch.
  - **Audio & Device Mixer**: PipeWire/PulseAudio output and microphone sliders, mute toggles, and device switching.
  - **Clipboard History**: Searchable copy-paste history (`cliphist` / `wl-paste`) with pinning.
  - **Color Picker & Capture**: Screen color picker (`hyprpicker`) with swatch history and region/fullscreen screenshots (`grim` + `slurp`).
  - **Weather & Rain Alert**: Current conditions, rain probability, and hourly forecast.
  - **QR & Local File Share**: Clipboard-to-QR generator and temporary LAN HTTP file server.
  - **Quick Translator**: Inline multi-language translation (`Auto->ID`, `ID->EN`, `EN->ID`, `JA->ID`).
  - **System, Prayer, Downloads, Stocks, Caffeine, Teleprompter, Recorder, Notes, Health, IELTS**: All toggleable from the Add-ons tab.

---

## Requirements

### Core Dependencies

| Package | Purpose |
| --- | --- |
| `quickshell` | QML/Wayland shell runtime |
| `git` | Installation and self-updates |
| `curl` | Lyrics, weather, artwork, and translation requests |
| `playerctl` | MPRIS media metadata and playback control |
| `python3` | Embedded PTY bridge and LAN file sharing |

Install core packages on Arch Linux:

```bash
sudo pacman -S quickshell git curl playerctl python
```

### Optional Add-on Dependencies

| Package | Add-on |
| --- | --- |
| `cava` | Music 16-band audio visualizer |
| `wl-clipboard`, `cliphist` | Clipboard history and copy actions |
| `grim`, `slurp`, `hyprpicker` | Screenshots and color picker |
| `wf-recorder` | Wayland screen and region recording |
| `yt-dlp` | Video and audio downloader |
| `qrencode` | Offline QR code generation |
| `zenity` or `kdialog` | File and directory picker dialogs |

---

## Installation

Install directly into `~/.dgxo/ponix`:

```bash
curl -fsSL https://raw.githubusercontent.com/DDGXO/PoniX/linux/install.sh | bash
```

### Manual Installation

```bash
mkdir -p ~/.dgxo
git clone --branch linux --depth 1 https://github.com/DDGXO/PoniX.git ~/.dgxo/ponix
chmod +x ~/.dgxo/ponix/launch.sh ~/.dgxo/ponix/install.sh ~/.dgxo/ponix/scripts/pty_bridge.py
```

---

## Hyprland Configuration

Add the following to `~/.config/hypr/hyprland.conf`:

```ini
# Autostart PoniX
exec-once = ~/.dgxo/ponix/launch.sh

# Toggle island expansion
bind = SUPER, P, exec, qs ipc -p ~/.dgxo/ponix/shell.qml call ponix toggle
```

To start PoniX immediately without restarting Hyprland:

```bash
~/.dgxo/ponix/launch.sh &
```

---

## IPC Commands

Control PoniX from scripts or custom keybinds:

| Command | Action |
| --- | --- |
| `qs ipc -p ~/.dgxo/ponix/shell.qml call ponix toggle` | Toggle expanded/collapsed state |
| `qs ipc -p ~/.dgxo/ponix/shell.qml call ponix open <tab>` | Expand directly to a tab (`music`, `today`, `shelf`, `tasks`, `focus`, `addons`, `settings`) |
| `qs ipc -p ~/.dgxo/ponix/shell.qml call ponix close` | Collapse island |
| `qs ipc -p ~/.dgxo/ponix/shell.qml call ponix play` | Play/pause active media player |
| `qs ipc -p ~/.dgxo/ponix/shell.qml call ponix next` | Next track |
| `qs ipc -p ~/.dgxo/ponix/shell.qml call ponix prev` | Previous track |
| `qs ipc -p ~/.dgxo/ponix/shell.qml call ponix focus` | Toggle focus timer |

---

## Updates

Open **Settings** in the island footer and click **Check Updates** to compare against `https://github.com/DDGXO/PoniX.git`, then click **Updates** to download and apply updates in place. You can also re-run the installer command at any time.

---

## License

- **Source Code**: [MIT License](LICENSE) (`Copyright (c) 2026 Dream & Driven Generation eXperience Operations (DGXO)`).
- **Brand Assets & Third-Party Icons**: Governed by [assets/LICENSE](assets/LICENSE) (`All Rights Reserved` for PoniX/DGXO marks; third-party icons remain the property of their respective owners; Outfit fonts under SIL OFL 1.1).
