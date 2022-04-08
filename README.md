# Bee Swarm Simulator Macros & Functions
## What is this?

Our attempt at providing a powerful & easily extensible / editable function list for BSS beekeepers to create their own macros. Additionally, an open-source alternative to potentially dangerous compiled executables or less-powerful JitBit macros prevalent in the BSS community.<br>

## Features
- Easily configurable hotkeys, such as the default CTRL+P to play, CTRL+Q to stop
- Reconnect to the game if you lost connection or the server restarted
- Set cooldowns for any task (such as bug running every 20/30/60/any minutes, wealth clock every hour, ant pass every 2 hours) that persist through macro sessions
- Place 1-4 sprinklers, jumping as necessary automatically
- Support for emptying the hive balloon if desired
- Fully configureable planter support & management including harvesting, replacing, and rotating them through fields defined in `config.ini`

## How to Use

1. Download & Install [Autohotkey](https://www.autohotkey.com/)
2. Download this code and it's dependencies (Code -> Download ZIP) & unzip it into a directory of your choice.
3. Edit `config.ini` to your liking (NOT `configuration.ahk` - run `reset config.ahk` first if you don't have a `config.ini` file).
4. Put your sprinkler in the first slot of your hotbar ingame.
5. Run an included example such as `sunf +bca.ahk` or `pine balloon.ahk` or any user-created file, default hotkeys are CTRL+Q to stop, and CTRL+P to play.

## Troubleshooting
- Make sure your screen resolution is at least 800x600.
- Make sure Windows Display Scaling is set to 100% (default).
- If you have a dedicated GPU, make sure you don't have any settings enabled which change image fidelity (such as AI-powered resolution upscaling, system-wide anti-aliasing, etc.) - note that these are usually off by default.
- Any of the three above issues can cause repeated reconnections due to the functions not properly detecting if you're connected or in-game, and you may have to recapture or resize the pictures inside the `errors` and `images` folders.
- If your wind shrine donations aren't functioning properly, you may need to recapture `wind_shrine_next_item.png` due to the way roblox draws this character differently for every resolution.
- Make sure you have your sprinkler in the first slot, and have edited `config.ini`
- You can try running the `reset config.ahk` file and re-editing the fresh `config.ini` if these functions worked for you in the past but stopped working.

## Creating Your Own Macros
- Browse through the comments inside `functions.ahk` to create your own macro, or take a look at the implementation in the included examples for ideas or inspiration. For example, the `sunf +bca` macro:
    - Reconnects if disconnected
    - Activates the Wealth Clock every hour
    - Uses the free Ant Pass dispenser every 2 hours
    - Kills & loots Mondo Chick (make sure your system time is set correctly if you do this)
    - Does a bug run every 30 minutes, turning in polar bear quests & killing vicious bees on the way through
      - Note: See the warnings in `functions.ahk`
    - Farms in sunflower field if it's not time to grab clock/ant/mondo/bugs
    - Empties the hive balloon if it hasn't been emptied in the last 30 minutes
- `pine balloon.ahk` implements some newer features, such as:
    - Activating Beesmas machines
    - Placing, harvesting, looting, and rotating planters through fields as defined in `config.ini`
    - Donating to the Wind Shrine & activating a field booster
    - Farming Pine Tree Forest in a unique way designed for using the Tide Popper