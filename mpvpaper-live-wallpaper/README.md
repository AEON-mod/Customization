<div align="center">

<br>

<img src="https://img.shields.io/badge/%E2%96%B6-LIVE_WALLPAPER-8B5CF6?style=for-the-badge&labelColor=1a1b27" alt="Live Wallpaper" />

# ✦ mpvpaper Live Wallpaper

**Animated desktop wallpapers on Hyprland — crafted for [Caelestia](https://github.com/caelestia-dots/shell)**

<br>

<img src="https://img.shields.io/badge/hyprland-compositor-88C0D0?style=flat-square&labelColor=2E3440" />
<img src="https://img.shields.io/badge/mpvpaper-backend-A3BE8C?style=flat-square&labelColor=2E3440" />
<img src="https://img.shields.io/badge/NVENC-hardware_accel-BF616A?style=flat-square&labelColor=2E3440" />
<img src="https://img.shields.io/badge/arch-linux-1793D1?style=flat-square&logo=archlinux&logoColor=white&labelColor=2E3440" />

<br><br>

Play any **`.mp4`** · **`.mkv`** · **`.webm`** · **`.gif`** as your desktop wallpaper  
with auto-pause, NVENC hardware decoding, and full color scheme integration.

<br>

---

</div>

<br>

## 🚀 Quick Start

```bash
git clone https://github.com/AEON-mod/Customization
cd Customization/mpvpaper-live-wallpaper
bash install.sh
```

> [!TIP]
> The installer handles everything automatically.  
> Log out and back in — or run `hyprctl reload` — to activate.

<br>

## 📦 Prerequisites

<table>
<tr>
<td width="50%">

**Install mpvpaper** — Arch Linux (AUR)

```bash
yay -S mpvpaper
```

</td>
<td width="50%">

**Required dependencies**

```bash
sudo pacman -S mpv ffmpeg python
```

</td>
</tr>
</table>

<br>

## 🎮 Usage

<table>
<tr><td>

### Keybind

<kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd> — cycles through all videos in `~/Pictures/Wallpapers/live-wallpaper/`

### Direct Launch

```bash
~/.config/hypr/scripts/live-wallpaper.sh /path/to/video.mp4
```

### Thunar Integration

Right-click any `.mp4` `.mkv` `.webm` `.gif` or image → **Set as Wallpaper**

### Switch Back to Static

Use Caelestia's wallpaper picker as normal — the hook auto-kills mpvpaper and restores your background.

</td></tr>
</table>

<br>

## ⚡ Optimise Your Videos

> [!IMPORTANT]
> Playing 4K @ 60fps on a 1080p screen decodes **8× more data** than needed.  
> Run the transcoder first for a smooth experience.

```bash
cp scripts/transcode-wallpapers.sh ~/Pictures/Wallpapers/live-wallpaper/
cd ~/Pictures/Wallpapers/live-wallpaper
bash transcode-wallpapers.sh
```

Downscales to **1920×1080 @ 30fps** via GPU. GIFs are batch-converted to MP4.  
Originals are saved to `live-wallpaper/original/` — delete them when satisfied.

<details>
<summary><b>🔧 Encoding pipeline (click to expand)</b></summary>
<br>

| Priority | Method | Notes |
|:--------:|--------|-------|
| 1st | CUDA decode → NVENC encode | Fastest · NVIDIA only |
| 2nd | CPU decode → NVENC encode | Universal NVIDIA fallback |
| 3rd | libx264 software encode | Last resort · always works |

</details>

<br>

## 🔩 Manual Setup

<details>
<summary><b>Expand for step-by-step manual configuration</b></summary>

<br>

**① Copy scripts**

```bash
mkdir -p ~/.config/hypr/scripts
cp scripts/{live-wallpaper,wallpaper-hook,wallpaper-startup,set-wallpaper}.sh \
   ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/*.sh
```

**② Register the post-hook** — `~/.config/caelestia/cli.json`

```json
{
  "wallpaper": {
    "postHook": "~/.config/hypr/scripts/wallpaper-hook.sh"
  }
}
```

**③ Add to Hyprland config** — `~/.config/caelestia/hypr-user.conf`

```ini
# Restore wallpaper on login
exec-once = ~/.config/hypr/scripts/wallpaper-startup.sh

# Cycle live wallpapers (Super+Alt+W)
bind = SUPER ALT, W, exec, ~/.config/hypr/scripts/live-wallpaper.sh
```

**④ Create wallpaper directory**

```bash
mkdir -p ~/Pictures/Wallpapers/live-wallpaper
```

**⑤ Thunar right-click action** *(optional)*

Open Thunar → *Edit* → *Configure Custom Actions* → *Add*:

| Field | Value |
|-------|-------|
| **Name** | `Set as Wallpaper` |
| **Command** | `bash -c '~/.config/hypr/scripts/set-wallpaper.sh %f'` |
| **File patterns** | `*.png;*.jpg;*.jpeg;*.webp;*.mp4;*.mkv;*.webm;*.mov;*.gif` |

</details>

<br>

## 📜 Script Reference

| Script | Purpose |
|:-------|:--------|
| `live-wallpaper.sh` | Core launcher — plays video/GIF, updates `shell.json`, extracts color scheme |
| `wallpaper-hook.sh` | Caelestia postHook — kills mpvpaper when switching to a static image |
| `wallpaper-startup.sh` | `exec-once` — restores last wallpaper on login |
| `set-wallpaper.sh` | Universal router — dispatches by file type (Thunar / CLI) |
| `transcode-wallpapers.sh` | Batch transcoder — optimises videos to 1080p @ 30fps via NVENC |

<br>

## 🛠 Troubleshooting

<details>
<summary><b>Live wallpaper doesn't start</b></summary>

```bash
tail -50 ~/.local/state/caelestia/wallpaper/live-wallpaper.log
```
</details>

<details>
<summary><b>Blank screen instead of video</b></summary>

- Confirm your video is in `~/Pictures/Wallpapers/live-wallpaper/`
- Test manually:
  ```bash
  ~/.config/hypr/scripts/live-wallpaper.sh /path/to/video.mp4
  ```
</details>

<details>
<summary><b>Overheating / high GPU usage</b></summary>

- Run `transcode-wallpapers.sh` — playing a 4K file on a 1080p screen is the #1 cause
- Verify `--auto-pause` is working: open a fullscreen app and check that GPU usage drops
</details>

<details>
<summary><b>Desktop clock / widgets disappeared</b></summary>

```bash
qs -c caelestia reload
```
</details>

<details>
<summary><b>Color scheme not changing</b></summary>

```bash
python3 -c "from caelestia.utils.wallpaper import get_colours_for_wall"
```

> [!NOTE]
> Color extraction is non-fatal — the wallpaper still plays if it fails.

</details>

<br>

## 🖥 Tested On

<div align="center">

| | |
|---:|:---|
| **OS** | Arch Linux |
| **Compositor** | Hyprland |
| **Shell** | Caelestia (quickshell) |
| **GPU** | NVIDIA RTX 4050 Laptop |

</div>

<br>

---

<div align="center">

<sub>Built with 🤍 for the Caelestia community</sub>

<br>

[![GitHub](https://img.shields.io/badge/view_on-github-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/AEON-mod/Customization/tree/main/mpvpaper-live-wallpaper)

</div>
