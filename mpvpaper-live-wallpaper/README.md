# 🎬 mpvpaper Live Wallpaper

Animated live wallpapers on Hyprland via **mpvpaper** — built specifically for [Caelestia](https://github.com/caelestia-dots/shell) dotfile users.

> Plays any `.mp4`, `.mkv`, `.webm`, `.gif` as your desktop wallpaper with auto-pause, NVENC hardware decoding, and full color scheme integration.

---

## ✦ Install mpvpaper

**Arch Linux (AUR):**
```bash
yay -S mpvpaper
# or
paru -S mpvpaper
```

**Dependencies (all must be present):**
```bash
sudo pacman -S mpv ffmpeg python
```

---

## ✦ One-Command Setup

```bash
git clone https://github.com/AEON-mod/Customization
cd Customization/mpvpaper-live-wallpaper
bash install.sh
```

The installer handles everything automatically. Log out and back in (or `hyprctl reload`) to activate.

---

## ✦ Manual Setup

If you prefer to wire things up yourself:

**1 — Copy scripts**
```bash
mkdir -p ~/.config/hypr/scripts
cp scripts/live-wallpaper.sh \
   scripts/wallpaper-hook.sh \
   scripts/wallpaper-startup.sh \
   scripts/set-wallpaper.sh \
   ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/*.sh
```

**2 — Register the post-hook in `~/.config/caelestia/cli.json`**
```json
{
  "wallpaper": {
    "postHook": "~/.config/hypr/scripts/wallpaper-hook.sh"
  }
}
```

**3 — Add to `~/.config/caelestia/hypr-user.conf`**
```ini
# Restore wallpaper on login
exec-once = ~/.config/hypr/scripts/wallpaper-startup.sh

# Cycle live wallpapers (Super+Alt+W)
bind = SUPER ALT, W, exec, ~/.config/hypr/scripts/live-wallpaper.sh
```

**4 — Create wallpaper directory**
```bash
mkdir -p ~/Pictures/Wallpapers/live-wallpaper
```

**5 — (Optional) Thunar right-click action**

Open Thunar → Edit → Configure Custom Actions → Add:
| Field | Value |
|-------|-------|
| Name | Set as Wallpaper |
| Command | `bash -c '~/.config/hypr/scripts/set-wallpaper.sh %f'` |
| File patterns | `*.png;*.jpg;*.jpeg;*.webp;*.mp4;*.mkv;*.webm;*.mov;*.gif` |

---

## ✦ Usage

**Keybind** — `Super + Alt + W` cycles through all videos in `~/Pictures/Wallpapers/live-wallpaper/`

**Direct file:**
```bash
~/.config/hypr/scripts/live-wallpaper.sh /path/to/video.mp4
```

**Thunar** — Right-click any `.mp4`, `.mkv`, `.webm`, `.gif`, or image → **Set as Wallpaper**

**Switch back to static** — Use Caelestia's wallpaper picker as normal. The hook auto-kills mpvpaper and restores the background.

---

## ✦ Optimise Your Videos (Recommended)

Playing 4K @ 60fps on a 1080p screen decodes 8× more data than needed. Run the transcoder first:

```bash
cp scripts/transcode-wallpapers.sh ~/Pictures/Wallpapers/live-wallpaper/
cd ~/Pictures/Wallpapers/live-wallpaper
bash transcode-wallpapers.sh
```

Downscales to **1920×1080 @ 30fps** using NVENC GPU encoding. GIFs are batch-converted to MP4. Originals are saved to `live-wallpaper/original/` automatically — delete them once you're happy.

**Encoding paths (tried in order):**
1. CUDA decode + NVENC encode *(fastest, NVIDIA only)*
2. CPU decode + NVENC encode *(universal NVIDIA fallback)*
3. libx264 software *(last resort, always works)*

---

## ✦ Scripts

| Script | Purpose |
|--------|---------|
| `live-wallpaper.sh` | Core launcher — plays video/GIF, updates shell.json, extracts color scheme |
| `wallpaper-hook.sh` | Caelestia postHook — kills mpvpaper when switching to static image |
| `wallpaper-startup.sh` | `exec-once` — restores last wallpaper on login |
| `set-wallpaper.sh` | Universal router — dispatches by file type (Thunar / CLI) |
| `transcode-wallpapers.sh` | Batch transcoder — optimises videos to 1080p @ 30fps via NVENC |

---

## ✦ Troubleshooting

**Live wallpaper doesn't start**
```bash
tail -50 ~/.local/state/caelestia/wallpaper/live-wallpaper.log
```

**Blank screen instead of video**
- Confirm your video is in `~/Pictures/Wallpapers/live-wallpaper/`
- Test manually: `~/.config/hypr/scripts/live-wallpaper.sh /path/to/video.mp4`

**Overheating / high GPU usage**
- Run `transcode-wallpapers.sh` — playing a 4K file on a 1080p screen is the #1 cause
- Verify `--auto-pause` is working: open a fullscreen app and check GPU usage drops

**Desktop clock/widgets disappeared**
- Run `qs -c caelestia reload` to restart the shell

**Color scheme not changing**
```bash
python3 -c "from caelestia.utils.wallpaper import get_colours_for_wall"
```
Color extraction is non-fatal — wallpaper still plays if it fails.

---

## ✦ Tested On

| | |
|-|-|
| OS | Arch Linux |
| Compositor | Hyprland |
| Shell | Caelestia (quickshell) |
| GPU | NVIDIA RTX 4050 Laptop |

---

<div align="center">

*Built for the Caelestia community.*  
[↗ View on GitHub](https://github.com/AEON-mod/Customization/tree/main/mpvpaper-live-wallpaper)

</div>
