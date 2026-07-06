#!/bin/bash
# set-wallpaper.sh — Universal wallpaper setter (Thunar right-click / CLI)
# Routes by file extension:
#   .mp4 / .mkv / .webm / .mov / .gif  → live-wallpaper.sh (mpvpaper)
#   .jpg / .jpeg / .png / .webp         → caelestia wallpaper -f (static)

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
EXT="${EXT,,}"

case "$EXT" in
    mp4|mkv|webm|mov|gif)
        exec ~/.config/hypr/scripts/live-wallpaper.sh "$FILE"
        ;;

    jpg|jpeg|png|webp|tif|tiff)
        # Kill any live wallpaper and wait for surface release
        killall mpvpaper 2>/dev/null
        pkill -f linux-wallpaperengine 2>/dev/null
        rm -f "$HOME/.local/state/caelestia/wallpaper/is_live_wallpaper_active"

        retries=0
        while pgrep -x mpvpaper > /dev/null && [ $retries -lt 20 ]; do
            sleep 0.1
            retries=$((retries + 1))
        done

        # Restore caelestia background atomically before calling caelestia wallpaper
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
        caelestia wallpaper -f "$FILE"
        ;;

    *)
        notify-send "Set Wallpaper" "Unsupported file type: .$EXT" --icon=dialog-error
        exit 1
        ;;
esac
