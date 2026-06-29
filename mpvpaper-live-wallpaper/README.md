<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=28&pause=1000&color=CBA6F7&center=true&vCenter=true&width=600&lines=🎬+mpvpaper+Live+Wallpaper;GPU+Video+Wallpapers+on+Hyprland;~20%25+CPU+%C2%B7+Full+Caelestia+Support" alt="Typing SVG" />

<br/>

**Bring your desktop to life — GPU-decoded video wallpapers with full [Caelestia](https://github.com/caelestia-dots) integration**

<br/>

[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-89b4fa?style=for-the-badge&logo=wayland&logoColor=white)](https://hyprland.org)
[![mpvpaper](https://img.shields.io/badge/mpvpaper-1.8+-fab387?style=for-the-badge)](https://github.com/GhostNaN/mpvpaper)
[![GPU](https://img.shields.io/badge/NVDEC-Accelerated-a6e3a1?style=for-the-badge&logo=nvidia&logoColor=white)](https://developer.nvidia.com)
[![Caelestia](https://img.shields.io/badge/Caelestia-Compatible-cba6f7?style=for-the-badge)](https://github.com/caelestia-dots)

<br/>

> *From 94% CPU and 89°C crashes → to 20% CPU and 65°C silence.*  
> *That's not a tweak. That's the right way.*

</div>

---

## ✨ Why This Exists

Most mpvpaper guides online are wrong. They tell you to use `hwdec=nvdec` — which silently falls back to software decode. They tell you to use `vf=scale` — which destroys your CPU. They give you a one-liner and call it a day.

This isn't that. This is the setup that was built after diagnosing hours of 90%+ CPU usage, thermal throttling, and dropped frames — so you don't have to.

**Result:** a live wallpaper that runs so efficiently, you forget it's there. 🌙

---

## 🎯 What You Get

| | Feature | Details |
|--|---------|---------|
| 🎮 | **True GPU decoding** | `nvdec-copy` — the only mode that works with mpvpaper's EGL surface |
| 🔄 | **Wallpaper cycling** | One keybind to cycle through your entire video collection |
| 🎨 | **Live color extraction** | Caelestia reads a frame and recolors your whole shell/widgets instantly |
| 🔋 | **Auto-pause when covered** | mpvpaper sleeps when windows are in front — zero wasted cycles |
| 💾 | **Survives reboots** | Startup script restores your last video every login |
| 🎬 | **Batch transcoder** | One command downscales your entire 4K collection to screen resolution |
| 🖼 | **Clean image/video switching** | Static images and live wallpapers coexist with zero conflicts |
| 🕹 | **Wallpaper Engine support** | Works alongside `linux-wallpaperengine` scenes |

---

## 📋 Requirements

```
mpvpaper    ffmpeg    jq    python3    caelestia    hyprctl
```

```bash
# Arch / CachyOS / EndeavourOS
sudo pacman -S ffmpeg jq python
yay -S mpvpaper        # AUR
```

> `caelestia` comes with the [Caelestia dotfiles](https://github.com/caelestia-dots/caelestia).  
> Not using Caelestia? → See [Usage Without Caelestia](#-using-without-caelestia)

---

## 📁 Files

```
mpvpaper-live-wallpaper/
│
├── 🚀 live-wallpaper.sh         Main script — launch & cycle video wallpapers
├── 🔗 wallpaper-hook.sh         Caelestia post-hook — routes image/video/scene wallpapers
├── ⚡ wallpaper-startup.sh      Startup — restores last wallpaper on every boot
├── 🔧 transcode-wallpapers.sh   Batch downscale 4K/1440p → your screen res (NVENC)
├── 🎮 game-mode.sh              (optional) Power profile switcher for NVIDIA laptops
└── 📄 cpu-power-limits.service  (optional) Systemd TDP persistence
```

**Where they live on your system:**
```
~/.config/hypr/scripts/live-wallpaper.sh
~/.config/hypr/scripts/wallpaper-hook.sh
~/.config/hypr/scripts/wallpaper-startup.sh
~/Pictures/Wallpapers/live-wallpaper/      ← your videos go here
```

---

## 🚀 Setup Guide

> Follow every step. Each one matters.

---

### ① Install dependencies

```bash
sudo pacman -S ffmpeg jq python
yay -S mpvpaper
```

Quick check:
```bash
mpvpaper --help 2>&1 | grep -i version
ffmpeg -version | head -1
jq --version
```

---

### ② Clone this repo

```bash
git clone https://github.com/AEON-mod/Customization.git
cd Customization/mpvpaper-live-wallpaper
```

---

### ③ Copy the scripts

```bash
mkdir -p ~/.config/hypr/scripts

cp live-wallpaper.sh    ~/.config/hypr/scripts/
cp wallpaper-hook.sh    ~/.config/hypr/scripts/
cp wallpaper-startup.sh ~/.config/hypr/scripts/

chmod +x ~/.config/hypr/scripts/live-wallpaper.sh
chmod +x ~/.config/hypr/scripts/wallpaper-hook.sh
chmod +x ~/.config/hypr/scripts/wallpaper-startup.sh
```

> **Caelestia note:** These are drop-in replacements for Caelestia's default hook scripts.  
> They keep all original image + Wallpaper Engine behavior and add video routing on top.  
> Only copy `live-wallpaper.sh` + `wallpaper-hook.sh` + `wallpaper-startup.sh`.

---

### ④ Register the post-hook

Tell Caelestia to call your hook after every wallpaper change.  
Edit (or create) `~/.config/caelestia/cli.json`:

```bash
# One-liner — auto-fills your username:
echo "{\"wallpaper\":{\"postHook\":\"$HOME/.config/hypr/scripts/wallpaper-hook.sh\"}}" \
  | jq . > ~/.config/caelestia/cli.json
```

Or manually set it to:
```json
{
    "wallpaper": {
        "postHook": "/home/YOUR_USERNAME/.config/hypr/scripts/wallpaper-hook.sh"
    }
}
```

Verify:
```bash
cat ~/.config/caelestia/cli.json
```

---

### ⑤ Add to Hyprland user config

`~/.config/caelestia/hypr-user.conf` is the safe override file — Caelestia updates never touch it.

```bash
nano ~/.config/caelestia/hypr-user.conf
```

Add:
```conf
# Restore last live wallpaper on every startup
exec-once = ~/.config/hypr/scripts/wallpaper-startup.sh

# Super + Alt + W → cycle to next video wallpaper
bind = SUPER ALT, W, exec, ~/.config/hypr/scripts/live-wallpaper.sh
```

> Change `SUPER ALT, W` to any keybind you prefer.

---

### ⑥ Add your videos

```bash
mkdir -p ~/Pictures/Wallpapers/live-wallpaper

# Drop any .mp4 / .webm / .mkv files here
# Example:
cp ~/Downloads/my-wallpaper.mp4 ~/Pictures/Wallpapers/live-wallpaper/
```

---

### ⑦ Transcode high-res videos *(highly recommended)*

If you have 4K or 1440p videos, run this **before** using them as wallpapers:

```bash
bash transcode-wallpapers.sh
```

**What it does automatically:**
- Detects your screen resolution via `hyprctl monitors`
- Skips videos already at or below your resolution
- Tries **GPU pipeline** (CUDA + NVENC) → falls back to **CPU + NVENC** → falls back to **CPU-only**
- Saves originals as `.orig.mp4` — nothing is deleted
- Re-run anytime you add new wallpapers

Manual override:
```bash
bash transcode-wallpapers.sh 1920 1080    # force 1080p target
bash transcode-wallpapers.sh 2560 1440    # force 1440p target
```

---

### ⑧ Reload and enjoy 🎉

```bash
hyprctl reload
```

Press **`Super + Alt + W`** — your first live wallpaper starts playing.  
Press it again to cycle to the next one.

---

## 🎮 Daily Commands

```bash
# Cycle to next video wallpaper
bash ~/.config/hypr/scripts/live-wallpaper.sh

# Play a specific video
bash ~/.config/hypr/scripts/live-wallpaper.sh ~/Pictures/Wallpapers/live-wallpaper/city.mp4

# Stop the live wallpaper
killall mpvpaper

# Switch back to a static image (Caelestia handles everything automatically)
caelestia wallpaper -f ~/Pictures/Wallpapers/some-image.jpg

# Add new videos + transcode them
cp newvideo.mp4 ~/Pictures/Wallpapers/live-wallpaper/
bash ~/Customization/mpvpaper-live-wallpaper/transcode-wallpapers.sh
```

---

## 🔗 How It All Fits Together

```
┌─────────────────────────────────────────────────────────────┐
│                  Super + Alt + W pressed                    │
└────────────────────────────┬────────────────────────────────┘
                             ▼
                    live-wallpaper.sh
                    ├── Kill existing mpvpaper / wallpaperengine
                    ├── shell.json → wallpaperEnabled: false
                    ├── Write is_live_wallpaper_active flag
                    ├── Launch mpvpaper (nvdec-copy)
                    ├── Extract frame → ~/.cache/caelestia-live-frame.jpg
                    └── LIVE_WALLPAPER_COLORS_ONLY=1 caelestia wallpaper -f <frame>
                                        │
                                        ▼
                            wallpaper-hook.sh
                            └── Sees env var → exits immediately ✅
                                (color scheme updates, video keeps playing)

┌─────────────────────────────────────────────────────────────┐
│            Switch back to static image (Caelestia UI)       │
└────────────────────────────┬────────────────────────────────┘
                             ▼
                    wallpaper-hook.sh
                    ├── Kill mpvpaper ✅
                    ├── Remove is_live_wallpaper_active flag
                    └── shell.json → wallpaperEnabled: true

┌─────────────────────────────────────────────────────────────┐
│                    Hyprland starts up                       │
└────────────────────────────┬────────────────────────────────┘
                             ▼
                    wallpaper-startup.sh
                    ├── is_live_wallpaper_active exists?
                    │     YES → resume last video from current_live_wallpaper.txt
                    └─    NO  → re-apply last static image via wallpaper-hook.sh
```

---

## ⚡ Performance — The Real Story

### 🔴 The wrong way (what most guides say)

```bash
mpvpaper -o "hwdec=nvdec vf=scale=1920:1080" '*' video.mp4
# Result: 90%+ CPU, 89°C, fans screaming, frames dropping
```

**Two mistakes:**
1. `vf=scale` = CPU filter on every frame at full framerate
2. `nvdec` = silently falls back to software on mpvpaper's EGL surface

---

### 🟢 The right way (what this setup uses)

```bash
mpvpaper -s -o "loop=yes hwdec=nvdec-copy hwdec-codecs=all mute=yes panscan=1.0" '*' video.mp4
# Result: ~20% CPU, ~65°C, silent fans, zero dropped frames
```

**Why `nvdec-copy` and not `nvdec`?**  
mpvpaper uses a libmpv **EGL surface** — not a native dmabuf surface. Pure `nvdec` needs zero-copy GPU→compositor handoff via dmabuf, which EGL can't provide. mpv silently falls back to CPU with no warning. `nvdec-copy` decodes on GPU, copies to RAM for EGL upload — not perfectly zero-copy, but orders of magnitude better than software.

---

### 📊 Benchmark

> *Intel i7-12650HX · RTX 4050 Laptop · 1920×1080 · Hyprland · CachyOS*

| Setup | CPU | Temp | Dropped Frames |
|-------|-----|------|----------------|
| 4K60 + `vf=scale` + `nvdec` | **~94%** | **89°C** | 200+/min 🔴 |
| 4K60 + no `vf=scale` + `nvdec-copy` | ~45% | ~80°C | ~50/min 🟡 |
| **1080p30 + `nvdec-copy`** *(this setup)* | **~20%** | **~65°C** | **0** 🟢 |

---

## 🖥 Using Without Caelestia

Running vanilla Hyprland? No problem. Edit `live-wallpaper.sh` and remove these blocks:

```bash
# Remove (Caelestia-specific):
FLAG_FILE=...
SHELL_CONF=...
touch "$FLAG_FILE"
jq '.background.wallpaperEnabled = false' ...
FRAME_CACHE=...
ffmpeg ... "$FRAME_CACHE"
LIVE_WALLPAPER_COLORS_ONLY=1 caelestia wallpaper -f "$FRAME_CACHE"
```

Then add to `hyprland.conf`:
```conf
exec-once = bash ~/.config/hypr/scripts/live-wallpaper.sh
bind = SUPER ALT, W, exec, bash ~/.config/hypr/scripts/live-wallpaper.sh
```

Everything else (video cycling, transcode script, mpvpaper flags) works identically.

---

## ❓ FAQ

<details>
<summary><b>Does this work on AMD GPUs?</b></summary>

Replace `hwdec=nvdec-copy` with `hwdec=vaapi-copy`.  
In `transcode-wallpapers.sh`, change `h264_nvenc` → `h264_vaapi` and remove the CUDA hwaccel flags.

</details>

<details>
<summary><b>Does this work without a GPU?</b></summary>

Yes — use `hwdec=auto`. The transcode script's Path C (CPU fallback) handles encoding without GPU.

</details>

<details>
<summary><b>Color scheme doesn't update when I set a live wallpaper</b></summary>

Run the script from a terminal and look for ffmpeg errors. Usually caused by firejail wrapping ffmpeg.  
Check: `ls -la $(which ffmpeg)` — if it points to `/usr/bin/firejail`, see Problem 4 in the Performance section.  
Verify the frame cache exists: `ls ~/.cache/caelestia-live-frame.jpg`

</details>

<details>
<summary><b>Wallpaper doesn't restore after reboot</b></summary>

1. Check `~/.config/caelestia/hypr-user.conf` has `exec-once = ~/.config/hypr/scripts/wallpaper-startup.sh`
2. Check `~/.local/state/caelestia/wallpaper/is_live_wallpaper_active` exists  
3. Run `hyprctl reload` and try pressing your keybind again

</details>

<details>
<summary><b>Switching to a static image doesn't stop the video</b></summary>

Check `~/.config/caelestia/cli.json` has the correct `postHook` path.  
Test: `caelestia wallpaper -f ~/some-image.jpg` — mpvpaper should stop within a second.

</details>

<details>
<summary><b>Multiple monitors?</b></summary>

mpvpaper's `'*'` argument targets all monitors automatically. Same video on all screens.

</details>

---

## 🗂 State Files

| File | Purpose |
|------|---------|
| `~/.local/state/caelestia/wallpaper/current_live_wallpaper.txt` | Path of current video |
| `~/.local/state/caelestia/wallpaper/is_live_wallpaper_active` | Live wallpaper active flag |
| `~/.local/state/caelestia/wallpaper/path.txt` | Last static wallpaper path |
| `~/.cache/caelestia-live-frame.jpg` | Extracted frame for color scheme |
| `~/.config/caelestia/shell.json` | `background.wallpaperEnabled` toggled here |

---

<div align="center">

---

*Part of the [AEON-mod Customization Suite](https://github.com/AEON-mod/Customization)*

**Made for [Caelestia](https://github.com/caelestia-dots) · Runs on [Hyprland](https://hyprland.org) · Powered by [mpvpaper](https://github.com/GhostNaN/mpvpaper)**

*If this saved you hours of debugging — drop a ⭐ on the repo!*

</div>
