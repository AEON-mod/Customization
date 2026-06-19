# YASB Status Bar Configuration

<img width="1917" height="856" alt="YASB Dashboard Main View" src="https://github.com/user-attachments/assets/3ad8acda-94b0-4bb2-9ce4-193dc507a4d5" />
<img width="1761" height="1009" alt="YASB Dashboard Alt View" src="https://github.com/user-attachments/assets/b0dae5cc-eb34-4773-a4a4-304c8be572b8" />
<img width="505" height="431" alt="CPU Monitor Widget" src="https://github.com/user-attachments/assets/297edbc5-fac3-49e7-b910-fb4232f98037" />

## Overview

**YASB** is a lightweight, feature-rich Windows status bar providing real-time system monitoring and quick access to essential information. This configuration includes pre-configured widgets for CPU, RAM, clock, weather, battery, network status, and media controls—ready to use out of the box.

---

## 🚀 Quick Start

### 1. Install YASB

```bash
pip install yasb
```

### 2. Install Configuration & Stylesheet (Recommended)

This repository provides a ready-to-use configuration (`config.yaml`) and a stylesheet (`styles.css`). For YASB to load them, place both files in the YASB configuration directory.

Location (Windows):

```
%APPDATA%\yasb\
```

Steps (professional, safe):

1. Create the configuration directory (if it doesn't exist).
2. Copy `config.yaml` and `styles.css` from this repository into the directory.
3. Verify required watch flags in `config.yaml` so YASB can hot-reload changes.
4. Start or reload YASB.

PowerShell (recommended):

```powershell
# Create target folder (idempotent)
$target = "$env:APPDATA\yasb"
New-Item -ItemType Directory -Force -Path $target | Out-Null

# Copy files from current folder to YASB config folder
Copy-Item -Path .\config.yaml -Destination (Join-Path $target 'config.yaml') -Force
Copy-Item -Path .\styles.css -Destination (Join-Path $target 'styles.css') -Force

# Verify files
Get-ChildItem -Path $target -Filter "config.yaml", "styles.css"
```

Command Prompt (CMD):

```cmd
mkdir "%APPDATA%\yasb"
copy config.yaml "%APPDATA%\yasb\config.yaml" /Y
copy styles.css "%APPDATA%\yasb\styles.css" /Y
```

Notes and verification:

- Ensure the following options are set in `%APPDATA%\yasb\config.yaml`:

```yaml
watch_stylesheet: true
watch_config: true
```

- If your stylesheet has a different filename or path, update `config.yaml` accordingly or use the default `styles.css` filename.
- Use UTF-8 encoding (without BOM) for both files to avoid parsing issues.

### Reloading and Applying Changes

- Start YASB:

```bash
yasb
```

- If YASB is already running, press `Ctrl+Shift+R` to reload configuration and stylesheet (when watch flags are enabled), or restart the application to ensure all changes take effect.

### Backup & Restore (best practice)

- Backup your working configuration before making changes:

```powershell
Copy-Item "$env:APPDATA\yasb\config.yaml" "$env:APPDATA\yasb\config.yaml.bak" -Force
```

- To restore:

```powershell
Copy-Item "$env:APPDATA\yasb\config.yaml.bak" "$env:APPDATA\yasb\config.yaml" -Force
```

---

### Troubleshooting: Config & Stylesheet

- Symptom: YASB ignores stylesheet or config changes
  - Check `watch_stylesheet` and `watch_config` are set to `true`.
  - Verify files are in `%APPDATA%\yasb` and readable by your user account.
  - Inspect YASB logs in the terminal for parsing errors when launching `yasb`.

- Symptom: Visual glitches after applying stylesheet
  - Ensure `styles.css` is valid CSS and encoded as UTF-8.
  - Temporarily revert to the provided `styles.css` to isolate the issue.

- Symptom: Wallpaper paths not working
  - Use absolute paths and escape backslashes (e.g., `C:\Users\Alice\Pictures`).

---

## 📊 Available Widgets

| Widget | Function |
|--------|----------|
| **CPU** | Displays CPU usage percentage |
| **RAM** | Shows memory utilization |
| **Clock** | Current time and date |
| **Weather** | Real-time temperature (requires API key) |
| **Battery** | Battery percentage and status |
| **Network** | WiFi signal strength indicator |
| **Media** | Now playing information from media players |

---

## 🎨 Customization Options

### Change Bar Position

```yaml
bar:
  position: "top"   # Options: "top" or "bottom"
```

### Adjust Opacity

```yaml
bar:
  opacity: 90       # Range: 0-100
```

### Enable Blur Effect

```yaml
bar:
  blur: true
```

### Styling & Live Reload

- Ensure `watch_stylesheet: true` in your `config.yaml` to enable automatic stylesheet reloading.
- Edit `styles.css` in `%APPDATA%\yasb\styles.css` and YASB will apply your changes on save (if `watch_stylesheet` is enabled).

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+R` | Reload configuration |
| `Ctrl+Shift+T` | Switch theme |

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Status bar not appearing | Run `yasb` in terminal to verify installation and check for errors |
| Weather widget not functioning | Ensure API key is correctly added in the `config.yaml` file |
| Auto-start not working | Recreate the YASB shortcut in the startup folder (`shell:startup`) |
| Configuration or stylesheet changes not applied | Confirm `config.yaml` and `styles.css` are in `%APPDATA%\yasb` and `watch_config` / `watch_stylesheet` are set to `true` |

---

## 📁 Repository Contents

- **`config.yaml`** – Pre-configured status bar settings (ready to use)
- **`styles.css`** – Theme and widget styles (copy to `%APPDATA%\yasb\styles.css`)
- **`screenshots/`** – Preview images of the dashboard and individual widgets
- **`README.md`** – This documentation file

---

## 🤝 Support & Contribution

If you encounter any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

---

**Enhance your Windows desktop with real-time system insights. Star ⭐ if you find this helpful!**
