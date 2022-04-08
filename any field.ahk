;; Made by Lessy / Saber
Menu, Tray, Tip, Any Field
Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
#MaxThreads, 8
#MaxMem, 256
#Include functions.ahk

; "Pause" Hotkeys
$^q::		; CTRL+Q
$^F11::		; CTRL+F11
{
	Reload
	Return
}

; "Play" Hotkeys
$^p::		; CTRL+P
$^F4::		; CTRL+F4
{
	Menu, Tray, Icon, %A_ScriptDir%\icons\status\in-progress.ico
	GatherFieldPollen(False, 300, 100, 99999, 3)
	Menu, Tray, Icon, %A_ScriptDir%\icons\status\success.ico
}
