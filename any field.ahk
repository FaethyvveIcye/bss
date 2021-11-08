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
	; change tray icon to indicate playback
	Menu, Tray, Icon, %A_ScriptDir%\icons\handsome.ico

	Click, Down				; collector
	PlaceSprinklers(1)

	; initial movement to align macro
	KeyPress("a", 400)
	KeyPress("s", 150)

	; field gather
	Loop
	{
		Loop, 4
		{
			KeyPress("w", 300)
			KeyPress("d", 100)
			KeyPress("s", 300)
			KeyPress("d", 100)
		}
		
		Loop, 4
		{
			KeyPress("w", 300)
			KeyPress("a", 100)
			KeyPress("s", 300)
			KeyPress("a", 100)
		}
	}
}
