;; Made by Lessy / Saber
;; Place cursor on the hiveslot of the bee and have inventory open to show bitterberries & neonberries
Menu, Tray, Tip, Bitterberries
Menu, Tray, Icon, %A_ScriptDir%\icons\treat_bitterberry.ico
#MaxThreads, 8
#MaxMem, 256
#Include functions.ahk

q::	; Quit / Pause / Reload / Stop hotkey - "Q"
{
	Reload
	Return
}

b::	; Feed bitterberries until mutated hotkey - "B"
{
	FeedUntilMutated(20, 1000)
	Return
}

n::	; Feed a neonberry hotkey - "N"
{
	Menu, Tray, Icon, %A_ScriptDir%\icons\status\in-progress.ico
	MouseGetPos, hive_slot_x, hive_slot_y
	ImageSearch, neonberry_x, neonberry_y, 0, 0, 500, A_ScreenHeight, *90 %A_ScriptDir%\images\items\neonberry.png
	If (ErrorLevel == 0)
	{
		MouseClickDrag, Left, neonberry_x-50, neonberry_y+40, hive_slot_x, hive_slot_y
		Sleep, 1000
		ImageSearch, yes_x, yes_y, 0, 0, A_ScreenWidth, A_ScreenHeight, *30 %A_ScriptDir%\images\yes.png
		If (ErrorLevel == 0)
		{
			MouseClick, Left, yes_x, yes_y
			Menu, Tray, Icon, %A_ScriptDir%\icons\status\success.ico
			MouseMove, hive_slot_x, hive_slot_y
			Return
		}
	}
	Menu, Tray, Icon, %A_ScriptDir%\icons\status\failure.ico
	MouseMove, hive_slot_x, hive_slot_y
	Return
}

FeedUntilMutated(bitterberry_amount, delay_between_feeds)
{
	Menu, Tray, Icon, %A_ScriptDir%\icons\status\in-progress.ico
	is_mutated := False
	MouseGetPos, hive_slot_x, hive_slot_y
	ImageSearch, bee_ui_x, bee_ui_y, A_ScreenWidth*1/3, 0, A_ScreenWidth*2/3, A_ScreenHeight//2, *30 %A_ScriptDir%\images\bee_information_ui.png
	If (ErrorLevel == 0)
		MouseClick, Left, bee_ui_x, bee_ui_y

	Loop
	{
		ImageSearch, bitterberry_x, bitterberry_y, 0, 0, 500, A_ScreenHeight, *90 %A_ScriptDir%\images\items\bitterberry.png
		If (ErrorLevel == 0)
		{
			MouseClickDrag, Left, bitterberry_x-50, bitterberry_y+40, hive_slot_x, hive_slot_y
			Sleep, 500
			ImageSearch, feed_ui_x, feed_ui_y, A_ScreenWidth*1/3, A_ScreenHeight//2, A_ScreenWidth*2/3, A_ScreenHeight, *90 %A_ScriptDir%\images\feed_ui.png
			If (ErrorLevel == 0)
			{
				MouseClick, Left, feed_ui_x+200, feed_ui_y+20
				MouseClick, Left, feed_ui_x+200, feed_ui_y+20
				MouseClick, Left, feed_ui_x+200, feed_ui_y+20
				SendInput, %bitterberry_amount%
				Sleep, 100
				MouseClick, Left, feed_ui_x, feed_ui_y
				Sleep, %delay_between_feeds%
			} Else {
				Menu, Tray, Icon, %A_ScriptDir%\icons\status\failure.ico
				Break
			}
		} Else {
			Menu, Tray, Icon, %A_ScriptDir%\icons\status\failure.ico
			Break
		}
		ImageSearch, bee_ui_x, bee_ui_y, A_ScreenWidth*1/3, 0, A_ScreenWidth*2/3, A_ScreenHeight//2, *30 %A_ScriptDir%\images\bee_information_ui.png
		If (ErrorLevel == 0)
		{
			Menu, Tray, Icon, %A_ScriptDir%\icons\status\success.ico
			Break
		}
	}
	MouseMove, hive_slot_x, hive_slot_y
}
