;; Made by Lessy / Saber
Menu, Tray, Tip, Pine Balloon
Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
#MaxThreads, 8
#MaxMem, 256
#Include functions.ahk

; "Pause" Hotkeys
$^q::       ; CTRL+Q
$^F11::     ; CTRL+F11
{
    Reload
    Return
}

; "Play" Hotkeys
$^p::		; CTRL+P
$^F4::		; CTRL+F4
Loop
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\handsome.ico
    ReconnectIfDisconnected()
    
    If (MinutesSince(Cooldowns_balloon) >= 10)
        EmptyHiveBalloon()

    WealthClock()
    AntPass()
    
    Stockings()
    BeesmasFeast()
    Samovar()
    LidArt()
    HoneydayCandles()

    ManagePlanters()
    
    PolarRun()

    WindShrine()
    BlueFieldBooster()
    PineTreeForestTidePopper(110, True)
    ResetCharacter()
}
