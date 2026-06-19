# Windhawk Customization Collection

A comprehensive collection of UI customization mods for [Windhawk](https://windhawk.net), enabling advanced styling of Windows notifications, windows, taskbars, and start menus across both dark and light themes.

## Overview

This repository contains pre-configured Windhawk mod codes designed to enhance your Windows experience with:

- **Notification Styling**: Theme-specific notification customization
- **Window Transparency**: Adjustable opacity and glass effects
- **Taskbar Customization**: Color, transparency, and styling controls
- **Start Menu Styling**: Custom appearance and layout modifications

## Features

| Feature | Description | Compatibility |
|---------|-------------|-----------------|
| Dark Mode Notifications | Optimized notification styling for dark theme | Dark Mode |
| Light Mode Notifications | Optimized notification styling for light theme | Light Mode |
| Semi-Translucent Windows | Subtle transparency effect (80% opacity) with blur | Both Modes |
| Fully Translucent Windows | Enhanced glass effect (50% opacity) | Both Modes |
| Taskbar Styler | Advanced taskbar appearance customization | Both Modes |
| Start Menu Codes | Custom start menu styling | Both Modes |

## Contents

```
Windhawk-Styler/
├── Notification Styler Codes for Dark Mode.txt
├── Notification Styler Codes for Light Mode.txt
├── Semi Translucent Windows.txt
├── Start Menu Codes.txt
├── Taskbar Styler.txt
├── Translucent Windows.txt
└── README.md
```

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Windows Version | Windows 10 (1903+) | Windows 11 (22H2+) |
| Windhawk | v1.0+ | Latest version |
| RAM | 4 GB | 8 GB+ |
| GPU | Any | DirectX 11+ |

### Windows Compatibility

| Version | Status |
|---------|--------|
| Windows 10 1903+ | ✅ Supported |
| Windows 10 21H2 | ✅ Supported |
| Windows 11 21H2+ | ✅ Supported |
| Windows Server | ⚠️ Test before deployment |

## Getting Started

### 1. Install Windhawk

1. Download Windhawk from [windhawk.net](https://windhawk.net)
2. Install and launch the application
3. Create a free account to sync settings across devices

### 2. Import Mods

#### Option A: Import from Clipboard (Recommended)

1. Open the desired `.txt` file from this repository
2. Select all content (`Ctrl+A`) and copy (`Ctrl+C`)
3. Launch Windhawk
4. Click **+ Add mod** → **Import from clipboard**
5. Paste the code (`Ctrl+V`)
6. Click **Install mod**
7. Restart Windows Explorer when prompted

#### Option B: Manual Entry

1. Open Windhawk
2. Click **+ Add mod** → **Create custom mod**
3. Paste the code into the editor
4. Assign a descriptive name (e.g., "Dark Notification Styler")
5. Click **Save** → **Install**

## Usage Guide

### For Theme-Specific Notifications

**Dark Theme Users:**
- Import: `Notification Styler Codes for Dark Mode.txt`
- Provides optimized dark notification styling

**Light Theme Users:**
- Import: `Notification Styler Codes for Light Mode.txt`
- Provides optimized light notification styling

⚠️ **Note**: Use only the mod that matches your system theme to avoid visual inconsistencies.

### For Window Transparency

| File | Opacity | Effect | Best For |
|------|---------|--------|----------|
| `Semi Translucent Windows.txt` | 80% | Subtle transparency | Minimal visual impact |
| `Translucent Windows.txt` | 50% | Enhanced glass effect | Maximum visual impact |

### For Taskbar & Start Menu

Both `Taskbar Styler.txt` and `Start Menu Codes.txt` are compatible with both themes and support:
- Custom color schemes (hex code support)
- Transparency adjustments
- Layout modifications

## Customization

### Adjust Transparency

1. Open Windhawk
2. Locate your transparency mod
3. Click the mod → **Settings**
4. Adjust the Opacity slider (0–255)
5. Click **Save**

### Change Colors

1. Open Windhawk
2. Select your Taskbar/Start Menu mod
3. Navigate to **Settings**
4. Update background and border colors using hex codes (e.g., `#1E1E1E`, `#0078D4`)
5. Click **Save**

### Enable/Disable Mods

Use the toggle switch next to each mod in Windhawk's main list. No reinstallation is required.

### Remove Mods

1. Open Windhawk
2. Select the mod to remove
3. Click **Uninstall**
4. Restart Windows Explorer

## Recommended Configurations

### Dark Theme Setup
```
✅ Notification Styler (Dark Mode)
✅ Semi Translucent Windows
✅ Taskbar Styler
✅ Start Menu Codes
```

### Light Theme Setup
```
✅ Notification Styler (Light Mode)
✅ Translucent Windows
✅ Taskbar Styler
✅ Start Menu Codes
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Changes not visible | Restart Windows Explorer (Task Manager → Right-click **Windows Explorer** → **Restart**) |
| Black screen/glitches | Disable transparency mod, uninstall, and reinstall |
| Start menu not responding | Uninstall Start Menu mod and restart Explorer |
| Taskbar disappears | Uninstall Taskbar Styler and restart |
| Notifications not styled correctly | Verify you're using the mod matching your system theme |
| Mod installation fails | Ensure Windhawk is updated to v1.0+ |
| Settings not persisting | Run Windhawk as Administrator |

### Full Reset

If issues persist:

1. Open Windhawk
2. Uninstall all mods
3. Restart your computer
4. Reinstall mods one at a time to identify conflicts

## Best Practices

| ✅ Do | ❌ Don't |
|------|---------|
| Use dark notification codes with dark theme | Mix dark and light notification codes |
| Test mods individually before combining | Apply all mods simultaneously |
| Restart Explorer after installation | Edit `.txt` files before importing |
| Create a system restore point before installation | Use on production/enterprise systems without testing |
| Run Windhawk as Administrator | Share `.txt` files without documentation |

## Important Disclaimer

⚠️ **Modifying system UI components may cause instability.** While thoroughly tested on Windows 10/11 with Windhawk v1.3+, use at your own risk. **Always create a system restore point before installation.**

## Contributing

We welcome bug reports, feature requests, and custom mod submissions. Please open an issue or submit a pull request with your contributions.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

**Made with ❤️ for Windows customization enthusiasts**

If this collection helps you achieve your desired look, please consider starring ⭐ this repository to show your support.
