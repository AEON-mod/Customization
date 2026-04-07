🖱️ AEON-mod: Advanced Mouse Gestures
A lightweight, high-performance AutoHotkey v2 script designed to supercharge your workflow. This script adds multi-click, swipe, and edge-hover gestures to any standard mouse without interfering with your side buttons.

✨ Features
| Action | Gesture |
|---|---|
| Copy (Ctrl+C) | Double Right Click |
| Select All (Ctrl+A) | Triple Right Click |
| Paste (Ctrl+V) | Triple Left Click |
| Back / Forward | Right Click + Swipe Left/Right |
| Clipboard History | Hold Left Click + Tap Right Click |
| Snipping Tool | Hold Left Click + Hold Right Click (0.3s) |
| Task View (Win+Tab) | Hover Cursor at Top Edge of Screen (1s) |
| Native Support | Side buttons (X1/X2) and Middle click are untouched |

🚀 Installation
 * Install AutoHotkey v2.0+: Ensure you have the latest version from autohotkey.com.
 * Download the Script: Save the code as MouseGestures.ahk.
 * Run as Administrator: The script includes an auto-elevation block. When prompted by Windows (UAC), click Yes to allow the script to send commands to restricted apps (like Task Manager or Browsers).

**For quick startup drop the file in startup folder**

 C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
 
🛡️ Why Administrator Privileges?
This script includes an Auto-Admin block. It requires elevated permissions for two critical reasons:
 * System Window Interaction: Without Admin rights, Windows prevents scripts from "clicking" or "typing" inside protected windows like Task Manager, Command Prompt, Registry Editor, and even some parts of File Explorer.
 * Input Priority: Admin status ensures your gestures take priority and aren't "ignored" by Windows when the system is under heavy load.

🚀 Permanent Setup (Bypass UAC Popups)
To have the script start automatically as Administrator without asking for permission every time you boot your PC, follow these steps using the Windows Task Scheduler:
 * Open Task Scheduler: Press Win, type "Task Scheduler", and hit Enter.
 * Create Task: Click Create Task... (on the right-hand panel).
 * General Tab:
   * Name: AEON_MouseGestures
   * Check "Run with highest privileges" (This is the key step).
 * Triggers Tab:
   * Click New... -> Set "Begin the task" to At log on.
 * Actions Tab:
   * Click New... -> Keep "Start a program".
   * Program/script: Browse to your AutoHotkey64.exe (usually in C:\Program Files\AutoHotkey\v2\).
   * Add arguments: Paste the full path to your script file (e.g., "C:\Users\YourName\Documents\AEON-mod.ahk").
 * Conditions Tab:
   * Uncheck "Start the task only if the computer is on AC power" (important for laptops).
 * Finish: Click OK.
Now, the script will launch silently with full power every time you log in!

🛠️ Customization
You can tweak these variables at the top of the script:
 * T := 400: The time window (in milliseconds) allowed between clicks for double/triple click detection.
 * SwipeDist := 50: The distance (in pixels) you need to move the mouse for a Swipe gesture to trigger.

🛑 Emergency Exit
If you need to stop the script immediately, press Shift + Escape.

📝 Final Script Note
Ensure you have AutoHotkey v2.0+ installed. To run the script, simply double-click the .ahk file or use the Task Scheduler method above for a seamless "AEON-mod" experience.
