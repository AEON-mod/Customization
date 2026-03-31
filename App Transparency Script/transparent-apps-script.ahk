; ============================================================
;  TransparencyManager.ahk  —  AHK v2
;  Per-app window transparency + Always On Top
;  with persistent INI storage — GlazeWM compatible
;
;  HOTKEYS:
;    Ctrl+Shift+LClick     → Open GUI to manage current app
;    Ctrl+Shift+RClick     → Toggle transparency ON/OFF for current app
;    Ctrl+Shift+Space      → Toggle Always On Top for current window
;    Ctrl+Shift+Numpad+    → Increase opacity  (+10)
;    Ctrl+Shift+Numpad-    → Decrease opacity  (-10)
;    Ctrl+Shift+Numpad*    → Reset to fully opaque (255)
;    Ctrl+Shift+Numpad/    → Toggle transparency ON/OFF for current app
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

; ─── Constants ───────────────────────────────────────────────
CONFIG_FILE   := A_ScriptDir . "\TransparencySettings.ini"
INI_SECTION   := "Transparency"
PIN_SECTION   := "PinnedApps"
STEP          := 10
MIN_TRANS     := 20
MAX_TRANS     := 255
DEFAULT_TRANS := 220

; ─── State ───────────────────────────────────────────────────
global transparencyLevels := Map()   ; lowercase proc → opacity value
global disabledApps       := Map()   ; lowercase proc → true (transparency off)
global pinnedWindows      := Map()   ; winID → proc (always-on-top enforced)

; ─── Boot ────────────────────────────────────────────────────
LoadSettings()
ApplyTransparency()   ; immediate first run
SetTimer(ApplyTransparency, 300)
SetTimer(EnforcePinnedWindows, 300)
A_IconTip := "Transparency Manager"

; ============================================================
;  HOTKEYS
; ============================================================

; Ctrl+Shift+Left Click → Open GUI
^+LButton:: ShowAppGui()

; Ctrl+Shift+Right Click → Toggle transparency ON/OFF
^+RButton::
{
    proc := SafeGetProc()
    if (proc = "")
        return
    EnsureEntry(proc)
    ToggleApp(proc)
}

; Ctrl+Shift+Space → Toggle Always On Top
^+Space::
{
    try
    {
        if (!WinExist("A"))
            return
        cls := WinGetClass("A")
        if (cls = "Progman" || cls = "WorkerW" || cls = "Shell_TrayWnd")
        {
            ShowTip("⛔ Cannot pin desktop / taskbar", 1600)
            return
        }
        wid  := WinGetID("A")
        proc := WinGetProcessName("A")
        TogglePin(wid, proc)
    }
    catch Error as e
        ShowTip("⛔ Could not pin this window", 1600)
}

; Ctrl+Shift+Numpad+ → More opaque
^+NumpadAdd::
{
    proc := SafeGetProc()
    if (proc = "")
        return
    EnsureEntry(proc)
    if (disabledApps.Has(proc))
        disabledApps.Delete(proc)
    newVal := Min(transparencyLevels[proc] + STEP, MAX_TRANS)
    SetAppTransparency(proc, newVal)
    ShowTip("🔆 Opacity: " . Round((newVal / 255) * 100) . "% (" . newVal . ")", 900)
}

; Ctrl+Shift+Numpad- → More transparent
^+NumpadSub::
{
    proc := SafeGetProc()
    if (proc = "")
        return
    EnsureEntry(proc)
    if (disabledApps.Has(proc))
        disabledApps.Delete(proc)
    newVal := Max(transparencyLevels[proc] - STEP, MIN_TRANS)
    SetAppTransparency(proc, newVal)
    ShowTip("🔅 Opacity: " . Round((newVal / 255) * 100) . "% (" . newVal . ")", 900)
}

; Ctrl+Shift+Numpad* → Reset fully opaque
^+NumpadMult::
{
    proc := SafeGetProc()
    if (proc = "")
        return
    SetAppTransparency(proc, MAX_TRANS)
    if (disabledApps.Has(proc))
        disabledApps.Delete(proc)
    ShowTip("✅ Reset: fully opaque", 1200)
}

; Ctrl+Shift+Numpad/ → Toggle transparency ON/OFF
^+NumpadDiv::
{
    proc := SafeGetProc()
    if (proc = "")
        return
    EnsureEntry(proc)
    ToggleApp(proc)
}

; ============================================================
;  ALWAYS ON TOP — CORE
; ============================================================

TogglePin(wid, proc)
{
    global pinnedWindows

    if (pinnedWindows.Has(wid))
    {
        pinnedWindows.Delete(wid)
        try WinSetAlwaysOnTop(0, "ahk_id " . wid)
        SavePinnedApps()
        ShowTip("📌 Unpinned  —  " . proc, 1600)
    }
    else
    {
        pinnedWindows[wid] := proc
        try WinSetAlwaysOnTop(1, "ahk_id " . wid)
        SavePinnedApps()
        ShowTip("📌 Pinned On Top  —  " . proc, 1600)
    }
}

EnforcePinnedWindows()
{
    global pinnedWindows
    deadIDs := []
    for wid, proc in pinnedWindows
    {
        if (!WinExist("ahk_id " . wid))
        {
            deadIDs.Push(wid)
            continue
        }
        try
        {
            exStyle := WinGetExStyle("ahk_id " . wid)
            if (!(exStyle & 0x8))
                WinSetAlwaysOnTop(1, "ahk_id " . wid)
        }
    }
    for , wid in deadIDs
        pinnedWindows.Delete(wid)
}

IsWinPinned(wid)
{
    global pinnedWindows
    return pinnedWindows.Has(wid)
}

; ============================================================
;  TRANSPARENCY — CORE
; ============================================================

ApplyTransparency()
{
    global transparencyLevels, disabledApps
    for proc, level in transparencyLevels
    {
        effectiveLevel := disabledApps.Has(proc) ? MAX_TRANS : level
        wins := WinGetList("ahk_exe " . proc)
        for , wid in wins
            SafeSetTrans(wid, effectiveLevel)
    }
}

SetAppTransparency(proc, value)
{
    global transparencyLevels
    lcProc := StrLower(proc)
    transparencyLevels[lcProc] := value
    SaveSetting(lcProc, value)
    wins := WinGetList("ahk_exe " . proc)
    for , wid in wins
        SafeSetTrans(wid, value)
}

ToggleApp(proc)
{
    global disabledApps, transparencyLevels
    lcProc := StrLower(proc)
    if (disabledApps.Has(lcProc))
    {
        disabledApps.Delete(lcProc)
        wins := WinGetList("ahk_exe " . proc)
        for , wid in wins
            SafeSetTrans(wid, transparencyLevels[lcProc])
        ShowTip("✅ Transparency ON`n" . proc . "`nOpacity: " . Round((transparencyLevels[lcProc] / 255) * 100) . "%", 1600)
    }
    else
    {
        disabledApps[lcProc] := true
        wins := WinGetList("ahk_exe " . proc)
        for , wid in wins
            SafeSetTrans(wid, MAX_TRANS)
        ShowTip("❌ Transparency OFF`n" . proc, 1600)
    }
}

SafeSetTrans(wid, level)
{
    try
    {
        if (!WinExist("ahk_id " . wid))
            return
        cls := WinGetClass("ahk_id " . wid)
        if (cls = "Progman" || cls = "WorkerW" || cls = "Shell_TrayWnd"
         || cls = "DV2ControlHost" || cls = "MsgrIMEWindowClass")
            return
        WinSetTransparent(level, "ahk_id " . wid)
    }
}

; ============================================================
;  HELPERS
; ============================================================

SafeGetProc()
{
    try
    {
        if (!WinExist("A"))
            return ""
        cls := WinGetClass("A")
        if (cls = "Progman" || cls = "WorkerW" || cls = "Shell_TrayWnd")
        {
            ShowTip("⛔ Cannot apply to desktop / taskbar", 1800)
            return ""
        }
        return StrLower(WinGetProcessName("A"))
    }
    catch
        return ""
}

EnsureEntry(proc)
{
    global transparencyLevels
    lcProc := StrLower(proc)
    if (!transparencyLevels.Has(lcProc))
    {
        transparencyLevels[lcProc] := DEFAULT_TRANS
        SaveSetting(lcProc, DEFAULT_TRANS)
    }
}

ShowTip(text, ms := 1200)
{
    ToolTip(text)
    SetTimer(() => ToolTip(), -ms)
}

; ============================================================
;  INI PERSISTENCE
; ============================================================

LoadSettings()
{
    global transparencyLevels, CONFIG_FILE, INI_SECTION, MIN_TRANS, MAX_TRANS, DEFAULT_TRANS

    ; Retry up to 10 times (500 ms each) if file doesn't exist or is empty
    loop 10
    {
        if FileExist(CONFIG_FILE)
        {
            content := FileRead(CONFIG_FILE)
            if (StrLen(content) > 10)
                break
        }
        Sleep 500
    }

    if !FileExist(CONFIG_FILE)
    {
        FileAppend("[" . INI_SECTION . "]`n", CONFIG_FILE)
        return
    }

    ; Remove BOM if present
    if (SubStr(content, 1, 1) == Chr(0xFEFF))
        content := SubStr(content, 2)
    else if (SubStr(content, 1, 3) == Chr(0xEF) . Chr(0xBB) . Chr(0xBF))
        content := SubStr(content, 4)

    lines := StrSplit(content, "`n", "`r")
    inSection := false

    for index, line in lines
    {
        line := Trim(line)
        if (line = "")
            continue

        if (line = "[" . INI_SECTION . "]")
        {
            inSection := true
            continue
        }

        if (SubStr(line, 1, 1) = "[")
        {
            inSection := false
            continue
        }

        if !inSection
            continue

        pos := InStr(line, "=")
        if (pos < 2)
            continue

        appName := Trim(SubStr(line, 1, pos - 1))
        rawVal  := Trim(SubStr(line, pos + 1))

        if !IsInteger(rawVal)
            continue

        val := Integer(rawVal)
        if (val < MIN_TRANS || val > MAX_TRANS)
            val := DEFAULT_TRANS

        transparencyLevels[StrLower(appName)] := val
    }
}

SaveSetting(appName, value)
{
    global CONFIG_FILE, INI_SECTION
    IniWrite(value, CONFIG_FILE, INI_SECTION, appName)
}

SavePinnedApps()
{
    global pinnedWindows, CONFIG_FILE, PIN_SECTION
    try IniDelete(CONFIG_FILE, PIN_SECTION)
    for wid, proc in pinnedWindows
        IniWrite(proc, CONFIG_FILE, PIN_SECTION, wid)
}

DeleteSetting(appName)
{
    global CONFIG_FILE, INI_SECTION
    lcProc := StrLower(appName)
    try IniDelete(CONFIG_FILE, INI_SECTION, lcProc)
    global transparencyLevels, disabledApps
    if (transparencyLevels.Has(lcProc))
        transparencyLevels.Delete(lcProc)
    if (disabledApps.Has(lcProc))
        disabledApps.Delete(lcProc)
}

; ============================================================
;  GUI  (Ctrl+Shift+Left Click)
; ============================================================

ShowAppGui()
{
    global transparencyLevels, disabledApps, pinnedWindows

    proc := SafeGetProc()
    if (proc = "")
        return
    EnsureEntry(proc)

    lcProc := proc
    isOff    := disabledApps.Has(lcProc)
    curLevel := transparencyLevels[lcProc]
    curPct   := Round((curLevel / 255) * 100)
    wid      := WinGetID("A")
    isPinned := IsWinPinned(wid)

    g := Gui("+AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox", "  🪟 Transparency Manager")
    g.BackColor := "0x1E1E2E"
    g.SetFont("s9 c0xF0F0F0", "Segoe UI")
    g.MarginX := 20
    g.MarginY := 16

    ; ── Header ───────────────────────────────────────────────
    g.SetFont("s8 c0xA0A0C0", "Segoe UI")
    g.AddText("w300", "ACTIVE APPLICATION")
    g.SetFont("s11 Bold c0xFFFFFF", "Segoe UI")
    g.AddText("w300 y+4", proc)

    ; Status badges
    g.SetFont("s9 c0x" . (isOff ? "FF6B6B" : "69FF94"), "Segoe UI")
    g.AddText("w144 y+4", isOff ? "⬤  Transparency OFF" : "⬤  Transparency ON")
    g.SetFont("s9 c0x" . (isPinned ? "FFD700" : "606080"), "Segoe UI")
    g.AddText("w144 yp Right", isPinned ? "📌 Pinned ON TOP" : "📌 Not Pinned")

    ; ── Divider ──────────────────────────────────────────────
    g.SetFont("s8 c0x404060", "Segoe UI")
    g.AddText("w300 y+12", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; ── Slider ───────────────────────────────────────────────
    g.SetFont("s9 c0xA0A0C0", "Segoe UI")
    g.AddText("w150 y+10", "OPACITY LEVEL")
    g.SetFont("s11 Bold c0xFFFFFF", "Segoe UI")
    lblPct := g.AddText("w140 yp Right", curPct . "%")
    g.SetFont("s9 c0xF0F0F0", "Segoe UI")
    slider := g.AddSlider("w300 y+6 Range20-255 TickInterval10 Page10 AltSubmit", curLevel)
    g.SetFont("s8 c0x606080", "Segoe UI")
    g.AddText("w150 y+4", "More Transparent")
    g.AddText("w140 yp Right", "Fully Opaque")

    slider.OnEvent("Change", (*) => UpdateLabel())
    UpdateLabel()
    {
        v   := slider.Value
        pct := Round((v / 255) * 100)
        lblPct.Value := pct . "%"
    }

    ; ── Quick presets ────────────────────────────────────────
    g.SetFont("s8 c0xA0A0C0", "Segoe UI")
    g.AddText("w300 y+14", "QUICK PRESETS")
    g.SetFont("s9 c0xFFFFFF", "Segoe UI")
    btn25  := g.AddButton("w66 y+6 Background0x2A2A3E", "25%")
    btn50  := g.AddButton("w66 x+6 yp Background0x2A2A3E", "50%")
    btn75  := g.AddButton("w66 x+6 yp Background0x2A2A3E", "75%")
    btn100 := g.AddButton("w66 x+6 yp Background0x2A2A3E", "100%")
    btn25.OnEvent("Click",  (*) => (slider.Value := 64,  UpdateLabel()))
    btn50.OnEvent("Click",  (*) => (slider.Value := 128, UpdateLabel()))
    btn75.OnEvent("Click",  (*) => (slider.Value := 191, UpdateLabel()))
    btn100.OnEvent("Click", (*) => (slider.Value := 255, UpdateLabel()))

    ; ── Divider ──────────────────────────────────────────────
    g.SetFont("s8 c0x404060", "Segoe UI")
    g.AddText("w300 y+14", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; ── Action buttons ───────────────────────────────────────
    g.SetFont("s10 Bold c0xFFFFFF", "Segoe UI")
    btnApply  := g.AddButton("w300 y+10 h34 Background0x0078D4", "✔  Apply Opacity")
    g.SetFont("s9 c0xFFFFFF", "Segoe UI")
    btnToggle := g.AddButton("w144 y+8 h30 Background0x" . (isOff ? "1A6B3A" : "6B1A1A"), isOff ? "✅  Enable Trans." : "❌  Disable Trans.")
    btnPin    := g.AddButton("w144 x+12 yp h30 Background0x" . (isPinned ? "5A4A00" : "1A3A2A"), isPinned ? "📌 Unpin Top" : "📌 Pin On Top")
    btnRemove := g.AddButton("w300 y+8 h28 Background0x3A2A1A", "🗑  Remove App from Tracking")

    ; ── Hotkey hint ──────────────────────────────────────────
    g.SetFont("s8 c0x505070", "Segoe UI")
    g.AddText("w300 y+14 Center", "Numpad +/−  adjust  |  *  reset  |  RClick  toggle  |  Space  pin")
    g.SetFont("s8 c0xFFD700", "Segoe UI")
    g.AddText("w300 y+6 Center", "⚡ GlazeWM mode: pin is actively re-enforced every 300ms")

    ; ── Events ───────────────────────────────────────────────
    btnApply.OnEvent("Click", ApplyClick)
    btnToggle.OnEvent("Click", ToggleClick)
    btnPin.OnEvent("Click", PinClick)
    btnRemove.OnEvent("Click", RemoveClick)
    g.OnEvent("Close", (*) => g.Destroy())

    ApplyClick(*)
    {
        newVal := slider.Value
        if (disabledApps.Has(lcProc))
            disabledApps.Delete(lcProc)
        SetAppTransparency(proc, newVal)
        ShowTip("✅ Applied: " . proc . "  →  " . Round((newVal / 255) * 100) . "%", 1400)
        g.Destroy()
    }

    ToggleClick(*)
    {
        ToggleApp(proc)
        g.Destroy()
    }

    PinClick(*)
    {
        TogglePin(wid, proc)
        g.Destroy()
    }

    RemoveClick(*)
    {
        DeleteSetting(proc)
        wins := WinGetList("ahk_exe " . proc)
        for , deadWid in wins
        {
            SafeSetTrans(deadWid, MAX_TRANS)
            if (pinnedWindows.Has(deadWid))
            {
                try WinSetAlwaysOnTop(0, "ahk_id " . deadWid)
                pinnedWindows.Delete(deadWid)
            }
        }
        SavePinnedApps()
        ShowTip("🗑 Removed: " . proc . "  →  fully opaque", 1500)
        g.Destroy()
    }

    g.Show("AutoSize Center")
}


