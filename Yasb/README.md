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
