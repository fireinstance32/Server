---
tags: [lift-a-sword, design]
---
# Core Loop

The core loop as agreed on 2026-10-14. **It's still a draft:** open points are listed at the bottom, and no code gets written until they're settled. The references are Lift a Weight screenshots, not something to copy 1:1. Back to [[Lift a Sword]] · [[Lift a Sword Game Plan]] · [[Zones]] · [[Pets]].

## The loop
1. **Train:** equip your dumbbell and it lifts by itself, over and over. Each lift gives 💪 **Strength** and ⭐ **XP**.
2. **Level up:** XP fills the Level bar, and you level up automatically. Levels open zones ("Reach Level N" walls) and climb into the millions.
3. **Pull:** at a zone's pedestal, mash click/tap to fill the pull bar. Your Strength against the zone's Recommended Strength sets how fast it fills. When the bar is full the sword comes out and you get 💵 **Cash**.
4. **Spend Cash** on eggs (pets), dumbbell chests and the zone upgrade pads, so you train and pull faster.
5. **Moments:** while you train, a round **5x bubble** pops up on screen (UI, not in the world). Tap it for 5x training speed for 5 seconds. Each **level-up** gives screen shake, a burst round your character and a sound (no "+N Levels" popup).

## Stats
| Stat | You get it from | Boosted by | It's used for |
|---|---|---|---|
| 💪 Strength | every lift | dumbbell rarity, **pets**, x2 pass, 5x bubble | pull speed |
| ⭐ Level (XP) | every lift | **not pets**: only level packs / XP passes | zone walls, bragging (it shows how much you've trained) |
| 💵 Cash | pulling swords (later zones pay far more) | – | eggs, chests, upgrades |

## Pieces
- **Dumbbells:** you start with the "Train" dumbbell. There are 6 rarities, Common, Rare, Epic, Legendary, Mythical and Secret, with 5 dumbbells each and 2 Secret ones: **27 total**.
- **Chests:** one every 3 zones, **6 chests** in zones 1, 4, 7, 10, 13 and 16. Each sits behind its zone's wall, so a new zone also opens a new chest. Each chest rolls a dumbbell for Cash, and its odds lean higher than the chest before it (chest N is where rarity N starts dropping, and the zone 16 chest holds the 2 Secrets). Each chest also has a **special Robux version** (V.I.P roll, x5 luck, odds shown on the chest), like the reference.
- **Pets:** 16 eggs on the spawn stairs (84 pets), priced in Cash. They multiply Strength.
- **Zone upgrade pads:**
  - **Speed:** walk speed.
  - **Grip:** the aura upgrade. Shorter lift time (1s → 0.8s → …), and the gauntlets and aura show on your character.
- **Pulling** looks like Lift a Weight's lift bar: a mash bar, an Auto Pull toggle, and a Fast Pull game pass.
- **Zone walls:** a translucent wall reading "⭐ Level N Required" with a progress bar towards that level, like the reference.
- **UI:** a **Spawn** button at the top teleports you back to spawn. Level bar, Strength counter, Robux level packs (+5/+10/+25).
- **No rebirth at launch.** World 2 (the Underworld) is the long-term goal. Add rebirth later only if players finish too fast, and make it generous.

## Parked (good post-launch updates)
- **Evolve:** dropped for launch on 2026-10-14. Level, Strength and Cash are already three ways to grow. If it comes back, it must make your character buffer without copying Lift a Weight and must not depend on zones. Idea: Awaken (anime power-up stages) plus Titan growth.
- **Rebirth:** only if players finish too fast, and make it generous.
- **Zone training mats:** standing on an unlocked zone's `Mat` would multiply training. Not now.

## Open
- **Balancing targets:** progression should feel fast, but the game must not be 1 hour long. Robux Strength passes stack (x2, then x4, and so on) and must clearly speed players up. Simulator: `C:\LiftASword	oolsalancealance_sim.py`.
- First-pass numbers: Strength per lift, XP curve and zone Levels, Cash per pull per zone, prices for chests, pads and eggs, chest odds, and how the 27 dumbbells spread across the 6 chests.
