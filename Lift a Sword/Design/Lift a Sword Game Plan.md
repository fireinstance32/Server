---
tags: [lift-a-sword, design]
---
# Lift a Sword: Game Plan

Back to [[Lift a Sword]] · zone list in [[Zones]].

## The game
A Roblox strength simulator in the **Lift a Weight / Lift a Hammer** style (picked 2026-10-13), with a sword. Each zone down one long runway has a giant sword stuck in a themed pedestal, and the player **pulls it out of the stone** to gain Strength. More Strength unlocks heavier zones.

**Why a sword:** in the market scan, "Lift X" games with eggs did best (about 22K players). Lift a Hammer, Weight, Rock and most objects are taken. "Pull a Sword" exists but is small and uses a different verb.

## Loop (from the Lift a Weight reference)
- Click or press Train to lift and gain Strength.
- 15 themed zones with a recommended-Strength sign each.
- An egg pyramid at spawn with cash prices (15 → billions). Pets later.
- Strength upgrades, a permanent x2 Strength pass, offline Strength per hour, a World 2 portal, daily rewards, a spin wheel, a group chest, and Pass/Shop/Index/Pets buttons.

## Decided
- The map stays simple and readable like the reference: one straight runway of coloured zone strips, 140 wide × 150 long per zone, on a sea, with raised biome banks for decor.
- The player pulls the sword up out of the pedestal. A pull animation where the player stands on the pedestal and heaves; the grip starts about head height.
- **Pets:** 5 per egg for the first ~18 eggs, then 6, like Lift a Weight. **On hold** until you pick a style.
- The spin wheel and daily rewards are **UI**, not models.
- The group chest opens a "join the group" UI through a ProximityPrompt.
- The code will copy the +1 Frog Hop setup: Rojo, balance in Config, and a server-authoritative server.

## Starter assets in the place
- A blocky low-poly nature pack, used only as a clone source in `ServerStorage.NatureLibrary`.
- `StarterGui.Free_UI_Pack`: glossy cartoon buttons and panels.
