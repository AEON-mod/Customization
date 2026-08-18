#!/bin/bash
# live-wallpaper.sh — Sets a video/GIF as wallpaper using mpvpaper (Caelestia/Hyprland)

DIR="$HOME/Pictures/Wallpapers/live-wallpaper"
GIF_CACHE_DIR="$HOME/.cache/live-wallpaper-gifs"
mkdir -p "$DIR" "$GIF_CACHE_DIR"

STATE_FILE="$HOME/.local/state/caelestia/wallpaper/current_live_wallpaper.txt"
FLAG_FILE="$HOME/.local/state/caelestia/wallpaper/is_live_wallpaper_active"
SHELL_CONF="$HOME/.config/caelestia/shell.json"
LOG="$HOME/.local/state/caelestia/wallpaper/live-wallpaper.log"

mkdir -p "$(dirname "$STATE_FILE")"

# Rotate log if over 500KB
if [ -f "$LOG" ] && [ $(stat -c%s "$LOG" 2>/dev/null || echo 0) -gt 512000 ]; then
    tail -c 102400 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi
exec > >(tee -a "$LOG") 2>&1
echo "[$(date '+%H:%M:%S')] live-wallpaper.sh started, arg: ${1:-<none>}"

# Guard: abort if hyprpicker is active (would corrupt color picker output)
if pgrep -x hyprpicker > /dev/null 2>&1; then
    echo "[$(date '+%H:%M:%S')] hyprpicker is active — aborting"
    notify-send "Live Wallpaper" "⚠ Cannot set wallpaper while color picker is active" \
        --icon=dialog-warning 2>/dev/null
    exit 1
fi

# Kill existing wallpaper processes
killall mpvpaper 2>/dev/null
pkill -f linux-wallpaperengine 2>/dev/null
sleep 0.4

# Determine which video/GIF to play
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

# GIF → MP4 conversion (mpvpaper cannot loop GIFs correctly)
VIDEO_EXT="${VIDEO##*.}"
VIDEO_EXT="${VIDEO_EXT,,}"
PLAY_FILE="$VIDEO"

if [[ "$VIDEO_EXT" == "gif" ]]; then
    GIF_HASH=$(md5sum "$VIDEO" | cut -d' ' -f1)
    GIF_MP4="$GIF_CACHE_DIR/${GIF_HASH}.mp4"

    if [ ! -f "$GIF_MP4" ]; then
        echo "[$(date '+%H:%M:%S')] Converting GIF → MP4: $(basename "$VIDEO")"
        notify-send "Live Wallpaper" "⏳ Converting GIF to MP4..." --icon=video-x-generic 2>/dev/null

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
            /usr/bin/ffmpeg -y -i "$VIDEO" \
                -c:v libx264 -preset fast -crf 16 \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
                -movflags +faststart -an \
                "$GIF_MP4" 2>/dev/null
        fi

        if [ ! -f "$GIF_MP4" ] || [ ! -s "$GIF_MP4" ]; then
            echo "[$(date '+%H:%M:%S')] GIF conversion failed — playing original"
            GIF_MP4="$VIDEO"
        fi
    else
        echo "[$(date '+%H:%M:%S')] Using cached MP4 for GIF: $(basename "$VIDEO")"
    fi

    PLAY_FILE="$GIF_MP4"
fi

# Save state
echo "$VIDEO" > "$STATE_FILE"
touch "$FLAG_FILE"

# Set wallpaperEnabled=false — hides caelestia bg image but keeps clock/widgets alive
# (background.enabled=false would destroy the entire window including the clock widget)
python3 - <<'EOF'
import json, os, tempfile
path = os.path.expanduser('~/.config/caelestia/shell.json')
try:
    with open(path) as f:
        d = json.load(f)
    d.setdefault('background', {})['wallpaperEnabled'] = False
    d['background']['enabled'] = True
    dir_ = os.path.dirname(path)
    with tempfile.NamedTemporaryFile('w', dir=dir_, delete=False, suffix='.tmp') as tmp:
        json.dump(d, tmp, indent=2)
        tmp_path = tmp.name
    os.replace(tmp_path, path)
except Exception as e:
    print(f"shell.json update failed: {e}", file=__import__('sys').stderr)
EOF

# Get monitor name
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

# Launch mpvpaper
# --auto-pause: pauses when wallpaper is hidden (fullscreen app) — prevents overheating
# hwdec=nvdec: NVIDIA dedicated video decode engine (not CUDA/iGPU)
# Note: mpvpaper always uses libmpv VO internally — vo= and gpu-api= options are ignored
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

MPVPAPER_PID=$!
disown $MPVPAPER_PID

# Confirm mpvpaper started; fallback to software decode if not
sleep 0.8
if ! kill -0 $MPVPAPER_PID 2>/dev/null && ! pgrep -x mpvpaper > /dev/null; then
    echo "[$(date '+%H:%M:%S')] mpvpaper failed — trying software decode fallback"
    nice -n 10 mpvpaper \
        --auto-pause \
        -o "loop=inf \
            hwdec=no \
            mute=yes \
            panscan=1.0 \
            cache=no" \
        "$MONITOR" "$PLAY_FILE" >/dev/null 2>&1 &
    disown
fi

notify-send "Live Wallpaper" "▶ $(basename "$VIDEO")" --icon=video-x-generic 2>/dev/null
echo "[$(date '+%H:%M:%S')] mpvpaper launched (PID: $MPVPAPER_PID)"

# Extract frame for color scheme (wait for mpvpaper to be ready)
sleep 1.5

if pgrep -x hyprpicker > /dev/null 2>&1; then
    echo "[$(date '+%H:%M:%S')] Skipping color extraction — hyprpicker is now active"
    exit 0
fi

FRAME_CACHE="$HOME/.cache/caelestia-live-frame.jpg"

if [[ "$VIDEO_EXT" == "gif" ]]; then
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
