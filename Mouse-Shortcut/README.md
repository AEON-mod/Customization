# 🖱️ AEON-mod: Advanced Mouse Gestures (v4.3.1)
A high-performance Windows optimization script that adds powerful multi-click and spatial gestures to any mouse. Engineered for digital creators and power users who want a seamless, keyboard-free workflow.

## ✨ Core Gestures
| Action | Gesture |
|---|---|
| **Copy** (Ctrl+C) | Double Right Click |
| **Select All** (Ctrl+A) | Triple Right Click |
| **Paste** (Ctrl+V) | Triple Left Click |
| **Back / Forward** | Right Click + Swipe Left/Right |
| **Clipboard History** | Hold Left Click + Tap Right Click |
| **Snipping Tool** | Hold Left Click + Hold Right Click (0.3s) |
| **Task View** (Win+Tab) | Hover Cursor at Top Edge of Screen (1s) |

## 🎮 Smart Game Detection (New!)
AEON-mod is now **Gaming-Aware**. To ensure 100% compatibility with Anti-Cheat systems (Vanguard, EAC, Ricochet) and to prevent accidental "Pastes" during gameplay, the script:
 * **Auto-Suspends:** Instantly disables all gestures when a game window is active.
 * **Auto-Resumes:** Re-enables all features the moment you Alt-Tab out or close the game.
 * **Visual Feedback:** The System Tray icon turns **Red** when paused and **Green** when active.
> **Manual Toggle:** Press the **Scroll Lock** key at any time to manually pause/resume the script.
> 
## 🛡️ Setup & Permissions
### Why Administrator?
This script requires **Run as Administrator** to interact with protected system windows like Task Manager, elevated Command Prompts, and certain File Explorer menus. Without this, Windows blocks the script's ability to send shortcuts for security.

***For quick startup drop the file in startup folder:
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup***

### Bypass UAC (Permanent Admin)
To start AEON-mod automatically without the Windows permission popup:
 1. Open **Task Scheduler** and click **Create Task**.
 2. Under **General**, check **Run with highest privileges**.
 3. Under **Triggers**, set it to **At log on**.
 4. Under **Actions**, point it to your AutoHotkey64.exe and add the script path as an argument:
   * Program: "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
   * Arguments: "C:\Path\To\Your\AEON-mod.ahk"
 5. Under **Conditions**, uncheck **Start only if on AC power**.

## ⚙️ Resource Impact
 * **CPU Usage:** < 0.1% (Event-driven logic).
 * **RAM Usage:** ~5MB.
 * **Latency:** Zero. The script uses low-level Windows hooks for instantaneous response.

## 🛑 Emergency Exit
Press **Shift + Escape** to kill the process immediately.
### How to add new games:
Open the .ahk file and locate the TargetGames variable. Simply add the .exe name of your game to the list:
TargetGames := "ahk_exe Valorant.exe, ahk_exe MyNewGame.exe"

