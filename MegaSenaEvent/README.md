# Mega Sena Event (Louis Emulator S6)

This folder contains a complete **server-side Lua** example implementation of a "Mega Sena" weekly lottery event.

## Features
- Bets with 6, 7, or 8 numbers (1..60)
- Flexible payment for bets: Zen, WC/WP/GP, or item/jewel
- Flexible prize payout: Zen, WC/WP/GP, or item/jewel
- SQL persistence (tables + history)
- Weekly automatic draw by schedule
- NPC talk entry + manual command

## Install
1. Copy the folder `MegaSenaEvent` to your GameServer Lua scripts directory.
2. In your server Lua entrypoint (example `Arquivos Lua Server/ScriptMain.lua`) add:

```lua
require('MegaSenaEvent\\Main')
```

3. Create the SQL tables from `MegaSenaEvent/sql/MegaSena.sql`.
4. Edit `MegaSenaEvent/Config.lua` to choose bet currency/prize currency and prices.

## Usage
- Command: `/megasena` shows help.
- Command: `/megasena bet 6 1 2 3 4 5 6` places a bet.
- Command: `/megasena jackpot` shows current jackpot.
- Command: `/megasena last` shows last draw numbers.

NPC usage depends on `Config.lua` NPC coordinates.

---

This is a documentation/example folder for the Louis S6 Lua scripting system.

