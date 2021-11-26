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
    Menu, Tray, Icon, %A_ScriptDir%\icons\treat_sunflower_seed.ico
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
    Menu, Tray, Icon, %A_ScriptDir%\icons\treat_strawberry.ico
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
    Menu, Tray, Icon, %A_ScriptDir%\icons\treat_pineapple.ico
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
    Menu, Tray, Icon, %A_ScriptDir%\icons\treat_blueberry.ico
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

; Bitterberries until any Mutation
$F5::
{
	Menu, Tray, Icon, %A_ScriptDir%\icons\treat_bitterberry.ico
	MouseGetPos, MouseX, MouseY
	Loop
	{
		If (BecameGifted())
			break

		ImageSearch, FoundX, FoundY, 0, 0, 150, A_ScreenHeight, *40 %A_ScriptDir%\images\bitterberry.png
		If (ErrorLevel != 0)
			break
		
		Feed(FoundX, FoundY, MouseX, MouseY, 300, True)
	}
    Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
	MouseMove, MouseX, MouseY
	return
}

; Bitterberries until BAR
$F6::
{
	Menu, Tray, Icon, %A_ScriptDir%\icons\treat_bitterberry.ico
	MouseGetPos, MouseX, MouseY
	Loop
	{
		If (IsBarMutated(MouseX, MouseY))
			break

		ImageSearch, FoundX, FoundY, 0, 0, 150, A_ScreenHeight, *40 %A_ScriptDir%\images\bitterberry.png
		If (ErrorLevel != 0)
			break
		
		Feed(FoundX, FoundY, MouseX, MouseY, 300, True)
	}
    Menu, Tray, Icon, %A_ScriptDir%\icons\basic.ico
	MouseMove, MouseX, MouseY
	return
}
