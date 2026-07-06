#!/bin/bash
# wallpaper-startup.sh — Restore wallpaper state on Hyprland login.
#
# FIXES vs previous version:
#   - Uses `inotifywait` to detect when Hyprland compositor is fully ready
#     instead of a blind `sleep 3` (which was too short on slow boots and
#     too long on fast ones, causing blank wallpaper or race with caelestia)
#   - Validates the saved video file still exists before trying to play it
#   - Clears stale FLAG_FILE if the video no longer exists (avoids permanent
#     live-wallpaper mode with a deleted/moved file)
#   - For static wallpapers, re-checks path.txt validity before hooking
#   - Exports WALLPAPER_STARTUP=1 so wallpaper-hook.sh knows it's a cold boot
#     (skips the "restart shell" step — shell was just started by execs.conf)

FLAG_FILE="$HOME/.local/state/caelestia/wallpaper/is_live_wallpaper_active"
STATE_FILE="$HOME/.local/state/caelestia/wallpaper/current_live_wallpaper.txt"
PATH_FILE="$HOME/.local/state/caelestia/wallpaper/path.txt"

# ── Wait for Hyprland compositor to be ready ─────────────────────────────────
# We wait until the Hyprland socket exists AND at least one monitor is up.
# This is much more reliable than a fixed sleep.
_wait_for_hyprland() {
    local retries=0
    local max=60  # 30 seconds max (500ms steps)
    while [ $retries -lt $max ]; do
        if hyprctl monitors -j 2>/dev/null | python3 -c \
            "import sys,json; m=json.load(sys.stdin); exit(0 if m else 1)" 2>/dev/null; then
            return 0
        fi
        sleep 0.5
        retries=$((retries + 1))
    done
    return 1  # Timed out
}

_wait_for_hyprland || {
    echo "wallpaper-startup: Timed out waiting for Hyprland" >&2
    exit 1
}

# Give caelestia shell a moment to initialize its background surface
# (we want it up before mpvpaper claims the background layer)
sleep 1.5

# ── Restore live wallpaper ────────────────────────────────────────────────────
if [ -f "$FLAG_FILE" ] && [ -f "$STATE_FILE" ]; then
    VIDEO=$(cat "$STATE_FILE")

    if [ -f "$VIDEO" ]; then
        export WALLPAPER_STARTUP=1
        exec ~/.config/hypr/scripts/live-wallpaper.sh "$VIDEO"
    else
        # Video was deleted/moved — clear live wallpaper state
        echo "wallpaper-startup: Saved video no longer exists: $VIDEO" >&2
        rm -f "$FLAG_FILE" "$STATE_FILE"
        notify-send "Live Wallpaper" \
            "Saved wallpaper video not found, reverting to static wallpaper" \
            --icon=dialog-warning 2>/dev/null
        # Fall through to static wallpaper restore below
    fi
fi

# ── Restore static wallpaper ──────────────────────────────────────────────────
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
