<img width="1917" height="856" alt="Screenshot 2026-03-31 180110" src="https://github.com/user-attachments/assets/3ad8acda-94b0-4bb2-9ce4-193dc507a4d5" />
<img width="630" height="470" alt="Screenshot 2026-03-31 175859" src="https://github.com/user-attachments/assets/23daa353-a205-427e-9824-38f566f74e0d" />
<img width="457" height="572" alt="Screenshot 2026-03-31 175850" src="https://github.com/user-attachments/assets/63a2c215-fe2c-4120-ae4a-33ab44cb9ffd" />
<img width="616" height="661" alt="Screenshot 2026-03-31 175905" src="https://github.com/user-attachments/assets/b3fc5be5-b8af-48a7-93a8-c454e06a8fd0" />

YASB Status Bar Config 🎯
Simple Windows status bar with CPU, RAM, clock, weather, and more. Ready to use – just copy and run!

![YASB Screenshot]

🚀 Quick Start
Install YASB

bash
pip install yasb
Add Your Config

Download config.yaml

Place it here:
%APPDATA%\yasb\config.yaml
Open ymal.config go to wallpaper section and paste your wallaper folder path
Run YASB

bash
yasb
Auto-Start (Optional)

Press Win + R → type shell:startup → Enter

Copy yasb shortcut to that folder

📊 What You Get
Widget	Shows
CPU	CPU usage %
RAM	Memory used
Clock	Time & date
Weather	Temperature (needs API key)
Battery	Battery %
Network	WiFi signal
Media	Now playing
🎨 Easy Customization
Change position:

text
bar:
  position: "top"   # or "bottom"
Change opacity:

text
bar:
  opacity: 90       # 0-100
Turn on blur:

text
bar:
  blur: true
⌨️ Shortcuts
Ctrl+Shift+R → Reload config

Ctrl+Shift+T → Switch theme

🐛 Troubleshooting
Problem	Fix
Bar not showing	Run yasb in terminal
Weather not working	Add API key in config
Auto-start fails	Recreate shortcut in startup folder
📁 Files
config.yaml – Main config (ready to use)

screenshot.png – Preview

Simple. Clean. Powerful.
Star ⭐ if it helps!
