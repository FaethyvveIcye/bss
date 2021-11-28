;; Made by Lessy / Saber
#Include config.ahk

; Helper function to press a given key for a duration, similar to the JitBit function of the same name
KeyPress(key, duration:=0)
{

    Send, {%key% down}
    Sleep, (duration * movespeed_factor)
    Send, {%key% up}
}

; Helper function to assist in adding timers to different activities
SecondsSince(previous_time)
{
    time_difference := A_NowUTC
    EnvSub, time_difference, previous_time, Seconds
    Return time_difference
}

; Helper function to assist in adding timers to different activities
MinutesSince(previous_time)
{
    time_difference := A_NowUTC
    EnvSub, time_difference, previous_time, Minutes
    Return time_difference
}

; Helper function that checks if you are connected to the game by seeing if your sprinklers on hotkey #1 are visible or not
IsConnected()
{
    ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *40 %A_ScriptDir%\images\reconnect_sprinkler.png
    Return (ErrorLevel == 0)
}

; Helper function that claims a hive slot after reconnecting to the provided (or default) URL by launching it in your default web browser
Reconnect()
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\connection_problems.ico

    Run, %VIP_to_reconnect_to%

    wealthclock_cooldown := A_NowUTC
    FormatTime, CurrentMinute, A_NowUTC, m
    If (CurrentMinute < 16)
        mondo_cooldown := A_NowUTC

    Sleep, (seconds_to_wait_on_reconnect * 1000)

    If !(IsConnected())
        Return Reconnect()

    KeyPress("w", 5000)
    KeyPress("s", 800)
    (hive_slot < 3) ? KeyPress("d", (1200 * (3 - hive_slot))) : KeyPress("a", (1200 * (hive_slot - 3)))
    Loop, 5
    {
        KeyPress("e")
    }
    MouseMove, A_ScreenWidth//2, A_ScreenHeight//2
    ResetCharacter()
    Return
}

; Reconnects to the VIP provided in `config` if disconnected
ReconnectIfDisconnected()
{
    If !(IsConnected())
        Reconnect()
}

; Helper function to check if a bee has a BAR mutation, not fully implemented
IsBarMutated(x, y)
{
    ImageSearch, FoundX, FoundY, x-5, y-5, x+5, y+5, %A_ScriptDir%\images\BAR.png
    Return (ErrorLevel == 0)
}

; Helper function to feed 50 fruits to a given bee
Feed(x1, y1, x2, y2, delay:=300, only_1_treat:=false)
{
    MouseClickDrag, Left, x1, y1, x2, y2
    Loop, 5
    {
        Sleep, 100
        If (only_1_treat)
        {
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *40 %A_ScriptDir%\images\feed_1.png
        } Else {
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *40 %A_ScriptDir%\images\feed_50.png
        }
        If (ErrorLevel == 0)
        {
            MouseClick, Left, FoundX, FoundY
            Sleep, delay
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
PlaceSprinklers()
{
    RemainingSprinklers := sprinkler_amount
    Loop
    {
        KeyPress("1")
        RemainingSprinklers--
        Sleep, 800
        If (RemainingSprinklers < 1)
            break
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
        If (A_Index > 7)
        {
            ResetCharacter()
            Return
        }
    }
    RotateCamera(4)
}

; Walks from the initial hiveslot to a new slot
MoveToSlot(new_slot)
{
    (hive_slot < new_slot) ? KeyPress("d", (1200 * (new_slot - hive_slot))) : KeyPress("a", (1200 * (hive_slot - new_slot)))
}

; Helper function that hecks to see if you're stuck in a shop / dispenser
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

; Helper function that presses "E" to get out of a shop that you might be stuck in, then waits a little
UnStick()
{
    Sleep, 100
    KeyPress("e")
    Sleep, 1000
}

; Closes out of any shops or dispensers that you may be stuck in
UnStickIfStuck()
{
    If (IsStuck())
        UnStick()
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
    Sleep, 500
    Jump(100)
    KeyPress("w", 1000)
    Send, {d down}
    Sleep, 4000 * movespeed_factor
    Jump()
    Sleep, 2000 * movespeed_factor
    Jump()
    Sleep, 2000 * movespeed_factor
    Send, {d up}
    KeyPress("s", 2000)
    KeyPress("d", 3000)
    KeyPress("w", 500)
    KeyPress("d", 600)
    Sleep, 100
    Send, {d down}
    Sleep, 3000 * movespeed_factor
    Jump()
    Sleep, 1500 * movespeed_factor
    Jump()
    Sleep, 1000 * movespeed_factor
    Send, {d up}
    Sleep, 100
    Send, {w down}
    Sleep, 1100 * movespeed_factor
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
    Sleep, 500
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
    UnStickIfStuck()
    ResetCharacter()
}

; Enough Jump Power & Movement Speed required (gummy boots / clogs / mountaintop)
; Too many haste token bees / bear bee can cause runs where bugs or fields are missed
; Walks in a pattern conducive to activating vicious spikes in applicable fields
; Grabs some pollen in Polar Bear's quest fields on the way through & turns in Polar quests
; Paths inspired by e_IoI (mush-spider-straw-cactus-pumpkin-pine-polar-rose-sunf-dand-clover-bluf-bamboo-pineapple)
; Does a bug run starting from any slot
BugRun()
{
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    bugrun_cooldown := A_NowUTC

    Menu, Tray, Icon, %A_ScriptDir%\icons\mushroom.ico
    KeyPress("w", 10000)
    KeyPress("s", 100)
	PlaceSprinklers()
    Loop, 4
    {
        Sleep, 100
        KeyPress("s", 900)
        KeyPress("d", 200)
        KeyPress("w", 1000)
        KeyPress("a", 200)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\spider.ico
    Sleep, 500
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
    ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *5 %A_ScriptDir%\images\cavemonster_cave.png
    If (ErrorLevel == 0)
    {
        KeyPress("a", 4000)
    } Else {
        KeyPress("a", 200)
        Send, {s down}{a down}
        Sleep, 1200 * movespeed_factor
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
	PlaceSprinklers()
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
    KeyPress("w", 200)
    Jump()
    KeyPress("w", 8000)
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
    PlaceSprinklers()
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
    PlaceSprinklers()
    Loop, 5
    {
        Sleep, 100
        KeyPress("a", 600)
        KeyPress("s", 100)
        KeyPress("d", 500)
        KeyPress("w", 100)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\clover.ico
    KeyPress("d", 2500)
    KeyPress("w", 500)
    KeyPress("s", 10)
    Sleep, 500
    Jump()
    KeyPress("d", 3000)
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
    KeyPress("w", 2500)
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
    PlaceSprinklers()
    Loop, 6
    {
        Sleep, 100
        KeyPress("a", 600)
        KeyPress("s", 800)
        KeyPress("d", 800)
        KeyPress("w", 600)
    }
    UnStickIfStuck()
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

    ResetCharacter()    ; extra reset prevents bear morph reset glitches
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
			KeyPress("a", 700)
            KeyPress("w", 500)
			Loop, 5
			{
				Loop, 4
				{
					KeyPress("s", 1300)
					KeyPress("a", 200)
					KeyPress("w", 1300)
					KeyPress("a", 200)
				}
				Loop, 4
				{
					KeyPress("s", 1300)
					KeyPress("d", 200)
					KeyPress("w", 1300)
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

    UnStickIfStuck()
    ResetCharacter()
}

; Navigates to, and AFKs in, the ant challenge
AntChallenge()
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\ant.ico
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
    Sleep, 500
    Jump()
    KeyPress("w", 2100)
    KeyPress("a", 8000)
    RotateCamera(7)
	KeyPress("w", 2900)
	KeyPress("d", 200)
    RotateCamera(1)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 1000
    KeyPress("s", 1500)
    KeyPress("w", 100)
    KeyPress("d", 100)
    PlaceSprinklers()
    Click, Down
    Sleep, 5 * 60 * 1000
    Click, Up
    ResetCharacter()
    Sleep, 8000
    UnStickIfStuck()
}

; Places sprinklers then snakes the field for pollen, optionally stopping if bag is full
GatherFieldPollen(stop_on_full_bag:=True, vertical_length:=300, horizontal_length:=100, field_loops:=20, snakes:=4, inch_forwards:=False, inch_left:=False, inch_right:=False, inch_backwards:=False)
{
    PlaceSprinklers()
    Sleep, 500
    ImageSearch, SprinklerX, SprinklerY, A_ScreenWidth//2, A_ScreenHeight//4, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\errors\you_must_be_standing_in_a_field_to_build_a_Sprinkler.png
    If (ErrorLevel == 0)
        Return

    Click, Down
    KeyPress("a", horizontal_length*snakes)
    KeyPress("s", vertical_length/2)
    Loop, %field_loops%
    {
        ; right movement
        Loop, %snakes%
        {
            KeyPress("w", (inch_forwards ? vertical_length*1.03 : vertical_length))
            KeyPress("d", (inch_right ? horizontal_length*1.03 : horizontal_length))
            KeyPress("s", (inch_backwards ? vertical_length*1.03 : vertical_length))
            KeyPress("d", (inch_right ? horizontal_length*1.03 : horizontal_length))
        }
        If (stop_on_full_bag && IsBagFull())
            break

        ; left movement
        Loop, %snakes%
        {
            KeyPress("w", (inch_forwards ? vertical_length*1.03 : vertical_length))
            KeyPress("a", (inch_left ? horizontal_length*1.03 : horizontal_length))
            KeyPress("s", (inch_backwards ? vertical_length*1.03 : vertical_length))
            KeyPress("a", (inch_left ? horizontal_length*1.03 : horizontal_length))
        }
        If (stop_on_full_bag && IsBagFull())
            break

    }
    Click, Up
}

; Navigates to, and farms in, the bamboo field
BambooField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\bamboo.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 10000)
	Jump()
    KeyPress("w", 4000)
    KeyPress("d", 9500)
    KeyPress("w", 1300)
    ZoomOut(5)
    GatherFieldPollen(True, 650, 125, field_loops, 2, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the blue flower field
BlueFlowerField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\bluf.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 5750)
    KeyPress("d", 5500)
    KeyPress("w", 2300)
    KeyPress("d", 5200)
    KeyPress("w", 1000)
    ZoomOut(5)
    GatherFieldPollen(True, 650, 125, field_loops, 2, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the cactus field
CactusField(field_loops:=20)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\cactus.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 10000)
	Jump()
    KeyPress("w", 1500)
    KeyPress("a", 4700)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1700)
    KeyPress("w", 6100)
    KeyPress("d", 2500)
    KeyPress("s", 400)
    ZoomOut(5)
    RotateCamera(4)
    GatherFieldPollen(True, 300, 100, field_loops)
    UnStickIfStuck()
}

; Navigates to, and farms in, the clover field
CloverField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\clover.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 5750)
    KeyPress("d", 7000)
    KeyPress("w", 500)
    Sleep, 500
    Jump()
    KeyPress("d", 2000)
    Sleep, 500
    Jump()
    KeyPress("d", 2000)
    KeyPress("s", 1000)
    RotateCamera(4)
    ZoomOut(5)
    GatherFieldPollen(True, 350, 110, field_loops, 3)
    UnStickIfStuck()
}

; Navigates to, and farms in, the coconut field
CoconutField(field_loops:=20)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\coconut.ico
    FaceHive()
	KeyPress("d", 6969)
	KeyPress("w", 1000)
    Jump()
    KeyPress("d", 4000)
    Jump()
    KeyPress("d", 1000)
    KeyPress("w", 1000)
    Jump()
    KeyPress("w", 3000)
    Loop, 3
    {
        Jump()
        KeyPress("w", 1000)
    }
    KeyPress("w", 1000)
    KeyPress("a", 1000)
    RotateCamera(6)
    ZoomOut(5)
    GatherFieldPollen(True, 600, 110, field_loops, 2, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the dandelion field
DandelionField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\dandelion.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(5.5)
    KeyPress("w", 4000)
    ZoomOut(5)
    GatherFieldPollen(True, 300, 100, field_loops)
    UnStickIfStuck()
}

; Navigates to, and farms in, the mountain top field
MountainTopField(field_loops:=20)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\mountain.ico
    FaceHive()
	KeyPress("d", 6969)
	KeyPress("w", 1000)
    Sleep, 6969
    Jump()
    KeyPress("d", 1500)
    Loop, 5
    {
        KeyPress("e")
    }
	ZoomOut(5)
	Sleep, 2500
	KeyPress("w", 700)
    RotateCamera(6)
    GatherFieldPollen(True, 300, 110, field_loops, 4)
    UnStickIfStuck()
}

; Navigates to, and farms in, the mushroom field
MushroomField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\mushroom.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 7777)
    KeyPress("d", 777)
    ZoomOut(5)
    GatherFieldPollen(True, 300, 100, field_loops)
    UnStickIfStuck()
}

; Navigates to, and farms in, the pepper patch
PepperPatch(field_loops:=20)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\pepper.ico
    FaceHive()
	KeyPress("d", 6969)
	KeyPress("w", 1000)
    Jump()
    KeyPress("d", 4000)
    Jump()
    KeyPress("d", 1000)
    KeyPress("w", 1000)
    Jump()
    KeyPress("w", 3000)
    Loop, 3
    {
        Jump()
        KeyPress("w", 1000)
    }
    KeyPress("w", 1000)
    Jump()
    KeyPress("w", 4500)
    Sleep, 500
    Jump()
    KeyPress("d", 4000)
    Sleep, 500
    Jump()
    KeyPress("d", 1500)
    KeyPress("s", 500)
    RotateCamera(6)
    ZoomOut(5)
    GatherFieldPollen(True, 300, 110, field_loops)
    UnStickIfStuck()
}

; Navigates to, and farms in, the pine tree forest
PineTreeForest(field_loops:=35)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\pine.ico
    FaceHive()
	KeyPress("d", 6969)
	KeyPress("w", 1000)
    Sleep, 6969
    Jump()
    KeyPress("d", 1500)
    RotateCamera(6)
    Loop, 5
    {
        KeyPress("e")
    }
	ZoomOut(5)
	Sleep, 2500
	KeyPress("d", 1000)
	Send, {Space down}
	KeyPress("w", 18000)
	Send, {Space up}
    Sleep, 500
	KeyPress("a", 1337)
	KeyPress("s", 420*2)
    GatherFieldPollen(True, 650, 125, field_loops, 2, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the pineapple patch
PineapplePatch(field_loops:=25)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\pineapple.ico
    FaceHive()
	KeyPress("d", 6969)
	KeyPress("w", 1000)
    Sleep, 6969
    Jump()
    KeyPress("d", 1500)
    RotateCamera(2)
    ZoomOut(5)
    Loop, 5
    {
        KeyPress("e")
    }
	Sleep, 2500
    KeyPress("w", 4500)
    RotateCamera(2)
    KeyPress("w", 1600)
    GatherFieldPollen(True, 600, 120, field_loops, 2, True, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the pumpkin patch
PumpkinPatch(field_loops:=20)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\pumpkin.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 10000)
	Jump()
    KeyPress("w", 888)
    KeyPress("a", 4700)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1700)
    KeyPress("w", 6100)
    KeyPress("d", 2300)
    KeyPress("w", 3200)
    ZoomOut(5)
    GatherFieldPollen(True, 500, 120, field_loops, 3, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the rose field
RoseField(field_loops:=20)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\rose.ico
    FaceHive()
	KeyPress("d", 6969)
	RotateCamera(4)
	KeyPress("w", 4000)
	KeyPress("s", 100)
    Sleep, 500
	Jump()
	KeyPress("w", 3200)
	RotateCamera(2)
	KeyPress("w", 2000)
    Jump()
    KeyPress("w", 1200)
    KeyPress("d", 2100)
    RotateCamera(4)
	ZoomOut(5)
    GatherFieldPollen(True, 600, 110, field_loops, 2, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the spider field
SpiderField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\spider.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 10000)
	Jump()
    KeyPress("w", 4000)
    KeyPress("d", 2600)
    KeyPress("w", 1300)
	ZoomOut(5)
    GatherFieldPollen(True, 650, 125, field_loops, 2, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the strawberry field
StrawberryField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\strawberry.ico
    ResetCharacter()
    FaceHive()
    RotateCamera(4)
    MoveToSlot(3)
    KeyPress("w", 10000)
	Jump()
    KeyPress("w", 4000)
    KeyPress("a", 4000)
    ZoomOut(5)
    RotateCamera(2)
    GatherFieldPollen(True, 650, 125, field_loops, 2, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the stump field
StumpField(field_loops:=25)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\stump.ico
    FaceHive()
	KeyPress("d", 6969)
	KeyPress("w", 1000)
    Jump()
    KeyPress("d", 1500)
    RotateCamera(2)
    ZoomOut(5)
    Loop, 5
    {
        KeyPress("e")
    }
	Sleep, 2500
    KeyPress("w", 12750)
	Keypress("d", 500)
    Sleep, 500
    GatherFieldPollen(True, 300, 100, field_loops, 3)
    UnStickIfStuck()
}

; Navigates to, and farms in, the sunflower field
SunflowerField(field_loops:=30)
{
    Menu, Tray, Icon, %A_ScriptDir%\icons\sunf.ico
    FaceHive()
	KeyPress("d", 6969)
	RotateCamera(4)
	KeyPress("w", 4000)
	KeyPress("s", 100)
    Sleep, 500
	Jump()
	KeyPress("w", 3200)
	RotateCamera(2)
	KeyPress("w", 300)
	ZoomOut(5)
    GatherFieldPollen(True, 300, 100, field_loops)
    UnStickIfStuck()
}
