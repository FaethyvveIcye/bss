;; Made by Lessy / Saber
Menu, Tray, Tip, BCA-Sunf
Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
#MaxThreads, 8
#MaxMem, 256
#Include functions.ahk

; "Pause" Hotkeys
$^q::          ; CTRL+Q
$^F11::        ; CTRL+F11
{
    Reload
    Return
}

; "Play" Hotkeys
$^p::         ; CTRL+P
$^F4::        ; CTRL+F4
Loop
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\handsome.ico
    ReconnectIfDisconnected()

    ResetCharacter()

	If (MinutesSince(balloon_cooldown) > 30)
		EmptyHiveBalloon()

    WealthClock()

    AntPass()

    Mondo()

    If (MinutesSince(bugrun_cooldown) > 30)
        BugRun()

    SunflowerField()
}
