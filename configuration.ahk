; DO NOT CHANGE ANYTHING IN THIS "configuration.ahk" FILE
; Instead, change the "config.ini" file
; Run "reset config.ahk" if you don't have a "config.ini" file

; Global defaults
global Stats_sprinkler_amount := 1
global Stats_hive_slot := 1
global Stats_VIP_to_reconnect_to := "https://www.roblox.com/games/1537690962?privateServerLinkCode=508610322381920906618415046657"
global Stats_seconds_to_wait_on_reconnect := 120
global Stats_movespeed := 28
global Stats_movespeed_factor := 28 / movespeed

global Hotkeys_extracts := 2
global Hotkeys_enzymes := 3
global Hotkeys_planter1 := 4
global Hotkeys_planter2 := 5
global Hotkeys_planter3 := 6
global Hotkeys_whirligig := 7

global Planters_planter1 := "blueclay"
global Planters_planter1_fields := ["PineTreeForest"]
global Planters_planter1_reuse_time := [360]
global Planters_planter1_current_field := "nowhere"
global Planters_planter2 := "redclay"
global Planters_planter2_fields := ["PumpkinPatch","RoseField"]
global Planters_planter2_reuse_time := [360,360]
global Planters_planter2_current_field := "nowhere"
global Planters_planter3 := "tacky"
global Planters_planter3_fields := ["MushroomField","SunflowerField"]
global Planters_planter3_reuse_time := [360,360]
global Planters_planter3_current_field := "nowhere"

global Cooldowns_bugrun := 20211106000000
global Cooldowns_mondo := 20211106000000
global Cooldowns_balloon := 20211106000000
global Cooldowns_whirligig := 20211106000000
global Cooldowns_planter1 := 20211106000000
global Cooldowns_planter2 := 20211106000000
global Cooldowns_planter3 := 20211106000000
global Cooldowns_wealthclock := 20211106000000
global Cooldowns_antpass := 20211106000000
global Cooldowns_blue_field_booster := 20211106000000
global Cooldowns_red_field_booster := 20211106000000
global Cooldowns_field_booster := 20211106000000
global Cooldowns_honey_dispenser := 20211106000000
global Cooldowns_treat_dispenser := 20211106000000
global Cooldowns_star_hall_royal_jelly_dispenser := 20211106000000
global Cooldowns_blueberry_dispenser := 20211106000000
global Cooldowns_strawberry_dispenser := 20211106000000
global Cooldowns_coconut_dispenser := 20211106000000
global Cooldowns_glue_dispenser := 20211106000000
global Cooldowns_honeystorm := 20211106000000
global Cooldowns_special_sprout_summoner := 20211106000000
global Cooldowns_mythic_meteor_shower := 20211106000000
global Cooldowns_wind_shrine := 20211106000000
global Cooldowns_memory_match := 20211106000000
global Cooldowns_mega_memory_match := 20211106000000
global Cooldowns_night_memory_match := 20211106000000
global Cooldowns_extreme_memory_match := 20211106000000
global Cooldowns_honey_wreath := 20211106000000
global Cooldowns_gingerbread_house := 20211106000000
global Cooldowns_stockings := 20211106000000
global Cooldowns_snowbear_summoner := 20211106000000
global Cooldowns_beesmas_feast := 20211106000000
global Cooldowns_samovar := 20211106000000
global Cooldowns_lid_art := 20211106000000
global Cooldowns_winter_memory_match := 20211106000000
global Cooldowns_honeyday_candles := 20211106000000
global Cooldowns_snow_machine := 20211106000000
global Cooldowns_gummy_beacon := 20211106000000

; Creates a generic config.ini file
ConfigCreate()
{
    If FileExist("config.ini")
        FileDelete, config.ini
    default_timestamp := 20211106000000
    FileAppend,
    ( LTrim
    ; For sprinkler amounts, Diamond 4, Golden 3, Silver 2, and Basic / Supreme is 1
    ; For Hive Slots, 1 is closest to red cannon, 6 is closest to noob shop
    ; You can get your movespeed from the system tab, 28 is end-game gear
    [Stats]
    sprinkler_amount=%Stats_sprinkler_amount%
    hive_slot=%Stats_hive_slot%
    VIP_to_reconnect_to=%Stats_VIP_to_reconnect_to%
    seconds_to_wait_on_reconnect=%Stats_seconds_to_wait_on_reconnect%
    movespeed=%Stats_movespeed%

    ; These do not get pressed & don't need to be changed unless you code them in somewhere
    [Hotkeys]
    extracts=2
    enzymes=3
    planter1=4
    planter2=5
    planter3=6
    whirligig=7

    ; Reuse time is in minutes and a time value is needed for each field
    ; Make sure you are following the proper naming convention
    ; Valid fields are their proper names
    ; Valid planters are: paper, ticket, festive, plastic, candy, redclay, blueclay, tacky, pesticide, petal, plenty
    [Planters]
    planter1=blueclay
    planter1_fields=PineTreeForest
    planter1_reuse_time=360
    planter2=redclay
    planter2_fields=PumpkinPatch,RoseField
    planter2_reuse_time=360,360
    planter3=tacky
    planter3_fields=MushroomField,SunflowerField
    planter3_reuse_time=360,360



    ; Don't edit these cooldowns manually unless you know what you're doing
    [Cooldowns]

    [ConfigVersion]
    current=1
    ), config.ini
    UpdateIniFromGlobals()
    MsgBox, A new config.ini file has been created, make sure to edit it before running anything!
}

; Deletes the config.ini file
ConfigDelete()
{
    If FileExist("config.ini")
    {
        FileDelete, config.ini
        MsgBox, An old config.ini file has been deleted.
        Return True
    }
    Return False
}

; Deletes the config.ini file & generates a new one with standard settings
ConfigReset()
{
    ConfigDelete()
    ConfigCreate()
}

; Persistently saves pertinent information for use between sessions to config.ini
UpdateIniFromGlobals()
{
    ; to save arrays: iterate through array elements and create a string, then save the string to the ini
    ; we don't need to do this because we're not saving any arrays (yet?)

    ; saving planter fields persistently
    global_planter_vars_to_write := ["Planters_planter1_current_field", "Planters_planter2_current_field", "Planters_planter3_current_field"]
    For each, global_variable_name in global_planter_vars_to_write
    {
        ; removes "Planters_" from the start of the global variable and stores the result as the key name in the .ini file
        ini_key := SubStr(global_variable_name, 10)
        IniWrite, % %global_variable_name%, config.ini, Planters, %ini_key%
    }


    ; saving cooldowns persistently
    global_cooldown_vars_to_write := ["Cooldowns_bugrun", "Cooldowns_mondo", "Cooldowns_balloon", "Cooldowns_whirligig", "Cooldowns_planter1", "Cooldowns_planter2", "Cooldowns_planter3", "Cooldowns_wealthclock", "Cooldowns_antpass", "Cooldowns_blue_field_booster", "Cooldowns_red_field_booster", "Cooldowns_field_booster", "Cooldowns_honey_dispenser", "Cooldowns_treat_dispenser", "Cooldowns_star_hall_royal_jelly_dispenser", "Cooldowns_blueberry_dispenser", "Cooldowns_strawberry_dispenser", "Cooldowns_coconut_dispenser", "Cooldowns_glue_dispenser", "Cooldowns_honeystorm", "Cooldowns_special_sprout_summoner", "Cooldowns_mythic_meteor_shower", "Cooldowns_wind_shrine", "Cooldowns_memory_match", "Cooldowns_mega_memory_match", "Cooldowns_night_memory_match", "Cooldowns_extreme_memory_match", "Cooldowns_honey_wreath", "Cooldowns_gingerbread_house", "Cooldowns_stockings", "Cooldowns_snowbear_summoner", "Cooldowns_beesmas_feast", "Cooldowns_samovar", "Cooldowns_lid_art", "Cooldowns_winter_memory_match", "Cooldowns_honeyday_candles", "Cooldowns_snow_machine", "Cooldowns_gummy_beacon"]
    For each, global_variable_name in global_cooldown_vars_to_write
    {
        ; removes "Cooldowns_" from the start of the global variable and stores the result as the key name in the .ini file
        ini_key := SubStr(global_variable_name, 11)
        IniWrite, % %global_variable_name%, config.ini, Cooldowns, %ini_key%
    }
}

; Retrieves the settings from config.ini for use with AHK
UpdateGlobalsFromIni()
{
    ; reading all the stats in from config.ini
    global_stat_vars_to_read := ["Stats_sprinkler_amount", "Stats_hive_slot", "Stats_VIP_to_reconnect_to", "Stats_seconds_to_wait_on_reconnect", "Stats_movespeed"]
    For each, global_variable_name in global_stat_vars_to_read
    {
        ini_key := SubStr(global_variable_name, 7)
        IniRead, %global_variable_name%, config.ini, Stats, %ini_key%
    }

    ; reading all the hotkeys in from the config.ini
    global_hotkey_vars_to_read := ["Hotkeys_extracts", "Hotkeys_enzymes", "Hotkeys_planter1", "Hotkeys_planter2", "Hotkeys_planter3", "Hotkeys_whirligig"]
    For each, global_variable_name in global_hotkey_vars_to_read
    {
        ini_key := SubStr(global_variable_name, 9)
        IniRead, %global_variable_name%, config.ini, Hotkeys, %ini_key%
    }

    ; reading all the planter information in from the config.ini
    global_planter_vars_to_read := ["Planters_planter1", "Planters_planter2", "Planters_planter3", "Planters_planter1_current_field", "Planters_planter2_current_field", "Planters_planter3_current_field"]
    For each, global_variable_name in global_planter_vars_to_read
    {
        ini_key := SubStr(global_variable_name, 10)
        IniRead, %global_variable_name%, config.ini, Planters, %ini_key%
    }
    global_planter_arrays_to_read := ["Planters_planter1_fields", "Planters_planter2_fields", "Planters_planter3_fields", "Planters_planter1_reuse_time", "Planters_planter2_reuse_time", "Planters_planter3_reuse_time"]
    For each, global_array_name in global_planter_arrays_to_read
    {
        ini_key := SubStr(global_array_name, 10)
        temp_planter_string := ""
        IniRead, temp_planter_string, config.ini, Planters, %ini_key%
        %global_array_name% := StrSplit(temp_planter_string, ",")
    }

    ; reading all the cooldowns in from the config.ini
    global_cooldown_vars_to_read := ["Cooldowns_bugrun", "Cooldowns_mondo", "Cooldowns_balloon", "Cooldowns_whirligig", "Cooldowns_planter1", "Cooldowns_planter2", "Cooldowns_planter3", "Cooldowns_wealthclock", "Cooldowns_antpass", "Cooldowns_blue_field_booster", "Cooldowns_red_field_booster", "Cooldowns_field_booster", "Cooldowns_honey_dispenser", "Cooldowns_treat_dispenser", "Cooldowns_star_hall_royal_jelly_dispenser", "Cooldowns_blueberry_dispenser", "Cooldowns_strawberry_dispenser", "Cooldowns_coconut_dispenser", "Cooldowns_glue_dispenser", "Cooldowns_honeystorm", "Cooldowns_special_sprout_summoner", "Cooldowns_mythic_meteor_shower", "Cooldowns_wind_shrine", "Cooldowns_memory_match", "Cooldowns_mega_memory_match", "Cooldowns_night_memory_match", "Cooldowns_extreme_memory_match", "Cooldowns_honey_wreath", "Cooldowns_gingerbread_house", "Cooldowns_stockings", "Cooldowns_snowbear_summoner", "Cooldowns_beesmas_feast", "Cooldowns_samovar", "Cooldowns_lid_art", "Cooldowns_winter_memory_match", "Cooldowns_honeyday_candles", "Cooldowns_snow_machine", "Cooldowns_gummy_beacon"]
    For each, global_variable_name in global_cooldown_vars_to_read
    {
        ini_key := SubStr(global_variable_name, 11)
        IniRead, %global_variable_name%, config.ini, Cooldowns, %ini_key%
    }
    Stats_movespeed_factor := 28 / Stats_movespeed
}

; Returns the config.ini version from the bottom of the file
GetConfigVersion()
{
    IniRead, config_version, config.ini, ConfigVersion, current
    Return config_version
}
