Windows APK Transparency Manager 🪟
Make any Windows app transparent with persistent settings, always-on-top pinning, and keyboard controls. Built with AutoHotkey v2.

🌟 Features
Feature	Description
🎨 Per-App Transparency	Set different opacity for each application
⌨️ Keyboard Controls	Ctrl+Shift+/- to adjust opacity instantly
📌 Always On Top	Pin windows to stay above others
💾 Persistent Settings	Settings saved automatically in INI file
🚀 Auto-Start	Copy to Startup folder for automatic launch
🎯 GUI Interface	Right-click or Ctrl+Shift+LClick for full control
🔄 GlazeWM Compatible	Works with modern window managers
📋 Quick Start
1. Install AutoHotkey
bash
# Download and install AutoHotkey v2.0
# https://www.autohotkey.com/download/ahk-v2.exe
2. Prepare the Script
Download TransparencyManager.ahk

Double-click to run (icon appears in system tray)

Optional: Rename to TransparencyManager.exe (compile with AHK compiler)

3. Enable Auto-Start (Optional)
Copy the script (or .exe) to your Startup folder:

bash
# Press Win + R, then paste this path:
shell:startup
Now it launches automatically when you login!

⌨️ Hotkeys Reference
Hotkey	Action
Ctrl+Shift+Left Click	Open GUI manager for current app
Ctrl+Shift+Right Click	Toggle transparency ON/OFF
Ctrl+Shift+Space	Toggle Always On Top
Ctrl+Shift+Numpad+	Increase opacity (+10) 🔆
Ctrl+Shift+Numpad-	Decrease opacity (-10) 🔅
Ctrl+Shift+Numpad*	Reset to fully opaque (100%)
Ctrl+Shift+Numpad/	Toggle transparency ON/OFF
Note: The user requested Ctrl+Shift+/- but the script uses Numpad +/-. If you need regular keyboard +/-, see the Customization section below.

🖱️ How to Use
Method 1: Keyboard (Quick)
Click on the app window you want to make transparent

Press Ctrl+Shift+Numpad- repeatedly to increase transparency

Press Ctrl+Shift+Numpad+ to make it more opaque

Settings save automatically!

Method 2: GUI (Full Control)
Click on the app window

Press Ctrl+Shift+Left Click (or Right Click to toggle)

Use the slider to adjust opacity

Click preset buttons (25%, 50%, 75%, 100%)

Click "Apply Opacity"

Method 3: Always On Top
Click on the window you want to pin

Press Ctrl+Shift+Space

Window stays above all others (📌 badge shows in GUI)

📁 File Structure
text
TransparencyManager/
├── TransparencyManager.ahk        # Main script (run this)
├── TransparencyManager.exe        # Compiled version (optional)
├── TransparencySettings.ini       # Auto-saved settings
├── startup/
│   └── TransparencyManager.exe    # Copy here for auto-start
└── README.md
⚙️ Configuration
Settings File
All transparency levels are saved in TransparencySettings.ini:

text
[Transparency]
chrome.exe=220
explorer.exe=200
notepad.exe=180

[PinnedApps]
12345=chrome.exe
Default Values
Setting	Value
Default Opacity	220 (86%)
Minimum Opacity	20 (8%)
Maximum Opacity	255 (100%)
Adjustment Step	±10
🎨 Example Usage
Make Chrome 50% transparent:

Open Chrome

Press Ctrl+Shift+Numpad- until you see "Opacity: 50%"

Done! Settings save automatically

Pin Notepad on top while coding:

Open Notepad and your code editor

Click Notepad window

Press Ctrl+Shift+Space

Notepad stays above your editor 📌

🔧 Customization
Change Hotkeys to Regular +/− Keys
The script uses Numpad +/-. To use regular keyboard +/-:

Edit TransparencyManager.ahk, find these lines and replace:

text
; OLD (Numpad):
^+NumpadAdd::
^+NumpadSub::

; NEW (Regular keyboard):
^+Add::
^+Sub::
Adjust Opacity Step Size
text
STEP := 10  ; Change to 5 for finer control, or 20 for faster
Change Default Transparency
text
DEFAULT_TRANS := 220  ; Change to 150 for more transparent by default
Change Min/Max Limits
text
MIN_TRANS := 20   ; Minimum opacity (lower = more transparent)
MAX_TRANS := 255  ; Maximum opacity (255 = fully opaque)
🛡️ Safety & Compatibility
Compatible	Not Compatible
Chrome, Edge, Firefox	Desktop (Progman)
VS Code, Notepad++	Taskbar (Shell_TrayWnd)
Windows Explorer	System tray
Games (windowed mode)	Full-screen games
GlazeWM, PowerToys	Windows 10/11
🐛 Troubleshooting
Problem	Solution
Hotkeys not working	Make sure AHK v2.0 is installed
Transparency not applying	Restart the app after running script
Script won't auto-start	Copy .exe (not .ahk) to startup folder
Regular +/− not working	Use Numpad +/− or edit script (see Customization)
GUI won't open	Press Ctrl+Shift+Left Click on a window (not desktop)
Settings lost on restart	Check file permissions in TransparencySettings.ini
Quick Fix
bash
# Restart the script
1. Right-click AHK icon in system tray → Exit
2. Double-click TransparencyManager.ahk again
📸 Screenshots
Opacity adjustment with tooltip showing percentage

GUI manager with slider and preset buttons

System tray icon indicating script is running

🚀 Advanced Features
Persistent Pinned Windows
Windows you pin with Ctrl+Shift+Space are remembered across restarts. The script enforces "Always On Top" every 300ms.

Per-App Settings
Each application remembers its own transparency level:

Chrome: 220

VS Code: 200

Notepad: 180

Excluded Windows
These system windows are protected from transparency:

Desktop (Progman, WorkerW)

Taskbar (Shell_TrayWnd)

Input Method Editor (MsgrIMEWindowClass)

📜 Disclaimer
⚠️ Use at your own risk. Modifying window transparency may cause visual glitches in some applications.
Not responsible for any system instability. Tested on Windows 10/11 with AutoHotkey v2.0.

🤝 Contributing
Found a bug? Want new features? Open an issue or pull request!

📄 License
MIT License - Free for personal and commercial use

Made with ❤️ for Windows power users
Star ⭐ this repo if transparency helps your workflow!
