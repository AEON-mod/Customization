# 📊 YASB Status Bar Configuration

<img width="1917" height="856" alt="YASB Dashboard Main View" src="https://github.com/user-attachments/assets/3ad8acda-94b0-4bb2-9ce4-193dc507a4d5" />
<img width="1761" height="1009" alt="YASB Dashboard Alt View" src="https://github.com/user-attachments/assets/b0dae5cc-eb34-4773-a4a4-304c8be572b8" />

A lightweight, feature-rich Windows status bar with real-time system monitoring. This repository provides a ready-to-use configuration with pre-built widgets for CPU, RAM, clock, weather, battery, network, and media controls.

---

## ⚡ Quick Setup

### 1. Install YASB
```bash
pip install yasb
```

### 2. Add Configuration Files

Copy `config.yaml` and `styles.css` to your YASB config directory:

**PowerShell (Recommended):**
```powershell
$target = "$env:APPDATA\yasb"
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -Path .\config.yaml, .\styles.css -Destination $target -Force
```

**Command Prompt:**
```cmd
mkdir "%APPDATA%\yasb"
copy config.yaml "%APPDATA%\yasb\config.yaml" /Y
copy styles.css "%APPDATA%\yasb\styles.css" /Y
```

### 3. Enable Auto-Reload
Ensure your `config.yaml` has:
```yaml
watch_config: true
watch_stylesheet: true
```

### 4. Start YASB
```bash
yasb
```

Use `Ctrl+Shift+R` to reload changes after editing files.

---

## 🎨 Available Widgets

| Widget | Purpose |
|--------|---------|
| 🖥️ **CPU** | Real-time CPU usage |
| 🧠 **RAM** | Memory utilization |
| 🕐 **Clock** | Time & date display |
| 🌤️ **Weather** | Temperature (API key required) |
| 🔋 **Battery** | Battery status & percentage |
| 📶 **Network** | WiFi signal strength |
| 🎵 **Media** | Now playing info |

---

## ⚙️ Customization

### Bar Position & Appearance
```yaml
bar:
  position: "top"        # "top" or "bottom"
  opacity: 90            # 0-100
  blur: true             # Enable blur effect
```

### Edit Styles
Modify `%APPDATA%\yasb\styles.css` — changes auto-apply when `watch_stylesheet: true`.

---

## ⌨️ Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+R` | Reload config |
| `Ctrl+Shift+T` | Switch theme |

---

## 🐛 Troubleshooting

**Status bar not appearing?**
- Run `yasb` in terminal and check for error messages

**Weather widget failing?**
- Verify API key in `config.yaml`

**Changes not applying?**
- Confirm files are in `%APPDATA%\yasb`
- Check that `watch_config` and `watch_stylesheet` are `true`
- Use UTF-8 encoding (no BOM) for both files

**Auto-start not working?**
- Recreate YASB shortcut in Windows Startup folder (`shell:startup`)

---

## 📁 What's Included

- `config.yaml` – Pre-configured settings
- `styles.css` – Theme & widget styling
- `screenshots/` – Preview images
- `README.md` – Documentation

---

**Transform your Windows taskbar. Star ⭐ if you find this useful!**
