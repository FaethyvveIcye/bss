;; Made by Lessy / Saber
#Include configuration.ahk
If (GetConfigVersion() != 1)
{
    MsgBox, Your config.ini file is out of date, please press "OK" then run "reset config.ahk"
    ExitApp
}
UpdateGlobalsFromIni()
ReleaseHeldKeysAndMouse()

; Helper function to press a given key for a duration, similar to the JitBit function of the same name
KeyPress(key, duration:=0)
{

    Send, {%key% down}
    Sleep, (duration * Stats_movespeed_factor)
    Send, {%key% up}
}

; Releases any potentially unreleased keys or clicks
ReleaseHeldKeysAndMouse()
{
    Click, Up
    For each, key in ["w","a","s","d", "space"]
        Send, {%key% up}
}

; Helper function to assist in adding timers to different activities
SecondsSince(previous_time)
{
    UpdateIniFromGlobals()
    time_difference := A_NowUTC
    EnvSub, time_difference, previous_time, Seconds
    Return time_difference
}

; Helper function to assist in adding timers to different activities
MinutesSince(previous_time)
{
    UpdateIniFromGlobals()
    time_difference := A_NowUTC
    EnvSub, time_difference, previous_time, Minutes
    Return time_difference
}

; Harvests the specified planter from the field it's currently in, returning True if the planter is ready to be re-placed, and False otherwise
HarvestPlanter(planter_number)
{
    For each, field in Planters_planter%planter_number%_fields
    {
        If (field == Planters_planter%planter_number%_current_field)
        {
            ; cooldown isn't up yet, skip harvesting
            If (MinutesSince(Cooldowns_planter%planter_number%) < Planters_planter%planter_number%_reuse_time[each])
                Return False

            current_planter := Planters_planter%planter_number%
            Menu, Tray, Icon, %A_ScriptDir%\icons\planter_%current_planter%.ico
            ResetCharacter(3)
            %field%(0)  ; dynamically calling the field macro with 0 field loops to navigate to the field
            Loop, 5
            {
                KeyPress("e", 200)
            }
            Sleep, 1000
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\planter_still_growing.png
            If (ErrorLevel == 0)
            {
                MouseGetPos, MouseX, MouseY
                MouseMove, FoundX, FoundY
                Sleep, 1000
                Click, Left
                MouseMove, MouseX, MouseY
                Cooldowns_planter%planter_number% := A_NowUTC
                EnvSub, Cooldowns_planter%planter_number%, Planters_planter%planter_number%_reuse_time[each], Minutes
                EnvAdd, Cooldowns_planter%planter_number%, 15, Minutes
                UpdateIniFromGlobals()
                Return False
            } Else {
                to_return := True
                If (Planters_planter%planter_number%_fields.Length() == 1)
                {
                    KeyPress(Hotkeys_planter%planter_number%)
                    Planters_planter%planter_number%_current_field := field
                    Cooldowns_planter%planter_number% := A_NowUTC
                    UpdateIniFromGlobals()
                    to_return := False
                }
                ; Planters_planter#_current_field should continue to store the last planter for referencing where to place it next until it is placed
                KeyPress("a", 600)
                KeyPress("s", 100)
                Sleep, 100
                CircleForLoot(11)
                Return to_return
            }
        }
    }
    ; planter is in an unregistered field or it's nowhere, assuming inventory
    Planters_planter%planter_number%_current_field := "nowhere"
    UpdateIniFromGlobals()
    Return True
}

; Places down the specified planter in the next field it should go in
PlacePlanter(planter_number)
{
    field_to_place_the_planter_in := Planters_planter%planter_number%_fields[1]
    For each, field in Planters_planter%planter_number%_fields
    {
        If (field == Planters_planter%planter_number%_current_field)  ; this was the previous field
        {
            If (Planters_planter%planter_number%_fields.Length() > each)
                field_to_place_the_planter_in := Planters_planter%planter_number%_fields[each+1]
            Break
        }
    }
    current_planter := Planters_planter%planter_number%
    Menu, Tray, Icon, %A_ScriptDir%\icons\planter_%current_planter%.ico
    ResetCharacter(3)
    %field_to_place_the_planter_in%(0)    ; we are once again dynamically calling the field macro with 0 field loops to navigate to the field
    KeyPress(Hotkeys_planter%planter_number%)
    Planters_planter%planter_number%_current_field := field_to_place_the_planter_in
    Cooldowns_planter%planter_number% := A_NowUTC
    UpdateIniFromGlobals()
    Return True
}

; Harvests any ready planter, replanting them in the appropriate fields
ManagePlanters()
{
    ReconnectIfDisconnected()

    If (HarvestPlanter(1))
        PlacePlanter(1)

    If (HarvestPlanter(2))
        PlacePlanter(2)

    If (HarvestPlanter(3))
        PlacePlanter(3)
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

    Run, %Stats_VIP_to_reconnect_to%

    Cooldowns_wealthclock := A_NowUTC
    FormatTime, CurrentMinute, A_NowUTC, m
    If (CurrentMinute < 16)
    {
        Cooldowns_mondo := A_NowUTC
    }
    EnvAdd, Cooldowns_planter1, Stats_seconds_to_wait_on_reconnect, Seconds
    EnvAdd, Cooldowns_planter2, Stats_seconds_to_wait_on_reconnect, Seconds
    EnvAdd, Cooldowns_planter3, Stats_seconds_to_wait_on_reconnect, Seconds
    UpdateIniFromGlobals()

    Sleep, (Stats_seconds_to_wait_on_reconnect * 1000)

    If !(IsConnected())
        Return Reconnect()

    ; Rotating camera if we spawned in backwards, because apparently that's a thing now
    ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\reconnect_hiveblock.png
    If (ErrorLevel != 0) {
        RotateCamera(4)
        Sleep, 1000
        ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\reconnect_hiveblock.png
        If (ErrorLevel != 0) {
            Return Reconnect()
        }
    }

    KeyPress("w", 5000)
    KeyPress("s", 800)
    (Stats_hive_slot < 3) ? KeyPress("d", (1200 * (3 - Stats_hive_slot))) : KeyPress("a", (1200 * (Stats_hive_slot - 3)))
    Loop, 5
    {
        KeyPress("e")
    }
    MouseMove, A_ScreenWidth//2, A_ScreenHeight//2
    ResetCharacter()
    Return
}

; Reconnects to the VIP provided in `config.ini` if disconnected
ReconnectIfDisconnected()
{
    If !(IsConnected())
        Return Reconnect()
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
    RemainingSprinklers := Stats_sprinkler_amount
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
FaceHive(should_face_hive:=true)
{
    Loop, 4
    {
        Loop, 7
        {
            ; checks bottom-left quadrant of screen for sprinkler on hivecomb background
            ; for a full-screen check, change co-ordinates to: 0, 0, A_ScreenWidth, A_ScreenHeight
            ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\hivecomb.png
            If (ErrorLevel == 0)
            {
                If(should_face_hive)
                    RotateCamera(4)
                Return
            }
            
            /*
            ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\hivecomb2.png
            If (ErrorLevel == 0)
                break
            
            ImageSearch, FoundX, FoundY, 0, A_ScreenHeight//2, A_ScreenWidth//2, A_ScreenHeight, *90 %A_ScriptDir%\images\hivecomb3.png
            If (ErrorLevel == 0)
                break
            */
            
            RotateCamera(4)
            Sleep, 1000
        }
        ResetCharacter()
    }
    ; Client crashed or frozen
    Reconnect()
}

; Walks from the initial hiveslot to a new slot, assuming facing away from the hive
MoveToSlot(new_slot)
{
    distance_between_slots := 1200
    (Stats_hive_slot < new_slot) ? KeyPress("d", (distance_between_slots * (new_slot - Stats_hive_slot))) : KeyPress("a", (distance_between_slots * (Stats_hive_slot - new_slot)))
}

; Helper function that checks to see if you're stuck in a shop / dispenser
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

; Helper function that presses "E" to get out of a shop that you might be stuck in, then waits for the shop UI to close
UnStick()
{
    Sleep, 100
    KeyPress("e")
    Sleep, 1000
    If (IsStuck())
        Reconnect()
}

; Closes out of any shops or dispensers that you may be stuck in
UnStickIfStuck()
{
    If (IsStuck())
        UnStick()
}

; Empties the hive balloon - does not reset your character first
EmptyHiveBalloon(reset_after_emptying:=false)
{
    If (MinutesSince(Cooldowns_balloon) < 5)
        Return

    If (MinutesSince(Cooldowns_whirligig) > 1)
        FaceHive()

    Menu, Tray, Icon, %A_ScriptDir%\icons\balloon.ico
    ImageSearch, FoundX, FoundY, A_ScreenWidth//3, 0, A_ScreenWidth, A_ScreenHeight//3, *90 %A_ScriptDir%\images\can_make_honey_from_balloon.png
    If (ErrorLevel != 0)
        Return

    KeyPress("e")
    Cooldowns_balloon := A_NowUTC
    UpdateIniFromGlobals()
    Loop, 600
    {
        Sleep, 1000
        ImageSearch, FoundX, FoundY, A_ScreenWidth//3, 0, A_ScreenWidth, A_ScreenHeight//3, *90 %A_ScriptDir%\images\making_honey_from_balloon.png
        If (ErrorLevel != 0)
            Break
    }

    If (reset_after_emptying)
        ResetCharacter()
}

; Uses a Whirligig or resets if it's on cooldown
WhirligigOrReset(camera_rotations:=0)
{
    If (MinutesSince(Cooldowns_whirligig) > 5)
    {
        KeyPress(Hotkeys_whirligig)
        Cooldowns_whirligig := A_NowUTC
        UpdateIniFromGlobals()
        RotateCamera(camera_rotations)
        Sleep, 1000
    } Else {
        ResetCharacter()
    }
}

CircleForLoot(circles:=5, repeats:=0)
{
    loot_movement_amount := 100
    Loop, %circles%
    {
        KeyPress("w", loot_movement_amount/2)
        KeyPress("d", loot_movement_amount)
        KeyPress("s", loot_movement_amount)
        KeyPress("a", loot_movement_amount)
        KeyPress("w", loot_movement_amount/2)
        loot_movement_amount += 100
    }
    If (repeats > 0)
    {
        Loop, %circles%
        {
            loot_movement_amount -= 100
            KeyPress("w", loot_movement_amount/2)
            KeyPress("d", loot_movement_amount)
            KeyPress("s", loot_movement_amount)
            KeyPress("a", loot_movement_amount)
            KeyPress("w", loot_movement_amount/2)
        }
        new_repeats := repeats - 1
        CircleForLoot(circles, new_repeats)
    }
}

; Grabs wealth clock during Beesmas, then resets, skipping if on cooldown automatically
WealthClock()
{
    If (MinutesSince(Cooldowns_wealthclock) < 60)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\clock.ico

    ResetCharacter(3)    ; extra resets prevent haste problems & bear morph reset glitches
    FaceHive(false)
    Sleep, 500
    MoveToSlot(5.5)
    KeyPress("w", 5000)
    RotateCamera(6)
    Sleep, 500
    Send, {w down}
    Jump(17000*Stats_movespeed_factor)
    Send, {w up}
    Sleep, 1000
    Loop, 20
    {
        KeyPress("e", 50)
    }
    Cooldowns_wealthclock := A_NowUTC
    UpdateIniFromGlobals()
    ResetCharacter()
}

/* Non-Beesmas Pathing
; Grabs wealth clock, then resets, skipping if on cooldown automatically
WealthClock()
{
    If (MinutesSince(Cooldowns_wealthclock) < 60)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\clock.ico
    FaceHive(false)
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
    Sleep, 4000 * Stats_movespeed_factor
    Jump()
    Sleep, 2000 * Stats_movespeed_factor
    Jump()
    Sleep, 2000 * Stats_movespeed_factor
    Send, {d up}
    KeyPress("s", 2000)
    KeyPress("d", 3000)
    KeyPress("w", 500)
    KeyPress("d", 600)
    Sleep, 100
    Send, {d down}
    Sleep, 3000 * Stats_movespeed_factor
    Jump()
    Sleep, 1500 * Stats_movespeed_factor
    Jump()
    Sleep, 1000 * Stats_movespeed_factor
    Send, {d up}
    Sleep, 100
    Send, {w down}
    Sleep, 1100 * Stats_movespeed_factor
    Jump()
    Loop, 50
    {
        KeyPress("e", 50)
    }
    Cooldowns_wealthclock := A_NowUTC
    UpdateIniFromGlobals()
    Send, {w up}
    ResetCharacter()
}
*/

; Grabs ant pass, then resets, skipping if on cooldown automatically
AntPass()
{
    If (MinutesSince(Cooldowns_antpass) < 120)
        Return

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
    KeyPress("d", 300)
    Loop, 5
    {
        KeyPress("d", 100)
        KeyPress("e")
    }
    Cooldowns_antpass := A_NowUTC
    UpdateIniFromGlobals()
    Sleep, 1000
    UnStickIfStuck()
    ResetCharacter()
}

; Plays Memory Match - not yet impelmented
MemoryMatch()
{
    ; 5.1 Memory Match          2 hours
    ; 5.2 Mega Memory Match     4 hours
    ; 5.3 Night Memory Match    8 hours - only at night
    ; 5.4 Extreme Memory Match  8 hours
    ; 5.5 Winter Memory Match   4 hours
}

; Enough Jump Power required (gummy boots / clogs / mountaintop)
; Too many haste token bees / bear bee can cause runs where bugs or fields are missed
; Walks in a pattern conducive to activating vicious spikes in applicable fields
; Grabs some pollen in Polar Bear's quest fields on the way through & turns in Polar quests
; Paths inspired by e_IoI (mush-spider-straw-cactus-pumpkin-pine-polar-rose-sunf-dand-clover-bluf-bamboo-pineapple)
; Does a bug run starting from any slot
BugRun()
{
    FaceHive(false)
    MoveToSlot(3)
    Cooldowns_bugrun := A_NowUTC
    UpdateIniFromGlobals()

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
        Sleep, 1200 * Stats_movespeed_factor
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
    KeyPress("w", 2000)
    KeyPress("d", 12000)
    KeyPress("s", 6969)
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
    KeyPress("w", 100)
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
    If (MinutesSince(Cooldowns_mondo) < 40)
        Return

    FormatTime, CurrentMinute, A_NowUTC, m
    If (CurrentMinute >= 14)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\mondo.ico
    Cooldowns_mondo := A_NowUTC
    UpdateIniFromGlobals()

    ResetCharacter(2)    ; extra resets prevent bear morph reset glitches
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

; Navigates to and activates the Blue Field Booster in Blue HQ
BlueFieldBooster()
{
    If (MinutesSince(Cooldowns_blue_field_booster) < 60)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\blue_field_booster.ico
    ResetCharacter(2)
    FaceHive(false)
    MoveToSlot(3)
    KeyPress("w", 5750)
    KeyPress("d", 5500)
    KeyPress("w", 2300)
    KeyPress("d", 11000)
    Sleep, 100
    Jump()
    KeyPress("d", 500)
    KeyPress("s", 1500)
    KeyPress("a", 3200)
    KeyPress("w", 2200)
    Loop, 5
    {
        KeyPress("e", 50)
    }
    Cooldowns_blue_field_booster := A_NowUTC
    UpdateIniFromGlobals()
}

; Navigates to and activates the Red Field Booster in Red HQ
RedFieldBooster()
{
    If (MinutesSince(Cooldowns_red_field_booster) < 60)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\red_field_booster.ico
    ResetCharacter(2)
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("w", 4000)
    KeyPress("s", 100)
    Sleep, 100
    Jump()
    KeyPress("w", 1000)
    RotateCamera(2)
    KeyPress("w", 2000)
    KeyPress("a", 1000)
    KeyPress("d", 1000)
    KeyPress("s", 100)
    Sleep, 100
    Jump()
    KeyPress("w", 2500)
    KeyPress("a", 1000)
    Loop, 5
    {
        KeyPress("e", 50)
    }
    Cooldowns_red_field_booster := A_NowUTC
    UpdateIniFromGlobals()
}


; Navigates to and donates to the Wind Shrine - item_index is how many times to click the right-arrow (ie. to switch to donating gumdrops)
WindShrine(item_index:=0, item_amount:=1)
{
    If (MinutesSince(Cooldowns_wind_shrine) < 60)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\windy_bee.ico
    ResetCharacter(2)
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Sleep, 100
    Jump()
    KeyPress("a", 4000)
    Sleep, 100
    Jump()
    KeyPress("a", 1000)
    KeyPress("s", 1000)
    Sleep, 100
    Jump()
    KeyPress("s", 3000)
    Loop, 3
    {
        Jump()
        KeyPress("s", 1000)
    }
    KeyPress("s", 1000)
    Sleep, 100
    Jump()
    KeyPress("s", 4500)
    Sleep, 100
    Jump()
    KeyPress("a", 4000)
    Sleep, 100
    Jump()
    KeyPress("a", 4000)
    KeyPress("w", 3000)
    KeyPress("d", 2000)
    Sleep, 100
    KeyPress("s", 300)
    Sleep, 100
    Jump()
    KeyPress("w", 1500)
    Jump()
    KeyPress("w", 600)
    Sleep, 1000
    ; Donation
    KeyPress("e", 50)
    MouseGetPos, MouseOriginalX, MouseOriginalY
    MouseMove, 100, 100
    Sleep, 1000
    FoundXDialogue := 100
    FoundYDialogue := 100
    ImageSearch, FoundXDialogue, FoundYDialogue, 0, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\wind_shrine_dialogue.png
    If (ErrorLevel != 0)
    {
        ImageSearch, FoundXDialogue, FoundYDialogue, 0, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\wind_shrine_offering.png
        If (ErrorLevel != 0)
            Return
    }
    MouseMove, FoundXDialogue, FoundYDialogue
    Click, Left
    Sleep, 500
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\wind_shrine_next_item.png
    If (ErrorLevel != 0)
        Return
    MouseMove, FoundX, FoundY
    Loop, %item_index%
    {
        Click, Left
        Sleep, 200
    }
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\wind_shrine_increment.png
    If (ErrorLevel != 0)
        Return
    MouseMove, FoundX, FoundY
    Loop, (%item_amount% - 1)
    {
        Click, Left
        Sleep, 200
    }
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\images\wind_shrine_donate.png
    If (ErrorLevel != 0)
        Return
    MouseMove, FoundX, FoundY
    Click, Left
    Cooldowns_wind_shrine := A_NowUTC
    UpdateIniFromGlobals()
    Sleep, 500
    MouseMove, FoundXDialogue, FoundYDialogue
    Loop, 10
    {
        Click, Left
        Sleep, 200
    }
    MouseMove, MouseOriginalX, MouseOriginalY
    ; Token collection
    wind_shrine_collection_movement_amount := 400
    Loop, 2
    {
        KeyPress("w", wind_shrine_collection_movement_amount * 2)
        KeyPress("d", wind_shrine_collection_movement_amount)
        KeyPress("s", wind_shrine_collection_movement_amount / 2)
        KeyPress("d", wind_shrine_collection_movement_amount / 2)
        KeyPress("s", wind_shrine_collection_movement_amount / 2)
        KeyPress("d", wind_shrine_collection_movement_amount / 2)
        KeyPress("s", wind_shrine_collection_movement_amount * 2)
        KeyPress("a", wind_shrine_collection_movement_amount / 2)
        KeyPress("s", wind_shrine_collection_movement_amount / 2)
        KeyPress("a", wind_shrine_collection_movement_amount / 2)
        KeyPress("s", wind_shrine_collection_movement_amount / 2)
        KeyPress("a", wind_shrine_collection_movement_amount)
        Sleep, 100
        Jump()
        KeyPress("w", wind_shrine_collection_movement_amount * 2)
        Sleep, 1000
        wind_shrine_collection_movement_amount -= 100
    }
}

; Navigates to, checks inside, and collects the items from, Brown Bear's Stockings
Stockings()
{
    If (MinutesSince(Cooldowns_stockings) < 60)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\brown_bear.ico
    ResetCharacter(3)
    FaceHive(false)
    Sleep, 500
    MoveToSlot(5.5)
    KeyPress("w", 4000)
    RotateCamera(6)
    Sleep, 500
    KeyPress("w", 6000)
    Sleep, 100
    Jump()
    KeyPress("w", 5000)
    KeyPress("d", 500)
    Loop, 5
    {
        KeyPress("e", 50)
    }
    Cooldowns_stockings := A_NowUTC
    UpdateIniFromGlobals()
    KeyPress("w", 1000)
    KeyPress("d", 350)
    KeyPress("s", 1500)
}

; Navigates to, digs in to, and collects the yummies from, Polar Bear's Beesmas Feast
BeesmasFeast()
{
    If (MinutesSince(Cooldowns_beesmas_feast) < 90)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\polar_bear.ico
    ResetCharacter(3)
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 700
    Jump()
    Jump()
    Sleep, 3500
    Keypress("a", 5500)
    KeyPress("w", 500)
    Keypress("d", 150)
    KeyPress("s", 100)
    Sleep, 100
    Jump()
    KeyPress("w", 900)
    Loop, 5
    {
        KeyPress("e", 50)
    }
    Cooldowns_beesmas_feast := A_NowUTC
    UpdateIniFromGlobals()
    Sleep, 1500
    CircleForLoot()
}

; Navigates to, heats up, and collects the loot from, Dapper Bear's Samovar
Samovar()
{
    If (MinutesSince(Cooldowns_samovar) < 360)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\dapper_bear.ico
    ResetCharacter(2)
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    RotateCamera(6)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 2500
    KeyPress("w", 12400)
    RotateCamera(2)
    KeyPress("w", 4000)
    KeyPress("s", 100)
    Sleep, 100
    Jump()
    KeyPress("w", 2000)
    KeyPress("s", 100)
    RotateCamera(7)
    Sleep, 100
    Jump()
    KeyPress("a", 775)
    KeyPress("s", 100)
    Sleep, 100
    Jump()
    KeyPress("w", 950)
    Loop, 5
    {
        KeyPress("e", 50)
    }
    Cooldowns_samovar := A_NowUTC
    UpdateIniFromGlobals()
    Sleep, 3000
    CircleForLoot(7)
}

; Navigates to, ganders at, and collects the goodies from, Onett's Lid Art
LidArt()
{
    If (MinutesSince(Cooldowns_lid_art) < 480)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\onett.ico
    ResetCharacter(3)
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 2500
    KeyPress("w", 2000)
    KeyPress("a", 2500)
    KeyPress("d", 475)
    KeyPress("w", 7000)
    Sleep, 100
    Jump()
    KeyPress("w", 4000)
    Sleep, 100
    Jump()
    KeyPress("w", 300)
    Sleep, 1000
    Loop, 5
    {
        KeyPress("e", 50)
    }
    Cooldowns_lid_art := A_NowUTC
    UpdateIniFromGlobals()
    Sleep, 3000
    KeyPress("a", 200)
    CircleForLoot(7)
}

; Navigates to, admires, and collects the wax from, Riley Bee's Honeyday Candles
HoneydayCandles()
{
    If (MinutesSince(Cooldowns_honeyday_candles) < 240)
        Return

    Menu, Tray, Icon, %A_ScriptDir%\icons\riley.ico
    ResetCharacter(2)
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("w", 4000)
    KeyPress("s", 100)
    Sleep, 100
    Jump()
    KeyPress("w", 1000)
    RotateCamera(2)
    KeyPress("w", 2000)
    KeyPress("a", 1000)
    KeyPress("d", 1000)
    KeyPress("s", 100)
    Sleep, 100
    Jump()
    KeyPress("w", 4200)
    KeyPress("a", 3350)
    KeyPress("w", 2000)
    Loop, 5
    {
        KeyPress("e", 50)
    }
    Cooldowns_honeyday_candles := A_NowUTC
    UpdateIniFromGlobals()
    Sleep, 5000
    RotateCamera(4)
    CircleForLoot()
}

; Places sprinklers then snakes the field for pollen, optionally stopping if bag is full, realigning against the walls
GatherFieldPollen(stop_on_full_bag:=True, vertical_length:=300, horizontal_length:=100, field_loops:=20, snakes:=4, front_wall:=False, left_wall:=False, right_wall:=False, back_wall:=False, realign_distance:=400, realign_frequency:=5)
{
    If (%field_loops% == 0)
        Return

    PlaceSprinklers()
    Sleep, 500
    ImageSearch, SprinklerX, SprinklerY, A_ScreenWidth//2, A_ScreenHeight//4, A_ScreenWidth, A_ScreenHeight, *90 %A_ScriptDir%\errors\you_must_be_standing_in_a_field_to_build_a_Sprinkler.png
    If (ErrorLevel == 0)
        Return

    ; if there is a wall, we want to start close to it, then realign on it at the end of a few loops
    Click, Down
    KeyPress(right_wall ? "d" : "a", horizontal_length*snakes)
    KeyPress(front_wall ? "w" : "s", vertical_length/2)
        
    Loop, %field_loops%
    {
        ; away from walls
        Loop, %snakes%
        {
            KeyPress(right_wall ? "a" : "d", horizontal_length)
            KeyPress(front_wall ? "s" : "w", vertical_length)
            KeyPress(right_wall ? "a" : "d", horizontal_length)
            KeyPress(front_wall ? "w" : "s", vertical_length)
        }

        ; towards walls
        Loop, %snakes%
        {
            KeyPress(right_wall ? "d" : "a", horizontal_length)
            KeyPress(front_wall ? "s" : "w", vertical_length)
            KeyPress(right_wall ? "d" : "a", horizontal_length)
            KeyPress(front_wall ? "w" : "s", vertical_length)
        }

        ; realignment or bag check
        Switch Mod(A_Index, realign_frequency)
        {
            Case 0:
                KeyPress("w", realign_distance * (front_wall ? 1.2 : 0))
                KeyPress("a", realign_distance * (left_wall ? 1.2 : 0))
                KeyPress("s", realign_distance * (back_wall ? 1.2 : 0))
                KeyPress("d", realign_distance * (right_wall ? 1.2 : 0))
                KeyPress("d", realign_distance * (left_wall ? 1 : 0))
                KeyPress("s", realign_distance * (front_wall ? 1 : 0))
                KeyPress("a", realign_distance * (right_wall ? 1 : 0))
                KeyPress("w", realign_distance * (back_wall ? 1 : 0))
            Default:
                If (stop_on_full_bag && IsBagFull()) then
                    break
        }
    }
    Click, Up
}

; Navigates to, and farms in, the bamboo field
BambooField(field_loops:=30)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\bamboo.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(3)
    KeyPress("w", 10000)
    Jump()
    KeyPress("w", 4000)
    KeyPress("d", 9500)
    KeyPress("w", 1300)
    ZoomOut(5)
    GatherFieldPollen(True, 650, 120, field_loops, 2)
    UnStickIfStuck()
}

; Navigates to, and farms in, the blue flower field
BlueFlowerField(field_loops:=30)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\bluf.ico
    ResetCharacter()
    FaceHive(false)
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
CactusField(field_loops:=30)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\cactus.ico
    ResetCharacter()
    FaceHive(false)
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
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\clover.ico
    ResetCharacter()
    FaceHive(false)
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
    If (field_loops > 0)
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
    GatherFieldPollen(True, 600, 110, field_loops, 2, True, False, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the dandelion field
DandelionField(field_loops:=35)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\dandelion.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(5.5)
    KeyPress("w", 4000)
    ZoomOut(5)
    GatherFieldPollen(True, 300, 100, field_loops)
    UnStickIfStuck()
}

; Navigates to, and farms in, the mountain top field
MountainTopField(field_loops:=25)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\mountain.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    RotateCamera(2)
    Loop, 5
    {
        KeyPress("e")
    }
    ZoomOut(5)
    Sleep, 2500
    KeyPress("a", 700)
    RotateCamera(4)
    GatherFieldPollen(True, 300, 110, field_loops, 4, True, False, False, False, 1000, 8)
    UnStickIfStuck()
}

; Navigates to, and farms in, the mushroom field
MushroomField(field_loops:=30)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\mushroom.ico
    ResetCharacter()
    FaceHive(false)
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
    If (field_loops > 0)
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
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\pine.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    RotateCamera(2)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 2500
    ZoomOut(5)
    KeyPress("d", 800)
    Sleep, 100
    Send, {Space down}
    KeyPress("w", 18000)
    Send, {Space up}
    Sleep, 500
    KeyPress("a", 420)
    KeyPress("s", 420*2)
    Sleep, 100
    GatherFieldPollen(True, 650, 125, field_loops, 2, True, False, True, False)
    UnStickIfStuck()
}

; Navigates to, and farms in, the pine tree forest in a manner optimal for using the Tide Popper
PineTreeForestTidePopper(field_loops:=150, use_shiftlock:=True)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\pine.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    RotateCamera(4)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 2500
    ZoomOut(5)
    KeyPress("s", 800)
    Sleep, 100
    Send, {Space down}
    KeyPress("d", 18000)
    Send, {Space up}
    Sleep, 500
    KeyPress("a", 1000)
    If (use_shiftlock)
        Send, LShift
    GatherFieldPollen(True, 500, 120, field_loops, 2, False, False, True, True)
    If (use_shiftlock)
        Send, LShift
    UnStickIfStuck()
}

; Navigates to, and farms in, the pineapple patch
PineapplePatch(field_loops:=25)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\pineapple.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    RotateCamera(6)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 2500
    ZoomOut(5)
    KeyPress("w", 4500)
    RotateCamera(2)
    KeyPress("w", 1600)
    GatherFieldPollen(True, 600, 120, field_loops, 2, True, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the pumpkin patch
PumpkinPatch(field_loops:=20)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\pumpkin.ico
    ResetCharacter()
    FaceHive(false)
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
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\rose.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(0)
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
    GatherFieldPollen(True, 600, 110, field_loops, 2, True, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the spider field
SpiderField(field_loops:=30)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\spider.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(3)
    KeyPress("w", 10000)
    Jump()
    KeyPress("w", 4000)
    KeyPress("d", 2600)
    KeyPress("w", 1300)
    ZoomOut(5)
    GatherFieldPollen(True, 650, 125, field_loops, 2, True, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the strawberry field
StrawberryField(field_loops:=30)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\strawberry.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(3)
    KeyPress("w", 10000)
    Jump()
    KeyPress("w", 4000)
    KeyPress("a", 4000)
    ZoomOut(5)
    RotateCamera(2)
    GatherFieldPollen(True, 650, 125, field_loops, 3, True, False, True)
    UnStickIfStuck()
}

; Navigates to, and farms in, the stump field
StumpField(field_loops:=25)
{
    If (field_loops > 0)
        Menu, Tray, Icon, %A_ScriptDir%\icons\stump.ico
    ResetCharacter()
    FaceHive(false)
    MoveToSlot(0)
    KeyPress("s", 1000)
    Jump()
    KeyPress("a", 1500)
    RotateCamera(6)
    Loop, 5
    {
        KeyPress("e")
    }
    Sleep, 2500
    ZoomOut(5)
    KeyPress("w", 12750)
    Keypress("d", 500)
    Sleep, 500
    GatherFieldPollen(True, 300, 100, field_loops, 3)
    UnStickIfStuck()
}

; Navigates to, and farms in, the sunflower field
SunflowerField(field_loops:=30)
{
    If (field_loops > 0)
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
    GatherFieldPollen(True, 300, 100, field_loops, 3, True, False, False, False, 200, 6)
    UnStickIfStuck()
}
