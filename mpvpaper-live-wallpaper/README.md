<div align="center">

<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30"/>

```
███╗   ███╗██████╗ ██╗   ██╗██████╗  █████╗ ██████╗ ███████╗██████╗
████╗ ████║██╔══██╗██║   ██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
██╔████╔██║██████╔╝██║   ██║██████╔╝███████║██████╔╝█████╗  ██████╔╝
██║╚██╔╝██║██╔═══╝ ╚██╗ ██╔╝██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
██║ ╚═╝ ██║██║      ╚████╔╝ ██║     ██║  ██║██║     ███████╗██║  ██║
╚═╝     ╚═╝╚═╝       ╚═══╝  ╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
         L I V E   W A L L P A P E R   —   C A E L E S T I A
```

**Live video/GIF wallpapers for Hyprland + Caelestia, powered by mpvpaper**

[![Hyprland](https://img.shields.io/badge/Hyprland-v0.40+-58e1ff?style=flat-square&logo=linux&logoColor=white)](https://hyprland.org)
[![Caelestia](https://img.shields.io/badge/Caelestia-Dotfiles-c9cbff?style=flat-square)](https://github.com/caelestia-dots)
[![mpvpaper](https://img.shields.io/badge/mpvpaper-latest-a6e3a1?style=flat-square)](https://github.com/GhostNaN/mpvpaper)
[![Shell](https://img.shields.io/badge/Shell-Bash-89dceb?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-f5c2e7?style=flat-square)](LICENSE)

</div>

---

## ✦ What This Is

A fully-fixed, production-ready live wallpaper system for **Caelestia dotfile users** on Hyprland. Drop a video or GIF into a folder, press a key — your desktop becomes a live wallpaper, desktop clock and widgets still showing, colors extracted and applied automatically.

All of the bugs that plague a naive mpvpaper setup have been hunted down and eliminated:

| Bug | Fix Applied |
|-----|------------|
| GPU crashes / overheating | `--auto-pause` pauses decode when wallpaper is hidden (fullscreen game/app) |
| Wrong GPU decoder (vaapi → Intel iGPU on NVIDIA laptops) | `hwdec=nvdec` forces the NVIDIA NVDEC engine |
| Widgets (desktop clock) disappear on live wallpaper | Set `wallpaperEnabled=false` only — not `background.enabled=false` |
| Static GIFs (mpvpaper can't loop GIFs) | GIFs are converted to MP4 via ffmpeg before playback |
| Memory dumps / shell crashes on wallpaper change | Atomic `shell.json` writes (tmp→rename) + startup guard |
| Color picker interference | Guard at start of script; color extraction skipped if hyprpicker is running |
| Log file growing to 14k+ lines per run | mpvpaper output redirected to `/dev/null`; log rotation at 500KB |
| Blank wallpaper on startup (race condition) | Waits for Hyprland compositor socket + monitor before launching mpvpaper |

---

## ✦ File Map

```
mpvpaper-live-wallpaper/
│
├── scripts/                         # → Install to ~/.config/hypr/scripts/
│   ├── live-wallpaper.sh            #   Core: launches mpvpaper, handles GIFs, extracts colors
│   ├── wallpaper-hook.sh            #   Hook: runs after `caelestia wallpaper -f <image>`
│   ├── wallpaper-startup.sh         #   Boot: restores wallpaper state on login
│   └── set-wallpaper.sh             #   Router: routes any file to correct handler
│
└── transcode-wallpapers.sh          # → Run manually from ~/Pictures/Wallpapers/
                                     #   Batch-transcodes 4K/60fps videos to 1080p@30fps
                                     #   Converts GIFs → MP4. Saves originals in original/
```

### Where Each File Lives After Install

| File | Destination |
|------|-------------|
| `scripts/live-wallpaper.sh` | `~/.config/hypr/scripts/live-wallpaper.sh` |
| `scripts/wallpaper-hook.sh` | `~/.config/hypr/scripts/wallpaper-hook.sh` |
| `scripts/wallpaper-startup.sh` | `~/.config/hypr/scripts/wallpaper-startup.sh` |
| `scripts/set-wallpaper.sh` | `~/.config/hypr/scripts/set-wallpaper.sh` |
| `transcode-wallpapers.sh` | Anywhere you like — run it manually |

---

## ✦ Prerequisites

### Required Packages

```bash
# Arch Linux / EndeavourOS (pacman + AUR)
sudo pacman -S mpv ffmpeg python libnotify
paru -S mpvpaper          # AUR

# Also required (usually already installed with Caelestia):
# hyprland, caelestia, hyprpicker, wl-clipboard, python3
```

> **NVIDIA Laptop (RTX series)?**
> Install the NVIDIA drivers with NVDEC support. The scripts use `hwdec=nvdec` for hardware-accelerated decoding on the dedicated GPU — do **not** use `hwdec=vaapi` which routes to the Intel iGPU and causes driver conflicts.

### Required: Caelestia Dotfiles

This setup is designed specifically for [Caelestia dotfiles](https://github.com/caelestia-dots/shell). It integrates with:
- `caelestia wallpaper` CLI (postHook system)
- `~/.config/caelestia/shell.json` (background layer control)
- `~/.config/caelestia/hypr-user.conf` (exec-once and keybinds)

---

## ✦ Installation

### One-Click (Recommended)

```bash
git clone https://github.com/yourusername/mpvpaper-live-wallpaper.git
cd mpvpaper-live-wallpaper
bash install.sh
```

The installer handles everything automatically — see [What the Installer Does](#what-the-installer-does) below.

---

### Manual Setup

If you prefer to set things up yourself, follow these steps exactly.

#### Step 1 — Copy Scripts

```bash
mkdir -p ~/.config/hypr/scripts

cp scripts/live-wallpaper.sh      ~/.config/hypr/scripts/
cp scripts/wallpaper-hook.sh      ~/.config/hypr/scripts/
cp scripts/wallpaper-startup.sh   ~/.config/hypr/scripts/
cp scripts/set-wallpaper.sh       ~/.config/hypr/scripts/

chmod +x ~/.config/hypr/scripts/*.sh
```

#### Step 2 — Register the Wallpaper Hook

Tell caelestia to call `wallpaper-hook.sh` after every wallpaper change.

Edit `~/.config/caelestia/cli.json`:

```json
{
    "wallpaper": {
        "postHook": "/home/YOUR_USERNAME/.config/hypr/scripts/wallpaper-hook.sh"
    }
}
```

> ⚠️ Replace `YOUR_USERNAME` with your actual username. Tilde (`~`) does **not** work in `cli.json`.

#### Step 3 — Add Startup Exec + Keybind

Edit `~/.config/caelestia/hypr-user.conf` and add:

```ini
# Restore wallpaper on login
exec-once = ~/.config/hypr/scripts/wallpaper-startup.sh

# Super+Alt+W — cycle/activate live wallpaper
bind = SUPER ALT, W, exec, ~/.config/hypr/scripts/live-wallpaper.sh
```

> **Why `hypr-user.conf`?** Caelestia sources this file into Hyprland automatically. Adding to it means your config survives Caelestia updates.

#### Step 4 — Create the Wallpaper Directory

```bash
mkdir -p ~/Pictures/Wallpapers/live-wallpaper
```

Drop your `.mp4`, `.mkv`, `.webm`, or `.gif` files here.

#### Step 5 — (Optional) Thunar Right-Click Action

To enable right-clicking any image/video in Thunar → "Set as Wallpaper":

Open **Thunar → Edit → Configure custom actions → Add** and fill in:

| Field | Value |
|-------|-------|
| **Name** | `Set as Wallpaper` |
| **Command** | `bash -c '~/.config/hypr/scripts/set-wallpaper.sh %f'` |
| **File patterns** | `*.png;*.jpg;*.jpeg;*.webp;*.mp4;*.mkv;*.webm;*.mov;*.gif` |
| **Appears if selection contains** | ✅ Image Files  ✅ Video Files |

---

## ✦ What the Installer Does

`install.sh` automates all 5 manual steps above:

```
▶ Checking dependencies      checks mpvpaper, mpv, ffmpeg, ffprobe, python3, notify-send
▶ Installing scripts          copies 4 scripts → ~/.config/hypr/scripts/ (backs up existing)
▶ Registering postHook        writes/updates ~/.config/caelestia/cli.json atomically
▶ Adding exec-once + bind     appends to ~/.config/caelestia/hypr-user.conf (idempotent)
▶ Creating wallpaper dir      mkdir -p ~/Pictures/Wallpapers/live-wallpaper/
▶ Thunar action               interactively adds right-click "Set as Wallpaper"
```

---

## ✦ Usage

### Setting a Live Wallpaper

**Method 1 — Keybind**
Press `Super + Alt + W` — cycles through all videos in `~/Pictures/Wallpapers/live-wallpaper/` and plays the next one.

**Method 2 — Direct file**
```bash
~/.config/hypr/scripts/live-wallpaper.sh /path/to/video.mp4
```

**Method 3 — Thunar**
Right-click any `.mp4`, `.mkv`, `.webm`, or `.gif` → **Set as Wallpaper**

### Switching Back to Static Wallpaper

Use caelestia's wallpaper picker as normal (`caelestia wallpaper -f image.jpg` or through the Caelestia UI). The hook automatically kills mpvpaper and restores the background.

### Optimising Your Videos (Highly Recommended)

Run the transcoder on your wallpaper folder before using a video for the first time:

```bash
cp transcode-wallpapers.sh ~/Pictures/Wallpapers/
cd ~/Pictures/Wallpapers/
bash transcode-wallpapers.sh
```

This batch-transcodes all videos down to your screen resolution (default: 1920×1080) at 30fps using NVENC (GPU encoding). GIFs are converted to MP4.

**Why bother?**
- A 4K video at 60fps on a 1080p screen decodes 4× more pixels than needed, 60× per second
- After transcoding: CPU ~90% → ~20%, temps ~87°C → ~65°C, dropped frames 200+/min → 0

Originals are automatically saved in `~/Pictures/Wallpapers/live-wallpaper/original/` with `.original` appended to their name.

---

## ✦ How It Works

```
User triggers wallpaper change
        │
        ├─ Video/GIF ──────→ live-wallpaper.sh
        │                         │
        │                    Guard: hyprpicker running? → abort
        │                         │
        │                    Kill existing mpvpaper
        │                         │
        │                    GIF? → convert to MP4 via ffmpeg (cached)
        │                         │
        │                    Update shell.json:
        │                      wallpaperEnabled = false  ← hides caelestia bg image
        │                      enabled          = true   ← keeps clock/widgets alive
        │                         │
        │                    Launch mpvpaper (nice +10, --auto-pause)
        │                         │
        │                    Extract frame → apply color scheme
        │
        └─ Static image ───→ set-wallpaper.sh
                                  │
                             Kill mpvpaper
                                  │
                             Restore shell.json (wallpaperEnabled = true)
                                  │
                             caelestia wallpaper -f <image>
                                  │
                             wallpaper-hook.sh (postHook)
                                  │
                             Restart caelestia shell (recreates surface cleanly)
```

### The Widget Fix — Explained

Caelestia's background layer has two relevant properties in `shell.json`:

| Property | Effect |
|----------|--------|
| `background.enabled` | Creates/destroys the **entire** background window (includes clock widget) |
| `background.wallpaperEnabled` | When `false`: moves window from `WlrLayer.Background` → `WlrLayer.Bottom` with transparent background. Wallpaper image hidden, but clock widget stays visible |

**The bug:** setting `enabled = false` destroyed the clock widget.
**The fix:** only set `wallpaperEnabled = false` — mpvpaper's `WlrLayer.Background` shows through, and the clock widget on `WlrLayer.Bottom` stays visible on top.

---

## ✦ Script Reference

### `live-wallpaper.sh`
Core wallpaper launcher. Accepts an optional path argument; if omitted, cycles through `~/Pictures/Wallpapers/live-wallpaper/`.

```bash
~/.config/hypr/scripts/live-wallpaper.sh [/path/to/video.mp4]
```

Key mpv options used:
| Option | Why |
|--------|-----|
| `hwdec=nvdec` | NVIDIA hardware decode (NVDEC engine, not CUDA/iGPU) |
| `--auto-pause` | Pauses when wallpaper is hidden — eliminates overheating |
| `profile=low-latency` | Disables unnecessary prefetch buffers |
| `vd-lavc-skiploopfilter=all` | Skips H.264 deblocking — major GPU savings, invisible at wallpaper distance |
| `scale=bilinear` | Fast scaling (lanczos is overkill for a wallpaper) |
| `video-sync=audio` | Cheaper than `display-resample` when muted |

### `wallpaper-hook.sh`
Registered as caelestia's `postHook`. Called automatically after `caelestia wallpaper -f <image>`. Kills mpvpaper, restores `shell.json`, and restarts the caelestia shell.

### `wallpaper-startup.sh`
Called on login via `exec-once`. Waits for the Hyprland compositor to be ready (polls `hyprctl monitors`), then restores either the live video wallpaper or the static image from saved state.

### `set-wallpaper.sh`
Universal router — accepts any supported file and dispatches to the right handler. Ideal for file manager integration.

| Input | Action |
|-------|--------|
| `.mp4` `.mkv` `.webm` `.mov` | → `live-wallpaper.sh` |
| `.gif` | → `live-wallpaper.sh` (converted to MP4 inline) |
| `.jpg` `.jpeg` `.png` `.webp` | → `caelestia wallpaper -f` (static) |

### `transcode-wallpapers.sh`
Batch video optimiser. Run from `~/Pictures/Wallpapers/` or point it at any folder. Not part of the auto-startup chain — run manually once per video.

```bash
bash transcode-wallpapers.sh [/path/to/folder]   # defaults to ~/Pictures/Wallpapers/live-wallpaper/
```

Encoding paths (tried in order):
1. **GPU: CUDA decode + NVENC encode** (fastest, NVIDIA-only)
2. **CPU decode + NVENC encode** (universal NVIDIA fallback)
3. **Pure software: libx264** (last resort, always works)

---

## ✦ Troubleshooting

**Live wallpaper doesn't start**
```bash
# Check the log
tail -50 ~/.local/state/caelestia/wallpaper/live-wallpaper.log
```

**Blank screen instead of video**
- Check that the video file exists in `~/Pictures/Wallpapers/live-wallpaper/`
- Try running `live-wallpaper.sh` manually with the full path
- If it's a GIF: GIF-to-MP4 conversion may have failed — check that ffmpeg is installed

**Desktop clock/widgets disappeared**
- This was the old bug — it should not happen with this version
- If it does: `qs -c caelestia reload` to restart the shell

**Overheating / high GPU usage**
- Run `transcode-wallpapers.sh` — playing a 4K file on a 1080p screen is the #1 cause
- Verify `--auto-pause` is working: open a fullscreen app and check if GPU usage drops

**Color scheme not changing**
- Requires `caelestia` Python package: `python3 -c "from caelestia.utils.wallpaper import get_colours_for_wall"`
- Color extraction is non-fatal — if it fails the wallpaper still plays

**hyprpicker (color picker) broken after installing**
- The script guards against running while hyprpicker is active
- The guard is a one-way check — hyprpicker is never interrupted by this setup

---

## ✦ Tested Environment

| Component | Version |
|-----------|---------|
| OS | Arch Linux |
| Compositor | Hyprland |
| Shell | Caelestia (quickshell) |
| GPU | NVIDIA RTX 4050 Laptop (proprietary drivers) |
| mpvpaper | latest (AUR) |
| mpv | latest |

---

## ✦ License

MIT — do whatever you want with it.

---

<div align="center">

*Built for the Caelestia community.*
*If something is broken, open an issue.*

</div>
