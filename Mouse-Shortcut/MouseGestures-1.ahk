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

; --- THE "IGNORE" REGION ---
; This ensures X1 and X2 (and their variations) are passed 
; directly to Windows without any delay or blocking.
~*XButton1::return
~*XButton2::return
~*MButton::return ; Added Middle Click to the ignore list just in case

; --- LEFT CLICK: TRIPLE CLICK PASTE ---
~LButton:: {
    static lClicks := 0
    if (A_PriorHotkey = "~LButton" and A_TimeSincePriorHotkey < T)
        lClicks++
    else
        lClicks := 1

    if (lClicks = 3) {
        Send "^v" 
        lClicks := 0
    }
}

; --- THE MASTER RBUTTON HANDLER ---
RButton:: {
    static rClicks := 0
    MouseGetPos(&x1, &y1)
    Start := A_TickCount
    
    ; 1. SNIPPING TOOL & CLIPBOARD (Hold Left, then Right)
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

    ; 3. MULTI-CLICK LOGIC
    if (A_PriorHotkey = "RButton" and A_TimeSincePriorHotkey < T)
        rClicks++
    else
        rClicks := 1

    if (rClicks = 1) {
        SetTimer(CheckMultiClick, -250) 
    }
    
    CheckMultiClick() {
        if (rClicks = 2) {
            SetTimer(CheckTripleClick, -200)
        } else if (rClicks = 1) {
            if (Duration < 300)
                Click "Right"
        }
    }

    CheckTripleClick() {
        if (rClicks = 3) {
            Send "{Ctrl down}a{Ctrl up}"
            rClicks := 0
        } else {
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

; --- KILL SWITCH ---
+Esc::ExitApp() ; Shift + Escape to close