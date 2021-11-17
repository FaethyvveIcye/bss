;; Made by Lessy / Saber
Menu, Tray, Tip, BCA-Sunf
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
Loop
{
	Menu, Tray, Icon, %A_ScriptDir%\icons\handsome.ico
	If !(IsConnected())
		Reconnect()

	ResetCharacter()

    WealthClock()

    AntPass()

	Mondo()

	If (MinutesSince(bugrun_cooldown) > 60)
		BugRun()

	Menu, Tray, Icon, %A_ScriptDir%\icons\sunf.ico
	FaceHive()
	KeyPress("d", 8000)
	RotateCamera(4)
	KeyPress("w", 4000)
	KeyPress("s", 100)
	Jump()
	KeyPress("w", 3200)
	RotateCamera(2)
	KeyPress("w", 300)
	ZoomOut(5)
	PlaceSprinklers()
	Click, Down				; collector
	KeyPress("a", 400)      ; initial movement to align snake
	KeyPress("s", 150)
	Loop, 20
	{
		Loop, 4
		{
			KeyPress("w", 300)
			KeyPress("d", 100)
			KeyPress("s", 300)
			KeyPress("d", 100)
		}
		If (IsBagFull())
			break
		Loop, 4
		{
			KeyPress("w", 300)
			KeyPress("a", 100)
			KeyPress("s", 300)
			KeyPress("a", 100)
		}
		If (IsBagFull())
			break
	}
	Click, Up				; collector
}
