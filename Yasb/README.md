# YASB Status Bar Configuration

<img width="1917" height="856" alt="YASB Dashboard Main View" src="https://github.com/user-attachments/assets/3ad8acda-94b0-4bb2-9ce4-193dc507a4d5" />
<img width="1761" height="1009" alt="YASB Dashboard Alt View" src="https://github.com/user-attachments/assets/b0dae5cc-eb34-4773-a4a4-304c8be572b8" />
<img width="505" height="431" alt="CPU Monitor Widget" src="https://github.com/user-attachments/assets/297edbc5-fac3-49e7-b910-fb4232f98037" />

<img width="630" height="470" alt="Weather Widget" src="https://github.com/user-attachments/assets/23daa353-a205-427e-9824-38f566f74e0d" />
<img width="457" height="572" alt="Network Status Widget" src="https://github.com/user-attachments/assets/63a2c215-fe2c-4120-ae4a-33ab44cb9ffd" />
<img width="616" height="661" alt="Media Control Widget" src="https://github.com/user-attachments/assets/b3fc5be5-b8af-48a7-93a8-c454e06a8fd0" />

## Overview

**YASB** is a lightweight, feature-rich Windows status bar providing real-time system monitoring and quick access to essential information. This configuration includes pre-configured widgets for CPU, RAM, clock, weather, battery, network status, and media controls—ready to use out of the box.

---

## 🚀 Quick Start

### 1. Install YASB

```bash
pip install yasb
```

### 2. Add Configuration

- Download the `config.yaml` file from this repository
- Place it in your YASB configuration directory:
  ```
  %APPDATA%\yasb\config.yaml
  ```

### 3. Configure Wallpaper Path

- Open `config.yaml` in your text editor
- Navigate to the `wallpaper` section
- Replace the placeholder with your wallpaper folder path

### 4. Launch YASB

```bash
yasb
```

### 5. Set Up Auto-Start (Optional)

To automatically launch YASB on system startup:

1. Press `Win + R`
2. Type `shell:startup` and press `Enter`
3. Copy the YASB shortcut to the startup folder

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
| Configuration not updating | Use `Ctrl+Shift+R` to reload the configuration |

---

## 📁 Repository Contents

- **`config.yaml`** – Pre-configured status bar settings (ready to use)
- **`screenshots/`** – Preview images of the dashboard and individual widgets
- **`README.md`** – This documentation file

---

## 🤝 Support & Contribution

If you encounter any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

---

**Enhance your Windows desktop with real-time system insights. Star ⭐ if you find this helpful!**
