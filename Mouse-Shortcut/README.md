# 🛸 MouseGestures-1
### *The Ultimate Windows Navigation Engine*
**Stop stretching for your keyboard.** MouseGestures-1 transforms any standard mouse into a productivity powerhouse. By mapping complex Windows shortcuts to intuitive multi-clicks and spatial "swipes," you can navigate, code, and create without ever lifting your hand.
## 🚀 Why Use It?
 * **Ergonomic Efficiency:** Reduce wrist strain by eliminating repetitive Ctrl+C/V stretches.
 * **Invisible UI:** No extra buttons needed—just the mouse you already own.
 * **Zero Bloat:** Uses **<0.1% CPU** and **~5MB RAM**. It’s lighter than a single browser tab.
## ✨ The Gesture Library
| Action | Mouse Input | Result |
|---|---|---|
| **📋 Copy** | Double Right Click | Instantly copy selection |
| **✅ Select All** | Triple Right Click | Highlight everything |
| **📥 Paste** | Triple Left Click | Paste from clipboard |
| **🧭 Navigate** | Right Click + Swipe | Left = Back | Right = Forward |
| **🗂️ History** | Hold Left + Tap Right | Open Clipboard History |
| **📸 Screenshot** | Hold Left + Hold Right | Trigger Snipping Tool |
| **🖥️ Task View** | Hover Top Edge (1s) | See all open windows |
## 🎮 Intelligence: "Gamer-Safe" Mode
**MouseGestures-1** is built for enthusiasts. It features a **Smart-Sense Timer** that detects when you are in a game and automatically **Suspends** itself.
 * **100% Anti-Cheat Compatible:** It stops "hooking" your mouse when a game is active.
 * **Visual Feedback:** The tray icon turns **🔴 Red (Paused)** when gaming and **🟢 Green (Active)** on your desktop.
### 🛠️ Adding Your Games
 1. Open **Task Manager** (Ctrl+Shift+Esc).
 2. Go to **Details** and find your game (e.g., Overwatch.exe).
 3. Open MouseGestures-1.ahk and add it to the TargetGames list:
   > TargetGames := "ahk_exe Valorant.exe, ahk_exe Overwatch.exe"
 4. **For quick startup drop the script in startup folder:**
   > C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
## 🛡️ Setup (The "Pro" Way)
To make **MouseGestures-1** feel like a built-in Windows feature (running with Admin rights but without the annoying popups):
 1. Open **Task Scheduler** and **Create Task**.
 2. **General:** Check Run with highest privileges.
 3. **Triggers:** Set to At log on.
 4. **Actions:** * Program: Browse to AutoHotkey64.exe
   * Arguments: Paste the path to "C:\...\MouseGestures-1.ahk"
 5. **Conditions:** Uncheck Start only if on AC power.
## 🛑 Control Center
 * **Pause/Resume:** Scroll Lock (Manual toggle)
 * **Instant Kill:** Shift + Escape (Panic button)
### 📡 Developer Note
Designed for the **AEON-mod** ecosystem. If you’re a coder, digital creator, or just a power user, this is the missing piece of your Windows experience.
**Ready to fly?** Just run the script. 🖱️✨
