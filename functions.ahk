;; Made by Lessy / Saber
; Default Timestamps, do not change these
global antpass_cooldown := 20211106000000
global wealthclock_cooldown := 20211106000000
global bugrun_cooldown := 20211106000000
global mondo_cooldown := 20211106000000

; Helper function to press a given key for a duration, similar to the JitBit function of the same name
KeyPress(key, duration:=0)
{
    Send, {%key% down}
    Sleep, %duration%
    Send, {%key% up}
}

; Helper function to assist in adding timers to different activities
MinutesSince(previous_time)
{
    time_difference := A_NowUTC
    EnvSub, time_difference, previous_time, Minutes
    Return time_difference
}

; Checks if you are connected to the game by seeing if your sprinklers on hotkey #1 are visible or not
IsConnected()
{
    ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *40 %A_ScriptDir%\images\reconnect_sprinkler.png
    Return (ErrorLevel == 0)
}

; Claims a hive slot after reconnecting to the provided (or default) URL by launching it in your default web browser
Reconnect(slot:=3, URL:="https://www.roblox.com/games/1537690962?privateServerLinkCode=5086103223819209066184150466573")
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\connection_problems.ico

    Run, %URL%
    Sleep, 2 * 60 * 1000

    If !(IsConnected())
        Return Reconnect(slot, URL)

    KeyPress("w", 5000)
    KeyPress("s", 800)
    (slot < 3) ? KeyPress("d", (1225 * (3 - slot))) : KeyPress("a", (1225 * (slot - 3)))
    Loop, 5
    {
        KeyPress("e")
    }
    MouseMove, A_ScreenWidth//2, A_ScreenHeight//2
    ResetCharacter()
    Return
}

; Helper function to check if a bee has a BAR mutation, not fully implemented
IsBarMutated(x, y)
{
    ImageSearch, FoundX, FoundY, x-5, y-5, x+5, y+5, %A_ScriptDir%\images\BAR.png
    Return (ErrorLevel == 0)
}

; Helper function to feed 50 fruits to a given bee
Feed(x1, y1, x2, y2)
{
    MouseClickDrag, Left, x1, y1, x2, y2
    Loop, 5
    {
        Sleep, 100
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *40 %A_ScriptDir%\images\feed_50.png
        If (ErrorLevel == 0)
        {
            MouseClick, Left, FoundX, FoundY
            break
        }
    }
}

; Checks the screen to see if the "Your bee became gifted!" popup happened
BecameGifted()
{
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *40 %A_ScriptDir%\images\gifted_success.png
    Return (ErrorLevel == 0)
}

; Checks to see if your bag is full
IsBagFull()
{
    ; PixelColor is F70017, but PixelSearch is unreliable
    ImageSearch, FoundX, FoundY, A_ScreenWidth//2, 0, A_ScreenWidth, A_ScreenHeight//4, *90 %A_ScriptDir%\images\bagfull.png
    Return (ErrorLevel == 0)
}

; Rotates the camera one (or more) times
RotateCamera(times:=1)
{
    Loop, %times%
    {
        KeyPress(",")
    }
}

; Zooms out one (or more) times
ZoomOut(times:=1)
{
    Loop, %times%
    {
        KeyPress("o")
    }
}

; Presses the jump key, releasing it momentarily (or longer after)
Jump(duration:=100)
{
    Send, {Space down}
    Sleep, %duration%
    Send, {Space up}
}

; Resets your character one (or more) times
ResetCharacter(times:=1)
{
    Loop, %times%
    {
        Send, {Escape}
        Sleep, 200
        Send, r
        Sleep, 200
        Send, {Enter}
        Sleep, 9500
    }
}

; Places down your sprinklers, jump-glitching to place more if needed
PlaceSprinklers(SprinklerCount:=1)
{
    RemainingSprinklers := SprinklerCount
    Loop,
    {
        KeyPress("1")
        RemainingSprinklers--
        If (RemainingSprinklers < 1)
            break
        Sleep, 700
        Jump()
        Sleep, 700
    }
}

; Rotates the camera to face your hive (ie. looking at all your bees)
FaceHive()
{
    Loop
    {
        ; checks bottom-left quadrant of screen for sprinkler on hivecomb background
        ; for a full-screen check, change co-ordinates to: 0, 0, A_ScreenWidth, A_ScreenHeight
        ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\hivecomb.png
        If (ErrorLevel == 0)
            break
        
        ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\hivecomb2.png
        If (ErrorLevel == 0)
            break
        
        ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\hivecomb3.png
        If (ErrorLevel == 0)
            break
        
        RotateCamera(4)
        Sleep, 1000
        If (A_Index > 6)
        {
            ResetCharacter()
            Return
        }
    }
    RotateCamera(4)
}

; Checks to see if you're stuck in a shop / dispenser
IsStuck()
{
    Loop, Files, %A_ScriptDir%\errors\shop_*.png
    {
        ; checks top-right quadrant of screen for honey cost of various shops interfaces
        ; for a full-screen check, change co-ordinates to: 0, 0, A_ScreenWidth, A_ScreenHeight
        ImageSearch, FoundX, FoundY, A_ScreenWidth//2, 0, A_ScreenWidth, A_ScreenHeight//2, *90 %A_LoopFileFullPath%
        If (ErrorLevel == 0)
            Return true
    }
    Return false
}

; Presses "E" to get out of a shop that you might be stuck in, then waits a little
UnStick()
{
    Sleep, 100
    KeyPress("e")
    Sleep, 1000
}

; Grabs wealth clock, then resets, skipping if on cooldown automatically
WealthClock()
{
    If (MinutesSince(wealthclock_cooldown) < 60)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\clock.ico
    wealthclock_cooldown := A_NowUTC
    FaceHive()
    RotateCamera(4)
    Sleep, 500
    KeyPress("s", 100)
    KeyPress("s", 700)
    KeyPress("d", 100)
    KeyPress("d", 10000)
    KeyPress("w", 100)
    KeyPress("w", 4000)
    KeyPress("s", 100)
    Jump(100)
    KeyPress("w", 1000)
    Send, {d down}
    Sleep, 2000
    Jump()
    Sleep, 2000
    Jump()
    Sleep, 2000
    Send, {d up}
    KeyPress("s", 2000)
    KeyPress("d", 3000)
    KeyPress("w", 500)
    KeyPress("d", 600)
    Sleep, 100
    Send, {d down}
    Sleep, 3000
    Jump()
    Sleep, 1500
    Jump()
    Sleep, 1000
    Send, {d up}
    Sleep, 100
    Send, {w down}
    Sleep, 1100
    Jump()
    Loop, 50
    {
        KeyPress("e", 50)
    }
    Send, {w up}
    ResetCharacter()
}

; Grabs ant pass, then resets, skipping if on cooldown automatically
AntPass()
{
    If (MinutesSince(antpass_cooldown) < 120)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\ant.ico
    antpass_cooldown := A_NowUTC
    FaceHive()
    KeyPress("w", 100)
    KeyPress("w", 700)
    KeyPress("a", 100)
    KeyPress("a", 8000)
    KeyPress("w", 100)
    KeyPress("w", 400)
    Jump()
    KeyPress("w", 1000)
    Jump()
    KeyPress("w", 1000)
    KeyPress("d", 100)
    KeyPress("d", 2000)
    KeyPress("w", 1500)
    KeyPress("s", 400)
    KeyPress("a", 400)
    Jump()
    KeyPress("w", 2100)
    KeyPress("a", 8000)
    KeyPress("d", 300)
    Loop, 5
    {
        KeyPress("d", 100)
        KeyPress("e")
    }
    Sleep, 1000
    If (IsStuck())
        UnStick()
    ResetCharacter()
}

; Enough Jump Power & Movement Speed required (gummy boots / clogs / maybe mountaintop)
; Gifted hasty / too many haste token bees / bear bee can cause runs where bugs or fields are missed
; Walks in a pattern conducive to activating vicious spikes in applicable fields
; Grabs some pollen in Polar Bear's quest fields on the way through & turns in Polar quests
; Paths inspired by e_IoI (mush-spider-straw-cactus-pumpkin-pine-polar-rose-sunf-dand-clover-bluf-bamboo-pineapple)
; Does a bug run starting from any slot
BugRun(slot:=3)
{
    FaceHive()
    RotateCamera(4)
    (slot < 3) ? KeyPress("d", (1225 * (3 - slot))) : KeyPress("a", (1225 * (slot - 3)))
    bugrun_cooldown := A_NowUTC

    Menu, Tray, Icon, %A_ScriptDir%\icons\mushroom.ico
    KeyPress("w", 10000)
    KeyPress("s", 100)
	PlaceSprinklers(1)
    Loop, 4
    {
        Sleep, 100
        KeyPress("s", 900)
        KeyPress("d", 200)
        KeyPress("w", 1000)
        KeyPress("a", 200)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\spider.ico
    Jump()
    KeyPress("w", 4400)
    KeyPress("d", 1600)
    KeyPress("w", 1200)
    KeyPress("d", 2000)
    KeyPress("s", 1800)
    KeyPress("a", 900)
    Loop, 6
    {
        Sleep, 500
        KeyPress("w", 600)
        KeyPress("a", 600)
        KeyPress("s", 400)
        KeyPress("d", 500)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\strawberry.ico
    KeyPress("w", 2500)
    KeyPress("a", 2000)
    Jump()
    KeyPress("a", 3000)
    Jump()
    KeyPress("a", 3000)
    KeyPress("s", 1000)
    Loop, 5
    {
        Sleep, 100
        KeyPress("d", 800)
        KeyPress("w", 700)
        KeyPress("a", 700)
        KeyPress("s", 800)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\cactus.ico
    KeyPress("a", 1000)
    KeyPress("s", 3500)
    Jump()
    KeyPress("a", 1700)
    KeyPress("w", 6100)
    Menu, Tray, Icon, %A_ScriptDir%\icons\vicious.ico
    KeyPress("d", 5000)
    
    ; Walking out of the cave monsters' cave if necessary
    ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\cavemonster_cave.png
    If (ErrorLevel == 0)
    {
        KeyPress("a", 5000)
    } Else {
        KeyPress("a", 200)
        Send, {s down}{a down}
        Sleep, 1200
        Send, {s up}{a up}
        KeyPress("a", 1400)
        Menu, Tray, Icon, %A_ScriptDir%\icons\cactus.ico
        Loop, 5
        {
            Sleep, 500
            KeyPress("w", 500)
            KeyPress("d", 600)
            KeyPress("s", 300)
            KeyPress("a", 500)
        }
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\pumpkin.ico
    KeyPress("w", 4000)
    KeyPress("s", 300)
	PlaceSprinklers(1)
    Loop, 4
    {
        Sleep, 100
        KeyPress("a", 400)
        KeyPress("s", 400)
        KeyPress("d", 500)
        KeyPress("w", 500)
    }
    Sleep, 2000

    Menu, Tray, Icon, %A_ScriptDir%\icons\pine.ico
    KeyPress("a", 3000)
    Jump()
    KeyPress("a", 4000)
    KeyPress("d", 200)
    Loop, 6
    {
        Sleep, 100
        KeyPress("w", 500)
        KeyPress("d", 600)
        KeyPress("s", 600)
        KeyPress("a", 500)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\polar.ico
    KeyPress("w", 1000)
    KeyPress("d", 12000)
    KeyPress("s", 9000)
    KeyPress("a", 1200)
    RotateCamera(7)
    KeyPress("w", 400)
    RotateCamera(1)
    Loop
    {
        Loop, 3
        {
            Sleep, 1000
            KeyPress("e", 1000)
            Sleep, 1000
            Loop, 10
            {
                Click, Left
                Sleep, 100
            }
        }
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\errors\dialogue_polar.png
        If (ErrorLevel == 0)
        {
            MouseMove, FoundX, FoundY
        } else {
            break
        }
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\rose.ico
    RotateCamera(3)
    KeyPress("w", 600)
    Jump()
    KeyPress("w", 400)
    Jump()
    KeyPress("w", 6000)
    RotateCamera(5)
    KeyPress("a", 1500)
    Menu, Tray, Icon, %A_ScriptDir%\icons\vicious.ico
    KeyPress("d", 1000)
    KeyPress("w", 2300)
    KeyPress("s", 300)
    KeyPress("d", 2500)
    KeyPress("d", 1000)
    KeyPress("a", 1500)
    Menu, Tray, Icon, %A_ScriptDir%\icons\rose.ico
    Loop, 6
    {
        Sleep, 500
        KeyPress("s", 500)
        KeyPress("a", 500)
        KeyPress("w", 400)
        KeyPress("d", 400)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\sunf.ico
    KeyPress("s", 2500)
    KeyPress("d", 6000)
    KeyPress("a", 3000)
    KeyPress("d", 300)
    PlaceSprinklers(1)
    Loop, 5
    {
        Sleep, 100
        KeyPress("d", 600)
        KeyPress("s", 100)
        KeyPress("a", 600)
        KeyPress("w", 100)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\dandelion.ico
    KeyPress("d", 13000)
    KeyPress("a", 300)
    KeyPress("s", 800)
    KeyPress("a", 1000)
    PlaceSprinklers(1)
    Loop, 5
    {
        Sleep, 100
        KeyPress("a", 600)
        KeyPress("s", 100)
        KeyPress("d", 500)
        KeyPress("w", 100)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\clover.ico
    KeyPress("d", 2000)
    KeyPress("w", 1500)
    Sleep, 500
    Jump()
    KeyPress("d", 2000)
    Sleep, 500
    Jump()
    KeyPress("d", 2500)
    Menu, Tray, Icon, %A_ScriptDir%\icons\vicious.ico
    KeyPress("s", 1800)
    KeyPress("a", 1000)
    Loop, 5
    {
        Sleep, 500
        KeyPress("w", 500)
        KeyPress("d", 600)
        KeyPress("s", 600)
        KeyPress("a", 500)
    }
    
    Menu, Tray, Icon, %A_ScriptDir%\icons\bluf.ico
    KeyPress("w", 5000)
    KeyPress("s", 200)
    Loop, 5
    {
        Sleep, 100
        KeyPress("a", 600)
        KeyPress("s", 700)
        KeyPress("d", 500)
        KeyPress("w", 500)
    }
    
    Menu, Tray, Icon, %A_ScriptDir%\icons\bamboo.ico
    KeyPress("w", 1500)
    KeyPress("d", 5500)
    KeyPress("a", 1200)
    Sleep, 500
    Jump()
    KeyPress("w", 600)
    KeyPress("a", 500)
    KeyPress("w", 500)
    KeyPress("a", 500)
    KeyPress("w", 500)
    KeyPress("a", 500)
    KeyPress("w", 4500)
    KeyPress("s", 300)
    Loop, 6
    {
        Sleep, 100
        KeyPress("a", 600)
        KeyPress("s", 500)
        KeyPress("d", 500)
        KeyPress("w", 700)
    }
    
    Menu, Tray, Icon, %A_ScriptDir%\icons\pineapple.ico
    KeyPress("w", 1500)
    KeyPress("d", 6000)
    Jump(21000)         ; allows haste to expire & prevents new token generation
    KeyPress("s", 3500)
    KeyPress("a", 50)
    Sleep, 500
    Jump()
    KeyPress("d", 1500)
    KeyPress("w", 10000)
    KeyPress("s", 300)
    PlaceSprinklers(1)
    Loop, 6
    {
        Sleep, 100
        KeyPress("a", 600)
        KeyPress("s", 800)
        KeyPress("d", 800)
        KeyPress("w", 600)
    }
    If (IsStuck())
        UnStick()
    ResetCharacter()
}


; Automatically skips if it's not time for Mondo or it's already dead
; MAKE SURE YOUR COMPUTER CLOCK IS SET PROPERLY
; Kills Mondo chick & loots the items
Mondo()
{
    If (MinutesSince(mondo_cooldown) < 40)
        Return

    FormatTime, CurrentMinute, A_NowUTC, m
    If (CurrentMinute >= 14)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\mondo.ico
    mondo_cooldown := A_NowUTC

    FaceHive()
    KeyPress("d", 8000)
    KeyPress("w", 1000)
    Jump()
    KeyPress("d", 1500)
    Loop, 5
    {
        KeyPress("e")
    }
	ZoomOut(5)
	Sleep, 2200
	KeyPress("w", 3200)
	RotateCamera(2)

    ClickedChatOff := False
    ImageSearch, ChatX, ChatY, 0, 0, 200, 200, *90 %A_ScriptDir%\images\chat_active.png
    If (ErrorLevel == 0)
    {
        MouseMove, ChatX, ChatY
        Click, Down
        Click, Up
        ClickedChatOff = True
        MouseMove, A_ScreenWidth//2, A_ScreenHeight//2
    }

	Loop
	{
		/*
		TODO: add additional death checks to ensure stability if grabbing tokens
		Loop, 4
		{
			Sleep, 2800
			KeyPress("a", 350)
			Sleep, 350
			KeyPress("d", 500)
		}
		*/
		Sleep, 5000
		ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, 120, *40 %A_ScriptDir%\images\mondobuff.png
		If (ErrorLevel == 0)
		{
			; loot
			KeyPress("a", 500)
            KeyPress("w", 500)
			Loop, 6
			{
				Loop, 4
				{
					KeyPress("s", 1200)
					KeyPress("a", 200)
					KeyPress("w", 1200)
					KeyPress("a", 200)
				}
				Loop, 4
				{
					KeyPress("s", 1200)
					KeyPress("d", 200)
					KeyPress("w", 1200)
					KeyPress("d", 200)
				}
			}
			break
		}
		FormatTime, CurrentMinute, A_NowUTC, m
		If (CurrentMinute >= 15)
			break
	}

    If (ClickedChatOff) {
        MouseMove, ChatX, ChatY
        Click, Down
        Click, Up
        MouseMove, A_ScreenWidth//2, A_ScreenHeight//2
    }

    If (IsStuck())
        UnStick()
    ResetCharacter()
}
