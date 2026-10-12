---
tags: [testing]
---
# Testing Guide

Every phase ends with a **playtest** step. I write a playtest note for it (checklist + what to look for), you run it in Studio, and we fix what you find before starting the next phase.

## Before every playtest
1. Obsidian Git has pulled (or run `git pull` in `C:\1FrogHop`).
2. `rojo serve` is running and the Studio Rojo plugin says **Connected**.
3. **View → Output** is open (errors show up here; screenshot anything red).
4. Press **Play** (F5). Use **Test → Clients and Servers → 2 Players** when a test needs two players.

## Test commands (Studio only)
Type these in the game chat. They only work in Studio (or for user ids listed in `src/shared/Config/Dev.luau`).

| Command | What it does |
|---|---|
| `/help` | List all commands |
| `/hops 5000` | Set Hops |
| `/wins 1000` | Set Wins |
| `/level 15` | Set Level (clamped to the cap) |
| `/maxlevel` | Jump to MAX LEVEL |
| `/rebirths 2` | Set Rebirths |
| `/frogs` | Unlock every frog |
| `/potion hops 3` | Add potions (hops / wins / luck) |
| `/daily next` / `/daily reset` | Pretend a day passed / restart the daily streak |
| `/grant DoubleHops` | Pretend you own a pass (this session) |
| `/buy HopsPack3` | Run a product's effect without paying |
| `/goto river` / `/goto pond 3` | Teleport to the Hop Zone / a training pond (1–7) |
| `/world swamp` | Unlock + travel to a world (lily / swamp / candy / space / lava) |
| `/event halloween 100` / `/event none` / `/event auto` | Force an event on (+ give its currency) / off / back to the calendar |
| `/reset` | Wipe your data to a brand-new player |

## Reporting a problem
For each issue, note: **what you did → what you expected → what happened**, plus a screenshot of the screen and of the Output window. Paste it to me in chat; I log fixes in the devlog.

## Playtests
- [[Phase 1 Playtest]]
- [[Phase 2 Playtest]]
- [[Phase 3 Playtest]]
- [[Phase 4 Playtest]]
- [[Phase 7 Playtest]]
- [[Phase 8 Playtest]]
