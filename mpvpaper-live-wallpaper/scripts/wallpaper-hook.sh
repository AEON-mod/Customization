#!/bin/bash
# wallpaper-hook.sh — Runs after 'caelestia wallpaper -f <image>' sets an image.
# Videos are handled by live-wallpaper.sh directly, NOT through this hook.
#
# FIXES vs previous version:
#   - Atomic shell.json writes (tmp + rename) — prevents corrupt JSON on crash
#   - Does NOT restart caelestia shell during startup (WALLPAPER_STARTUP=1 guard)
#     The old version force-killed the shell on boot, causing memory dumps
#   - Better process cleanup — waits for mpvpaper to fully exit before continuing
#   - Wallpaper Engine: validates project.json before launching wallpaperengine

# When live-wallpaper.sh calls caelestia just for color extraction, skip everything.
# mpvpaper is already running and we must NOT kill it.
[ "$LIVE_WALLPAPER_COLORS_ONLY" = "1" ] && exit 0

# ── Utility: atomic shell.json update ────────────────────────────────────────
_update_shell_json() {
    python3 - "$1" <<'EOF'
import json, os, sys, tempfile
enabled = sys.argv[1] == 'true'
path = os.path.expanduser('~/.config/caelestia/shell.json')
try:
    with open(path) as f:
        d = json.load(f)
    d.setdefault('background', {})['enabled'] = enabled
    d['background']['wallpaperEnabled'] = enabled
    dir_ = os.path.dirname(path)
    with tempfile.NamedTemporaryFile('w', dir=dir_, delete=False, suffix='.tmp') as tmp:
        json.dump(d, tmp, indent=2)
        tmp_path = tmp.name
    os.replace(tmp_path, path)
except Exception as e:
    print(f"shell.json update failed: {e}", file=sys.stderr)
EOF
}

# ── Kill any active video/scene wallpapers ────────────────────────────────────
pkill -f linux-wallpaperengine 2>/dev/null
if killall mpvpaper 2>/dev/null; then
    # Wait for mpvpaper to fully release the background Wayland surface
    # before we change shell.json (otherwise surface ownership races occur)
    local_retries=0
    while pgrep -x mpvpaper > /dev/null && [ $local_retries -lt 20 ]; do
        sleep 0.1
        local_retries=$((local_retries + 1))
    done
fi
rm -f "$HOME/.local/state/caelestia/wallpaper/is_live_wallpaper_active"

monitors=$(hyprctl monitors -j | jq -r '.[].name')
base_name=$(basename "$WALLPAPER_PATH")
dir_name=$(dirname "$WALLPAPER_PATH")

# ── Wallpaper Engine scene ────────────────────────────────────────────────────
if [[ "$base_name" == "preview.jpg" || "$base_name" == "preview.png" || "$base_name" == "preview.gif" ]]; then
    if [ -f "$dir_name/project.json" ]; then
        _update_shell_json false

        # Only restart shell if NOT on startup (shell was already just started)
        if [ "${WALLPAPER_STARTUP:-0}" != "1" ]; then
            qs -c caelestia kill 2>/dev/null
            sleep 0.5
            hyprctl dispatch exec "caelestia shell -d" > /dev/null 2>&1
            sleep 0.5
        fi

        args=""
        for mon in $monitors; do
            args="$args --screen-root $mon --bg $dir_name"
        done
        linux-wallpaperengine $args &
        disown
    fi
    exit 0
fi

# ── Standard static image ─────────────────────────────────────────────────────
_update_shell_json true

# Restart caelestia shell to recreate the background surface cleanly.
# Skip on startup — shell is already fresh from execs.conf.
if [ "${WALLPAPER_STARTUP:-0}" != "1" ]; then
    qs -c caelestia kill 2>/dev/null
    sleep 0.5
    hyprctl dispatch exec "caelestia shell -d" > /dev/null 2>&1
fi
