---
tags: [design, monetization]
---
# Monetization

IDs live in `src/shared/Config/Monetization.luau`. `0` = not created yet (ignored by the game).

All items live in `src/shared/Config/Monetization.luau` as `{ id, price, label }`. Create each one on the Creator Dashboard and paste the id; until then the button shows "not on sale yet".

## Game passes
| Pass | Effect | Shown price | Status |
|---|---|---|---|
| AutoHop | Auto-press HOP at a hop spot (top-centre button) | 23 | wired |
| AutoRebirth | Auto rebirth at MAX LEVEL (button shows while training) | 99 | wired |
| DoubleHops | x2 Hops | 5 | wired |
| DoubleWins | x2 Wins | 54 | wired |
| ExtraPetSlots | +2 equipped pets | 149 | wired |
| HatchTriple / HatchOcto | Hatch 3 / 8 eggs at once | 149 / 399 | wired |
| PetStorage | +100 pet inventory | 99 | wired |
| PondGolden / PondRainbow / PondCosmic | Unlock the 3x / 15x / 50x training ponds (all worlds) | 90 / 225 / 540 | wired |

## Developer products
| Product | Effect | Shown price | Status |
|---|---|---|---|
| HopsPack1/2/3 | +10K / +100K / +1M Hops | 10 / 41 / 86 | wired |
| StarterPack | +10K Hops, +500 Wins, +1 Rebirth (was 199) | 36 | wired |
| SkipRebirth | Rebirth without reaching max level | 25 | wired |
| PhoenixFrog | Unlock + equip Phoenix Frog | 199 | wired |
| RainbowEgg | Hatch one Rainbow Egg | 41 | wired |

## Copy from the reference shop (see [[Stone Skipping Reference]])
Robux eggs (x1/x3/x8), permanent 2x/10x Wins, tiered Hops packs, Skip Rebirth, Auto Rebirth, offline rewards x2, paid training zones, starter pack, `[GIFT]` version of every product, +pet inventory slots, trails.
