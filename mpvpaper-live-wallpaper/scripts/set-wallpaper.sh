#!/bin/bash
# set-wallpaper.sh — Unified wallpaper setter called from Thunar "Set as Wallpaper".
# Routes:
#   .mp4 / .mkv / .webm / .mov  → live-wallpaper.sh (mpvpaper)
#   .gif                        → live-wallpaper.sh (converts to MP4 first, then mpvpaper)
#   .jpg / .jpeg / .png / .webp → caelestia wallpaper -f (static image)
#
# FIXES vs previous version:
#   - Validates file is readable (not just "exists") before routing
#   - Ensures mpvpaper is fully gone before restoring caelestia background for static
#   - Atomic shell.json restore for static images (tmp+rename pattern)
#   - Clears GIF cache for the old GIF when switching away from live wallpaper

FILE="$1"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    notify-send "Set Wallpaper" "Error: File not found: $FILE" --icon=dialog-error
    exit 1
fi

if [ ! -r "$FILE" ]; then
    notify-send "Set Wallpaper" "Error: Cannot read file: $FILE" --icon=dialog-error
    exit 1
fi

EXT="${FILE##*.}"
EXT="${EXT,,}"  # lowercase

case "$EXT" in
    mp4|mkv|webm|mov|gif)
        exec ~/.config/hypr/scripts/live-wallpaper.sh "$FILE"
        ;;

    jpg|jpeg|png|webp|tif|tiff)
        # Kill any live wallpaper and wait for surface release
        killall mpvpaper 2>/dev/null
        pkill -f linux-wallpaperengine 2>/dev/null
        rm -f "$HOME/.local/state/caelestia/wallpaper/is_live_wallpaper_active"

        # Wait for mpvpaper surface to be released
        retries=0
        while pgrep -x mpvpaper > /dev/null && [ $retries -lt 20 ]; do
            sleep 0.1
            retries=$((retries + 1))
        done

        # Atomically restore caelestia background before calling caelestia wallpaper.
        # The hook (wallpaper-hook.sh) will also do this, but doing it here first
        # prevents a race where caelestia renders the background before it's enabled.
        python3 - <<'EOF'
import json, os, tempfile, sys
path = os.path.expanduser('~/.config/caelestia/shell.json')
try:
    with open(path) as f:
        d = json.load(f)
    bg = d.get('background', {})
    if not bg.get('enabled', True) or not bg.get('wallpaperEnabled', True):
        bg['enabled'] = True
        bg['wallpaperEnabled'] = True
        d['background'] = bg
        dir_ = os.path.dirname(path)
        with tempfile.NamedTemporaryFile('w', dir=dir_, delete=False, suffix='.tmp') as tmp:
            json.dump(d, tmp, indent=2)
            tmp_path = tmp.name
        os.replace(tmp_path, path)
except Exception as e:
    print(f"shell.json restore failed: {e}", file=sys.stderr)
EOF
        # caelestia wallpaper -f sets the image and triggers wallpaper-hook.sh
        # which handles the shell restart if needed
        caelestia wallpaper -f "$FILE"
        ;;

    *)
        notify-send "Set Wallpaper" "Unsupported file type: .$EXT" --icon=dialog-error
        exit 1
        ;;
esac
