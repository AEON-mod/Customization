#!/bin/bash
# live-wallpaper.sh — Sets a video/GIF as wallpaper using mpvpaper.
#
# FIXES vs previous version:
#   - hwdec=nvdec        : Uses NVIDIA native decoder (NOT vaapi-copy which is Intel iGPU)
#                          vaapi-copy was causing GPU driver conflicts and crashes on RTX 4050
#   - --auto-pause (-p)  : mpvpaper pauses decoding when wallpaper is hidden (fullscreen app)
#                          Eliminates the overheating-under-load issue entirely
#   - profile=low-latency: Reduces mpv internal buffer latency for wallpaper use
#                          NOTE: mpvpaper ignores vo= and gpu-api= options (always uses libmpv VO)
#   - GIF → MP4 first    : GIFs fed to mpv produce static/corrupt frames; we convert them
#                          to MP4 before playing — fixes the "static gif" bug
#   - Color lock guard   : Prevents color extraction from running while hyprpicker is active
#   - Atomic shell.json  : Writes config to tmp then renames — avoids corrupt JSON on crash
#   - Nice +10           : mpvpaper runs at lower CPU priority, won't compete with foreground
#   - No shell restart   : We no longer restart caelestia shell (was causing memory dumps
#                          from the shell being force-killed mid-render)
#   - wallpaperEnabled=false only (NOT background.enabled=false):
#                          background.enabled=false destroys the entire caelestia background
#                          window — killing the desktop clock widget too.
#                          wallpaperEnabled=false moves it to WlrLayer.Bottom (transparent)
#                          so mpvpaper's WlrLayer.Background shows through AND the clock
#                          widget stays visible on top.

DIR="$HOME/Pictures/Wallpapers/live-wallpaper"
GIF_CACHE_DIR="$HOME/.cache/live-wallpaper-gifs"
mkdir -p "$DIR" "$GIF_CACHE_DIR"

STATE_FILE="$HOME/.local/state/caelestia/wallpaper/current_live_wallpaper.txt"
FLAG_FILE="$HOME/.local/state/caelestia/wallpaper/is_live_wallpaper_active"
SHELL_CONF="$HOME/.config/caelestia/shell.json"
LOG="$HOME/.local/state/caelestia/wallpaper/live-wallpaper.log"

mkdir -p "$(dirname "$STATE_FILE")"
# Rotate log if it exceeds 500KB (prevents unbounded growth)
if [ -f "$LOG" ] && [ $(stat -c%s "$LOG" 2>/dev/null || echo 0) -gt 512000 ]; then
    tail -c 102400 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi
exec > >(tee -a "$LOG") 2>&1
echo "[$(date '+%H:%M:%S')] live-wallpaper.sh started, arg: ${1:-<none>}"

# ── Guard: Don't run if hyprpicker/color picker is active ────────────────────
# Running while colorpicker is active corrupts its output (re-renders the shell)
if pgrep -x hyprpicker > /dev/null 2>&1; then
    echo "[$(date '+%H:%M:%S')] hyprpicker is active — aborting to avoid color picker interference"
    notify-send "Live Wallpaper" "⚠ Cannot set wallpaper while color picker is active" \
        --icon=dialog-warning 2>/dev/null
    exit 1
fi

# ── Kill existing video wallpaper processes ───────────────────────────────────
killall mpvpaper 2>/dev/null
pkill -f linux-wallpaperengine 2>/dev/null
# Brief wait for Wayland surface to be released before we claim background layer
sleep 0.4

# ── Determine which video/GIF to play ────────────────────────────────────────
if [ -z "$1" ]; then
    mapfile -t VIDEOS < <(find "$DIR" -maxdepth 1 -type f \( \
        -iname '*.mp4' -o -iname '*.webm' -o \
        -iname '*.mkv' -o -iname '*.gif'  \) | sort)

    if [ ${#VIDEOS[@]} -eq 0 ]; then
        notify-send "Live Wallpaper" "No videos/GIFs found in $DIR" 2>/dev/null
        exit 1
    fi

    CURRENT=""
    [ -f "$STATE_FILE" ] && CURRENT=$(cat "$STATE_FILE")

    NEXT_INDEX=0
    for i in "${!VIDEOS[@]}"; do
        if [[ "${VIDEOS[$i]}" == "$CURRENT" ]]; then
            NEXT_INDEX=$(( (i + 1) % ${#VIDEOS[@]} ))
            break
        fi
    done
    VIDEO="${VIDEOS[$NEXT_INDEX]}"
else
    VIDEO="$1"
fi

[ ! -f "$VIDEO" ] && {
    notify-send "Live Wallpaper" "File not found: $VIDEO" 2>/dev/null
    exit 1
}

# ── Handle GIFs — convert to MP4 cache first ─────────────────────────────────
# mpvpaper/mpv cannot loop GIFs correctly; they show as static or corrupt.
# We convert GIF → MP4 (lossless palette-accurate) on first use and cache it.
VIDEO_EXT="${VIDEO##*.}"
VIDEO_EXT="${VIDEO_EXT,,}"
PLAY_FILE="$VIDEO"

if [[ "$VIDEO_EXT" == "gif" ]]; then
    GIF_HASH=$(md5sum "$VIDEO" | cut -d' ' -f1)
    GIF_MP4="$GIF_CACHE_DIR/${GIF_HASH}.mp4"

    if [ ! -f "$GIF_MP4" ]; then
        echo "[$(date '+%H:%M:%S')] Converting GIF to MP4 cache: $(basename "$VIDEO")"
        notify-send "Live Wallpaper" "⏳ Converting GIF to MP4..." --icon=video-x-generic 2>/dev/null

        # Two-pass: palette → encode, preserves all GIF colors perfectly
        PALETTE_TMP="$GIF_CACHE_DIR/${GIF_HASH}_palette.png"
        /usr/bin/ffmpeg -y -i "$VIDEO" \
            -vf "palettegen=max_colors=256:stats_mode=diff" \
            "$PALETTE_TMP" 2>/dev/null

        if [ -f "$PALETTE_TMP" ]; then
            /usr/bin/ffmpeg -y -i "$VIDEO" -i "$PALETTE_TMP" \
                -lavfi "paletteuse=dither=bayer:bayer_scale=5" \
                -c:v libx264 -preset fast -crf 16 \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
                -movflags +faststart -an \
                "$GIF_MP4" 2>/dev/null
            rm -f "$PALETTE_TMP"
        else
            # Fallback: direct conversion
            /usr/bin/ffmpeg -y -i "$VIDEO" \
                -c:v libx264 -preset fast -crf 16 \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
                -movflags +faststart -an \
                "$GIF_MP4" 2>/dev/null
        fi

        if [ ! -f "$GIF_MP4" ] || [ ! -s "$GIF_MP4" ]; then
            echo "[$(date '+%H:%M:%S')] GIF conversion failed — playing original (may be static)"
            GIF_MP4="$VIDEO"
        fi
    else
        echo "[$(date '+%H:%M:%S')] Using cached MP4 for GIF: $(basename "$VIDEO")"
    fi

    PLAY_FILE="$GIF_MP4"
fi

# ── Save state ────────────────────────────────────────────────────────────────
echo "$VIDEO" > "$STATE_FILE"    # Save original path (not the converted cache path)
touch "$FLAG_FILE"

# ── Disable caelestia wallpaper layer (atomic write, no corrupt JSON) ────────
# We set wallpaperEnabled=False ONLY — this moves the caelestia background
# window from WlrLayer.Background → WlrLayer.Bottom with a transparent bg,
# so mpvpaper's WlrLayer.Background layer shows through underneath.
# The desktop clock widget and visualiser remain alive on WlrLayer.Bottom.
# (Setting background.enabled=False would destroy the entire window and
#  kill the clock widget — that was the bug causing widgets to disappear.)
python3 - <<'EOF'
import json, os, tempfile
path = os.path.expanduser('~/.config/caelestia/shell.json')
try:
    with open(path) as f:
        d = json.load(f)
    # Only disable the wallpaper image, keep the background window alive
    d.setdefault('background', {})['wallpaperEnabled'] = False
    # Explicitly ensure background.enabled stays True
    d['background']['enabled'] = True
    # Write atomically
    dir_ = os.path.dirname(path)
    with tempfile.NamedTemporaryFile('w', dir=dir_, delete=False, suffix='.tmp') as tmp:
        json.dump(d, tmp, indent=2)
        tmp_path = tmp.name
    os.replace(tmp_path, path)
except Exception as e:
    print(f"shell.json update failed: {e}", file=__import__('sys').stderr)
EOF

# ── Get monitor name ──────────────────────────────────────────────────────────
MONITOR=$(hyprctl monitors -j 2>/dev/null | python3 -c "
import sys, json
try:
    monitors = json.load(sys.stdin)
    print(monitors[0]['name'] if monitors else 'eDP-1')
except:
    print('eDP-1')
" 2>/dev/null)
MONITOR="${MONITOR:-eDP-1}"
echo "[$(date '+%H:%M:%S')] Monitor: $MONITOR | File: $(basename "$PLAY_FILE")"

# ── Launch mpvpaper ───────────────────────────────────────────────────────────
# Key decisions:
#   hwdec=nvdec      — NVIDIA native decoder. Uses the dedicated video decode engine
#                      on RTX 4050 (NVDEC). Does NOT involve CUDA cores or iGPU.
#   NOTE: vo= and gpu-api= options are IGNORED by mpvpaper — it always uses
#         the libmpv embedded renderer (Wayland layer surface), not a standalone VO.
#         Passing vo=gpu-next produces: "[!] mpvpaper does not support any other vo"
#         warning. So we simply omit those options entirely.
#   profile=low-latency — Disables mpv's lookahead/prefetch buffers (not needed for wallpaper)
#   loop=inf         — Infinite loop
#   mute=yes         — Wallpaper should never make sound
#   panscan=1.0      — Fill screen without black bars (pan-and-scan)
#   video-sync=audio — Audio-sync is cheaper than display-resample for wallpaper
#                      (display-resample resamples audio & recalculates timing every frame
#                       — unnecessary work when muted)
#   vd-lavc-threads=2 — Limit decoder threads (wallpaper doesn't need max threads)
#   vd-lavc-skiploopfilter=all — Skip H.264 deblocking filter (major GPU savings,
#                                barely visible at wallpaper viewing distance)
#   scale=bilinear   — Use bilinear scaling instead of the default high-quality lanczos
#                      (lanczos is great for media playback, overkill for wallpaper)
#
# --auto-pause (-p): CRITICAL — pauses mpvpaper decode when wallpaper is hidden
#   (e.g. fullscreen game/app). This is what was causing overheating before.

nice -n 10 mpvpaper \
    --auto-pause \
    -o "loop=inf \
        hwdec=nvdec \
        profile=low-latency \
        mute=yes \
        panscan=1.0 \
        video-sync=audio \
        vd-lavc-threads=2 \
        vd-lavc-skiploopfilter=all \
        scale=bilinear \
        cache=no \
        demuxer-max-bytes=16MiB \
        demuxer-readahead-secs=1" \
    "$MONITOR" "$PLAY_FILE" >/dev/null 2>&1 &
# NOTE: >/dev/null 2>&1 is CRITICAL — without it mpvpaper inherits the script's
# exec redirect and floods the log with "V: 00:00:xx" progress lines (14k+ lines/run).

MPVPAPER_PID=$!
disown $MPVPAPER_PID

# Brief wait to confirm mpvpaper actually started
sleep 0.8
if ! kill -0 $MPVPAPER_PID 2>/dev/null && ! pgrep -x mpvpaper > /dev/null; then
    echo "[$(date '+%H:%M:%S')] mpvpaper failed to start — trying fallback (software decode)"
    # Fallback: software decode, no GPU acceleration (always works)
    nice -n 10 mpvpaper \
        --auto-pause \
        -o "loop=inf \
            hwdec=no \
            vo=gpu \
            mute=yes \
            panscan=1.0 \
            cache=no" \
        "$MONITOR" "$PLAY_FILE" >/dev/null 2>&1 &
    disown
fi

notify-send "Live Wallpaper" "▶ $(basename "$VIDEO")" --icon=video-x-generic 2>/dev/null
echo "[$(date '+%H:%M:%S')] mpvpaper launched (PID tracking: $MPVPAPER_PID)"

# ── Extract frame for color scheme ───────────────────────────────────────────
# Wait until mpvpaper is confirmed running before extracting (avoids race)
sleep 1.5

# Guard again — don't mess with colors if a picker just became active
if pgrep -x hyprpicker > /dev/null 2>&1; then
    echo "[$(date '+%H:%M:%S')] Skipping color extraction — hyprpicker is now active"
    exit 0
fi

FRAME_CACHE="$HOME/.cache/caelestia-live-frame.jpg"

if [[ "$VIDEO_EXT" == "gif" ]]; then
    # Extract from the converted MP4, not the GIF
    /usr/bin/ffmpeg -y -i "$PLAY_FILE" -vframes 1 -q:v 3 \
        -vf "select=eq(n\\,5),scale=512:288" "$FRAME_CACHE" 2>/dev/null \
    || /usr/bin/ffmpeg -y -i "$PLAY_FILE" -vframes 1 -q:v 3 \
        -vf "scale=512:288" "$FRAME_CACHE" 2>/dev/null
else
    /usr/bin/ffmpeg -y -ss 5 -i "$PLAY_FILE" -vframes 1 -q:v 3 \
        -vf "scale=512:288" "$FRAME_CACHE" 2>/dev/null \
    || /usr/bin/ffmpeg -y -i "$PLAY_FILE" -vframes 1 -q:v 3 \
        -vf "scale=512:288" "$FRAME_CACHE" 2>/dev/null
fi

# Apply color scheme from extracted frame (does NOT write to path.txt)
if [ -f "$FRAME_CACHE" ]; then
    python3 - "$FRAME_CACHE" <<'EOF'
import sys
from pathlib import Path
try:
    from caelestia.utils.wallpaper import get_colours_for_wall
    from caelestia.utils.theme import apply_colours
    frame = Path(sys.argv[1])
    data = get_colours_for_wall(frame, no_smart=False)
    apply_colours(data["colours"], data["mode"])
    print(f"Color scheme applied from: {frame.name}")
except Exception as e:
    print(f"Color extraction failed (non-fatal): {e}", file=__import__('sys').stderr)
EOF
fi

echo "[$(date '+%H:%M:%S')] live-wallpaper.sh done"
