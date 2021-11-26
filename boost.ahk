;; Made by Lessy / Saber
Menu, Tray, Tip, Boost
Menu, Tray, Icon, %A_ScriptDir%\icons\boost_off.ico
#MaxThreads, 8
#MaxMem, 256
#Include functions.ahk
global use_clouds := true    ; slot1
global use_gumdrops := true  ; slot2
global use_coconuts := true  ; slot3
global use_stingers := true  ; slot4
global last_stinger := 20211106000000

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
		If (use_clouds)
			KeyPress("1")
		If (use_gumdrops)
			KeyPress("2")
		If (use_coconuts)
			KeyPress("3")
		If (use_stingers && (SecondsSince(last_stinger) >= 10))
		{
			KeyPress("4")
			last_stinger := A_NowUTC
		}
		Sleep, 50
	}
	Return
}
