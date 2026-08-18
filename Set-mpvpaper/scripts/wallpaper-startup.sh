#!/bin/bash
# wallpaper-startup.sh — Restore wallpaper state on Hyprland login.

FLAG_FILE="$HOME/.local/state/caelestia/wallpaper/is_live_wallpaper_active"
STATE_FILE="$HOME/.local/state/caelestia/wallpaper/current_live_wallpaper.txt"
PATH_FILE="$HOME/.local/state/caelestia/wallpaper/path.txt"

# Wait for Hyprland compositor to be ready (polls every 500ms, 30s max)
_wait_for_hyprland() {
    local retries=0
    while [ $retries -lt 60 ]; do
        if hyprctl monitors -j 2>/dev/null | python3 -c \
            "import sys,json; m=json.load(sys.stdin); exit(0 if m else 1)" 2>/dev/null; then
            return 0
        fi
        sleep 0.5
        retries=$((retries + 1))
    done
    return 1
}

_wait_for_hyprland || {
    echo "wallpaper-startup: Timed out waiting for Hyprland" >&2
    exit 1
}

# Give caelestia shell time to initialize its background surface
sleep 1.5

# Restore live wallpaper
if [ -f "$FLAG_FILE" ] && [ -f "$STATE_FILE" ]; then
    VIDEO=$(cat "$STATE_FILE")

    if [ -f "$VIDEO" ]; then
        export WALLPAPER_STARTUP=1
        exec ~/.config/hypr/scripts/live-wallpaper.sh "$VIDEO"
    else
        echo "wallpaper-startup: Saved video no longer exists: $VIDEO" >&2
        rm -f "$FLAG_FILE" "$STATE_FILE"
        notify-send "Live Wallpaper" \
            "Saved wallpaper video not found, reverting to static wallpaper" \
            --icon=dialog-warning 2>/dev/null
    fi
fi

# Restore static wallpaper
if [ -f "$PATH_FILE" ]; then
    WALLPAPER_PATH=$(cat "$PATH_FILE")

    if [ -f "$WALLPAPER_PATH" ]; then
        export WALLPAPER_PATH
        export WALLPAPER_STARTUP=1
        exec ~/.config/hypr/scripts/wallpaper-hook.sh
    else
        echo "wallpaper-startup: Saved static wallpaper not found: $WALLPAPER_PATH" >&2
    fi
fi

echo "wallpaper-startup: No saved wallpaper state to restore"
