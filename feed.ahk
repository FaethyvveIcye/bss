;; Made by Lessy / Saber
Menu, Tray, Tip, Feed
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

; 50x Sunflower Seeds until gifted
$F1::
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\sunf.ico
	MouseGetPos, MouseX, MouseY
	Loop
	{
		If (BecameGifted())
			break

		ImageSearch, FoundX, FoundY, 0, 0, 150, A_ScreenHeight, *40 %A_ScriptDir%\images\sunflower_seed.png
		If (ErrorLevel != 0)
			break
		
		Feed(FoundX, FoundY, MouseX, MouseY)
	}
    Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
	MouseMove, MouseX, MouseY
	return
}

; 50x Strawberries until gifted
$F2::
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\strawberry.ico
	MouseGetPos, MouseX, MouseY
	Loop
	{
		If (BecameGifted())
			break

		ImageSearch, FoundX, FoundY, 0, 0, 150, A_ScreenHeight, *40 %A_ScriptDir%\images\strawberry.png
		If (ErrorLevel != 0)
			break
		
		Feed(FoundX, FoundY, MouseX, MouseY)
	}
    Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
	MouseMove, MouseX, MouseY
	return
}

; 50x Pineapples until gifted
$F3::
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\pineapple.ico
	MouseGetPos, MouseX, MouseY
	Loop
	{
		If (BecameGifted())
			break

		ImageSearch, FoundX, FoundY, 0, 0, 150, A_ScreenHeight, *40 %A_ScriptDir%\images\pineapple.png
		If (ErrorLevel != 0)
			break
		
		Feed(FoundX, FoundY, MouseX, MouseY)
	}
    Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
	MouseMove, MouseX, MouseY
	return
}

; 50x Blueberries until gifted
$F4::
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\pine.ico
	MouseGetPos, MouseX, MouseY
	Loop
	{
		If (BecameGifted())
			break

		ImageSearch, FoundX, FoundY, 0, 0, 150, A_ScreenHeight, *40 %A_ScriptDir%\images\blueberry.png
		If (ErrorLevel != 0)
			break
		
		Feed(FoundX, FoundY, MouseX, MouseY)
	}
    Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
	MouseMove, MouseX, MouseY
	return
}

; Bitterberries until BAR
$F5::
{
	/* TODO
	MouseGetPos, x, y
	MsgBox, % IsBarMutated(x, y)
	*/
}
