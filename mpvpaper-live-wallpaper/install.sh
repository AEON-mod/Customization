#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
# install.sh — mpvpaper Live Wallpaper for Caelestia
# ══════════════════════════════════════════════════════════════════════════════
# Automates the full setup:
#   1. Installs scripts to ~/.config/hypr/scripts/
#   2. Registers wallpaper-hook.sh in caelestia's cli.json
#   3. Adds startup exec and keybind to ~/.config/caelestia/hypr-user.conf
#   4. Creates the live wallpaper directory
#   5. (Optional) Adds Thunar right-click "Set as Wallpaper" action
#
# Run: bash install.sh
# ══════════════════════════════════════════════════════════════════════════════

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET}  $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $*"; }
err()  { echo -e "  ${RED}✗${RESET}  $*"; }
step() { echo -e "\n${CYAN}${BOLD}▶ $*${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}"
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║      mpvpaper Live Wallpaper — Caelestia Setup       ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# ── Dependency check ──────────────────────────────────────────────────────────
step "Checking dependencies"

MISSING=()
for dep in mpvpaper mpv ffmpeg ffprobe python3 notify-send hyprctl; do
    if command -v "$dep" &>/dev/null; then
        ok "$dep"
    else
        err "$dep — NOT FOUND"
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    warn "Missing packages: ${MISSING[*]}"
    warn "Install them before continuing. See README for package names."
    echo ""
    read -rp "  Continue anyway? [y/N] " cont
    [[ "$cont" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

# ── Step 1: Copy scripts ──────────────────────────────────────────────────────
step "Installing scripts → ~/.config/hypr/scripts/"

HYPR_SCRIPTS="$HOME/.config/hypr/scripts"
mkdir -p "$HYPR_SCRIPTS"

SCRIPTS=(live-wallpaper.sh wallpaper-hook.sh wallpaper-startup.sh set-wallpaper.sh)
for s in "${SCRIPTS[@]}"; do
    src="$SCRIPT_DIR/scripts/$s"
    dst="$HYPR_SCRIPTS/$s"
    if [ ! -f "$src" ]; then
        err "$s not found in $SCRIPT_DIR/scripts/ — skipping"
        continue
    fi
    if [ -f "$dst" ]; then
        cp "$dst" "${dst}.bak"
        warn "Backed up existing $s → ${s}.bak"
    fi
    cp "$src" "$dst"
    chmod +x "$dst"
    ok "$s"
done

# ── Step 2: Register postHook in caelestia cli.json ───────────────────────────
step "Registering wallpaper-hook.sh in caelestia cli.json"

CAELESTIA_CONF="$HOME/.config/caelestia"
CLI_JSON="$CAELESTIA_CONF/cli.json"
mkdir -p "$CAELESTIA_CONF"

HOOK_PATH="$HYPR_SCRIPTS/wallpaper-hook.sh"

if [ -f "$CLI_JSON" ]; then
    # Check if postHook is already set correctly
    CURRENT_HOOK=$(python3 -c "
import json, sys
try:
    d = json.load(open('$CLI_JSON'))
    print(d.get('wallpaper', {}).get('postHook', ''))
except:
    print('')
" 2>/dev/null)

    if [ "$CURRENT_HOOK" = "$HOOK_PATH" ]; then
        ok "cli.json already configured correctly"
    else
        # Update atomically
        python3 - "$CLI_JSON" "$HOOK_PATH" <<'EOF'
import json, os, sys, tempfile
path, hook = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        d = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    d = {}
d.setdefault('wallpaper', {})['postHook'] = hook
dir_ = os.path.dirname(path)
with tempfile.NamedTemporaryFile('w', dir=dir_, delete=False, suffix='.tmp') as tmp:
    json.dump(d, tmp, indent=4)
    tmp.write('\n')
    tmp_path = tmp.name
os.replace(tmp_path, path)
print("ok")
EOF
        ok "cli.json updated (postHook → wallpaper-hook.sh)"
    fi
else
    # Create fresh cli.json
    python3 - "$CLI_JSON" "$HOOK_PATH" <<'EOF'
import json, os, sys
path, hook = sys.argv[1], sys.argv[2]
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, 'w') as f:
    json.dump({"wallpaper": {"postHook": hook}}, f, indent=4)
    f.write('\n')
EOF
    ok "cli.json created"
fi

# ── Step 3: Add exec-once and keybind to hypr-user.conf ──────────────────────
step "Adding startup exec + keybind to ~/.config/caelestia/hypr-user.conf"

HYPR_USER_CONF="$CAELESTIA_CONF/hypr-user.conf"
touch "$HYPR_USER_CONF"

EXEC_LINE="exec-once = ~/.config/hypr/scripts/wallpaper-startup.sh"
BIND_LINE="bind = SUPER ALT, W, exec, ~/.config/hypr/scripts/live-wallpaper.sh"

if grep -qF "wallpaper-startup.sh" "$HYPR_USER_CONF"; then
    ok "exec-once for wallpaper-startup.sh already present"
else
    echo "" >> "$HYPR_USER_CONF"
    echo "# mpvpaper live wallpaper — restore wallpaper on login" >> "$HYPR_USER_CONF"
    echo "$EXEC_LINE" >> "$HYPR_USER_CONF"
    ok "Added: $EXEC_LINE"
fi

if grep -qF "live-wallpaper.sh" "$HYPR_USER_CONF"; then
    ok "Keybind for live-wallpaper.sh already present"
else
    echo "" >> "$HYPR_USER_CONF"
    echo "# Live wallpaper shortcut (Super+Alt+W = cycle/set live wallpaper)" >> "$HYPR_USER_CONF"
    echo "$BIND_LINE" >> "$HYPR_USER_CONF"
    ok "Added: $BIND_LINE"
fi

# ── Step 4: Create live wallpaper directory ────────────────────────────────────
step "Creating wallpaper directory"

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/live-wallpaper"
mkdir -p "$WALLPAPER_DIR"
ok "Directory ready: $WALLPAPER_DIR"
ok "Drop your .mp4 / .mkv / .webm / .gif files there"

# ── Step 5: Thunar custom action (optional) ───────────────────────────────────
step "Thunar right-click action (optional)"

UCA_XML="$HOME/.config/Thunar/uca.xml"
if [ -f "$UCA_XML" ] && grep -q "set-wallpaper-caelestia" "$UCA_XML"; then
    ok "Thunar 'Set as Wallpaper' action already registered"
elif [ -f "$UCA_XML" ]; then
    echo ""
    read -rp "  Add 'Set as Wallpaper' right-click action in Thunar? [Y/n] " add_thunar
    if [[ ! "$add_thunar" =~ ^[Nn]$ ]]; then
        # Insert before closing </actions> tag
        ACTION_XML='    <action>
        <icon>preferences-desktop-wallpaper</icon>
        <name>Set as Wallpaper</name>
        <unique-id>set-wallpaper-caelestia</unique-id>
        <command>bash -c '"'"'~/.config/hypr/scripts/set-wallpaper.sh %f'"'"'</command>
        <description>Set selected image, GIF or video as wallpaper (static or live via mpvpaper)</description>
        <patterns>*.png;*.jpg;*.jpeg;*.webp;*.mp4;*.mkv;*.webm;*.mov;*.gif</patterns>
        <image-files/>
        <video-files/>
    </action>'
        # Backup and insert
        cp "$UCA_XML" "${UCA_XML}.bak"
        # Use python for reliable XML manipulation
        python3 - "$UCA_XML" <<'EOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
action = '''    <action>
        <icon>preferences-desktop-wallpaper</icon>
        <name>Set as Wallpaper</name>
        <unique-id>set-wallpaper-caelestia</unique-id>
        <command>bash -c '~/.config/hypr/scripts/set-wallpaper.sh %f'</command>
        <description>Set selected image, GIF or video as wallpaper (static or live via mpvpaper)</description>
        <patterns>*.png;*.jpg;*.jpeg;*.webp;*.mp4;*.mkv;*.webm;*.mov;*.gif</patterns>
        <image-files/>
        <video-files/>
    </action>
</actions>'''
content = content.replace('</actions>', action)
with open(path, 'w') as f:
    f.write(content)
EOF
        ok "Thunar action added (backup saved as uca.xml.bak)"
    else
        warn "Skipped — you can add it manually later (see README)"
    fi
else
    warn "Thunar config not found — launch Thunar once first, then re-run or add manually"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}  ══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}   Installation complete!${RESET}"
echo -e "${BOLD}${GREEN}  ══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo "    1. Drop video/GIF files into ~/Pictures/Wallpapers/live-wallpaper/"
echo "    2. (Optional) Run transcode-wallpapers.sh to optimise them first"
echo "    3. Press  Super+Alt+W  to activate live wallpaper"
echo "    4. Or right-click any file in Thunar → 'Set as Wallpaper'"
echo "    5. Log out and back in (or run 'hyprctl reload') to apply startup"
echo ""
echo -e "  ${CYAN}Scripts installed to:${RESET} ~/.config/hypr/scripts/"
echo -e "  ${CYAN}Wallpaper directory:${RESET}  ~/Pictures/Wallpapers/live-wallpaper/"
echo ""
