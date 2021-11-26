;; Made by Lessy / Saber
Menu, Tray, Tip, Boost Helpers
Menu, Tray, Icon, %A_ScriptDir%\icons\boost_off.ico
#MaxThreads, 8
#MaxMem, 256
#Include functions.ahk
global use_gumdrops := true  ; slot2
global use_clouds := true    ; slot4
global use_jb := true  ; slot5

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
	Menu, Tray, Icon, %A_ScriptDir%\icons\boost_on.ico
	Loop
	{
		If (use_gumdrops)
			KeyPress("2")
		If (use_clouds)
			KeyPress("4")
		If (use_jb)
			KeyPress("5")
		Sleep, 50
	}
	Return
}
