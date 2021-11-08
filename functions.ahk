;; Made by Lessy / Saber
global antpass_cooldown := 20211106000000
global wealthclock_cooldown := 20211106000000
global bugrun_cooldown := 20211106000000
global mondo_cooldown := 20211106000000

KeyPress(key, duration:=0)
{
    Send, {%key% down}
    Sleep, %duration%
    Send, {%key% up}
}

MinutesSince(previous_time)
{
    time_difference := A_NowUTC
    EnvSub, time_difference, previous_time, Minutes
    return time_difference
}

IsBagFull()
{
    ; PixelColor is F70017, but PixelSearch is unreliable
    ImageSearch, FoundX, FoundY, A_ScreenWidth//2, 0, A_ScreenWidth, A_ScreenHeight//4, *90 %A_ScriptDir%\images\bagfull.png
    return (ErrorLevel == 0)
}

RotateCamera(times:=1)
{
    Loop, %times%
    {
        KeyPress(",")
    }
}

ZoomOut(times:=1)
{
    Loop, %times%
    {
        KeyPress("o")
    }
}

Jump(duration:=100)
{
    Send, {Space down}
    Sleep, %duration%
    Send, {Space up}
}

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

PlaceSprinklers(SprinklerCount:=1)
{
    RemainingSprinklers := SprinklerCount
    Loop,
    {
        KeyPress("1")
        RemainingSprinklers--
        If (RemainingSprinklers < 1)
            break
        Sleep, 400
        Jump()
        Sleep, 800
    }
}

FaceHive()
{
    Loop
    {
        ; checks bottom-left quadrant of screen for sprinkler on hivecomb background
        ; for a full-screen check, change co-ordinates to: 0, 0, A_ScreenWidth, A_ScreenHeight
        ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\hivecomb.png
        RotateCamera(4)
        If (ErrorLevel == 0)
            break
        Sleep, 500
        If (A_Index > 10)
        {
            ResetCharacter()
            FaceHive()
            break
        }
    }
}

IsStuck()
{
    Loop, Files, %A_ScriptDir%\errors\shop_*.png
    {
        ; checks top-right quadrant of screen for honey cost of various shops interfaces
        ; for a full-screen check, change co-ordinates to: 0, 0, A_ScreenWidth, A_ScreenHeight
        ImageSearch, FoundX, FoundY, A_ScreenWidth//2, 0, A_ScreenWidth, A_ScreenHeight//2, *90 %A_LoopFileFullPath%
        If (ErrorLevel == 0)
            return true
    }
    return false
}

UnStick()
{
    Sleep, 100
    KeyPress("e")
    Sleep, 1000
}

; Task-Based Functions
WealthClock()
{
    If (MinutesSince(wealthclock_cooldown) < 60)
        return

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

AntPass()
{
    If (MinutesSince(antpass_cooldown) < 120)
        return

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

BugRun(slot:=3)
{
    FaceHive()
    RotateCamera(4)
    (%slot% < 3) ? KeyPress("d", (1225 * (3 - slot))) : KeyPress("a", (1225 * (slot - 3)))
    bugrun_cooldown := A_NowUTC

    Menu, Tray, Icon, %A_ScriptDir%\icons\mushroom.ico
    KeyPress("w", 10000)
	Click, Down         ; collector
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
	PlaceSprinklers(1)
    KeyPress("w", 1200)
    KeyPress("d", 2000)
    KeyPress("s", 1800)
    KeyPress("a", 900)
    Loop, 7
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
	PlaceSprinklers(1)
    Loop, 6
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
    KeyPress("d", 2500)
	PlaceSprinklers(1)
    KeyPress("d", 2500)
    KeyPress("a", 200)
    Send, {s down}{a down}
    Sleep, 1200
    Send, {s up}{a up}
    KeyPress("a", 1400)
    Menu, Tray, Icon, %A_ScriptDir%\icons\cactus.ico
    Loop, 6
    {
        Sleep, 500
        KeyPress("w", 500)
        KeyPress("d", 600)
        KeyPress("s", 300)
        KeyPress("a", 500)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\pumpkin.ico
    KeyPress("w", 4000)
    KeyPress("s", 300)
	PlaceSprinklers(1)
    Loop, 5
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
	PlaceSprinklers(1)
    Loop, 7
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
    Click, Up         ; collector
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
    PlaceSprinklers(1)
    KeyPress("s", 300)
    KeyPress("d", 2500)
    KeyPress("d", 1000)
    KeyPress("a", 1500)
    Menu, Tray, Icon, %A_ScriptDir%\icons\rose.ico
    Loop, 6
    {
        Sleep, 500
        KeyPress("w", 500)
        KeyPress("a", 500)
        KeyPress("s", 400)
        KeyPress("d", 400)
    }

    Menu, Tray, Icon, %A_ScriptDir%\icons\sunf.ico
    KeyPress("s", 2500)
    KeyPress("d", 6000)
    KeyPress("a", 3000)
    KeyPress("d", 300)
    Click, Down         ; collector
    PlaceSprinklers(1)
    Loop, 6
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
    Loop, 6
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
    Jump()
    KeyPress("d", 2000)
    Jump()
    KeyPress("d", 2500)
    Menu, Tray, Icon, %A_ScriptDir%\icons\vicious.ico
    PlaceSprinklers(1)
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
    PlaceSprinklers(1)
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
    Jump()
    KeyPress("w", 600)
    KeyPress("a", 500)
    KeyPress("w", 500)
    KeyPress("a", 500)
    KeyPress("w", 500)
    KeyPress("a", 500)
    KeyPress("w", 3500)
    KeyPress("s", 300)
    PlaceSprinklers(1)
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
    KeyPress("s", 3200)
    KeyPress("a", 100)
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
    Click, Up         ; collector
    If (IsStuck())
        UnStick()
    ResetCharacter()
}

Mondo()
{
    If (MinutesSince(mondo_cooldown) < 40)
        return

    FormatTime, CurrentMinute , A_NowUTC, m
    If (CurrentMinute > 13)
        return

    Menu, Tray, Icon, %A_ScriptDir%\icons\mondo.ico
    mondo_cooldown := A_NowUTC

    /*
    TODO: Code for Mondo goes here
    */

    ResetCharacter()
}
