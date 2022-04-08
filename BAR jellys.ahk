;; Made by Lessy / Saber
Menu, Tray, Tip, BAR jellys
Menu, Tray, Icon, %A_ScriptDir%\icons\treat_bitterberry.ico
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
;; Place cursor on the level of the bee and have the "user another royal jelly" menu open already
$^p::		; CTRL+P
$^F4::		; CTRL+F4
{
	Menu, Tray, Icon, %A_ScriptDir%\icons\status\in-progress.ico
	RollUntilBar(800)
}

RollUntilBar(delay_between_rolls)
{
	is_bar_bee := False
	MouseGetPos, level_x, level_y
	Loop
	{
		ImageSearch, use_rj_x, use_rj_y, 0, 0, A_ScreenWidth, A_ScreenHeight, *30 %A_ScriptDir%\images\use_another_rj.png
		If (ErrorLevel == 0)
		{
			MouseClick, Left, use_rj_x+50, use_rj_y+10
			MouseMove, use_rj_x+50, use_rj_y-40
			Sleep, delay_between_rolls
		} Else {
			Menu, Tray, Icon, %A_ScriptDir%\icons\status\failure.ico
			Break
		}

		ImageSearch,,, level_x-10, level_y-10, level_x+10, level_y+10, *30 %A_ScriptDir%\images\BAR.png
		If (ErrorLevel == 0)
		{
			Menu, Tray, Icon, %A_ScriptDir%\icons\status\success.ico
			Break
		}
		
		ImageSearch,,, level_x-10, level_y-10, level_x+10, level_y+10, *30 %A_ScriptDir%\images\no_mutation.png
		If (ErrorLevel == 0)
		{
			Menu, Tray, Icon, %A_ScriptDir%\icons\status\failure.ico
			Break
		}
	}
	MouseMove, level_x, level_y
}
