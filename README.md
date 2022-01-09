# Bee Swarm Simulator Macros & Functions
## What is this?

Our attempt at providing a powerful & easily extensible / editable function list for BSS beekeepers to create their own macros. Additionally, an open-source alternative to potentially dangerous compiled executables or less-powerful JitBit macros prevalent in the BSS community.<br>

## Features
- Easily configurable hotkeys, such as the default CTRL+P to play, CTRL+Q to stop
- Reconnect to the game if you lost connection or the server restarted
- Set cooldowns for any task (such as bug running every 20/30/60/any minutes, wealth clock every hour, ant pass every 2 hours)
- Place 1-4 sprinklers, jumping as necessary automatically
- Support for emptying the hive balloon if desired

## How to Use

1. Download & Install [Autohotkey](https://www.autohotkey.com/)
2. Download this code and it's dependencies (Code -> Download ZIP) & unzip it into a directory of your choice
3. Edit `config.ahk` to your liking, put your sprinkler in the first slot
4. Run the included example `sunf +bca.ahk` or any user-created file, default hotkeys are CTRL+Q to stop, and CTRL+P to play.

## Troubleshooting
- Make sure your screen resolution is at least 800x600 and Windows Display Scaling is set to 100% (default), otherwise you may have to recapture or resize the pictures inside the `errors` and `images` folders
- Make sure you have your sprinkler in the first slot, and have edited `config.ahk`

## Creating Your Own Macros
- Browse through the comments inside `functions.ahk` to create your own macro, or take a look at the implementation in the included example `sunf +bca.ahk` for ideas or inspiration. This example macro:
    - Reconnects if disconnected
    - Activates the Wealth Clock every hour
    - Uses the free Ant Pass dispenser every 2 hours
    - Kills & loots Mondo Chick (make sure your system time is set correctly if you do this)
    - Does a bug run every 30 minutes, turning in polar bear quests & killing vicious bees on the way through
      - Note: See the warnings in `functions.ahk`
    - Farms in sunflower field if it's not time to grab clock/ant/mondo/bugs
    - Empties the hive balloon if it hasn't been emptied in the last 30 minutes