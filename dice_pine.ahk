;; Made by Lessy / Saber
;; Example of how to maintain 4x on a field using only dice
Menu, Tray, Tip, Dice Pine
Menu, Tray, Icon, %A_ScriptDir%\icons\field_dice.ico
#MaxThreads, 8
#MaxMem, 256
#Include functions.ahk

; "Pause" Hotkeys
$^8::     ; CTRL+8
{
    Reload
    Return
}

; "Play" Hotkeys
$^7::		; CTRL+7
Loop
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\status\in-progress.ico
    Loop
    {
        desired_field_was_boosted := False
        KeyPress("2")
        Sleep, 1500
        Loop, 50
        {
            ImageSearch,,, A_ScreenWidth-500, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\dice_pine.png
            If (ErrorLevel == 0)
            {
                desired_field_was_boosted := True
                Break
            }
            Sleep, 20
        }
        If (desired_field_was_boosted)
            Break
    }
    Menu, Tray, Icon, %A_ScriptDir%\icons\field_dice.ico
    Sleep, 13 * 60 * 1000
}
