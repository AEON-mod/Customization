#Requires AutoHotkey v2.0
#SingleInstance Force

; --- AUTO-ADMINISTRATOR ---
if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; --- SETTINGS ---
T := 400 
SwipeDist := 50 

; --- LEFT CLICK: PASTE ---
~LButton:: {
    if (A_PriorHotkey = "~LButton" and A_TimeSincePriorHotkey < T) {
        Send "^v"
    }
}

; --- THE MASTER RBUTTON HANDLER ---
RButton:: {
    static rClicks := 0
    MouseGetPos(&x1, &y1)
    Start := A_TickCount
    
    ; 1. SNIPPING TOOL vs CLIPBOARD HISTORY
    if GetKeyState("LButton", "P") {
        timedOut := !KeyWait("RButton", "T0.3") 
        if (timedOut)
            Send "#+s"
        else
            Send "#v"
        KeyWait "RButton" 
        return
    }

    KeyWait "RButton"
    Duration := A_TickCount - Start
    MouseGetPos(&x2, &y2)
    
    ; 2. SWIPE LOGIC
    distX := x2 - x1
    if (Abs(distX) > SwipeDist) {
        if (distX > 0)
            Send "!{Right}"
        else
            Send "!{Left}"
        rClicks := 0
        return
    }

    ; 3. MULTI-CLICK LOGIC (Logic overhaul for Select All)
    if (A_PriorHotkey = "RButton" and A_TimeSincePriorHotkey < T)
        rClicks++
    else
        rClicks := 1

    if (rClicks = 1) {
        ; Wait to see if a second click follows
        SetTimer(CheckMultiClick, -250) 
    }
    
    CheckMultiClick() {
        if (rClicks = 2) {
            ; Wait to see if a third click follows
            SetTimer(CheckTripleClick, -200)
        } else if (rClicks = 1) {
            ; Only a single click happened
            if (Duration < 300)
                Click "Right"
        }
    }

    CheckTripleClick() {
        if (rClicks = 3) {
            ; SUCCESS: Select All
            Send "^{a}"
            rClicks := 0
        } else {
            ; Only two clicks happened: Copy
            Send "^{c}"
            rClicks := 0
        }
    }
}

; --- TOP EDGE: TAB OVERVIEW ---
SetTimer(CheckTopEdge, 100)
CheckTopEdge() {
    static HoverStart := 0
    MouseGetPos(, &y)
    if (y <= 1) {
        if (HoverStart = 0) 
            HoverStart := A_TickCount
        else if (A_TickCount - HoverStart > 1000) {
            Send "#{Tab}"
            HoverStart := 0
            Sleep 1500 
        }
    } else {
        HoverStart := 0
    }
}