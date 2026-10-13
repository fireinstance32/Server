---
tags: [monetization, setup]
---
# Monetization Setup

Every Robux item is wired in code but has `id = 0` until you create it. Until then its button says "not on sale yet". Create each item on the **Creator Dashboard** (Creations → your experience → Monetization), then paste its id into `src/shared/Config/Monetization.luau` (`id = …`). Test without paying using `/grant <Pass>` and `/buy <Product>` in Studio.

## Game passes (Monetization → Passes)
| Config name | Name to use | Price | Description | id |
|---|---|---|---|---|
| `AutoHop` | Auto Lift | 49 | Automatically throws your rock while you stand in the Throw Zone. | ☐ |
| `AutoRebirth` | Auto Rebirth | 99 | Rebirths for you as soon as you reach MAX LEVEL. | ☐ |
| `DoubleHops` | +2x Strength | 5 | Strength multiplier tier 1: x2 Strength forever. | ☐ |
| `StrengthX4` | +4x Strength | 19 | Tier 2: x4 Strength forever (replaces x2). | ☐ |
| `StrengthX8` | +8x Strength | 49 | Tier 3: x8 Strength forever (replaces x4). | ☐ |
| `StrengthX16` | +16x Strength | 129 | Tier 4: x16 Strength forever (replaces x8). | ☐ |
| `DoubleWins` | 2x Wins | 99 | Doubles all the Wins you earn, forever. | ☐ |
| `ExtraPetSlots` | +2 Pet Slots | 129 | Equip 2 more pets at once. | ☐ |
| `HatchTriple` | +3 Eggs (hatch 3 at once) | 129 | Hatch 3 eggs at once (R key). | ☐ |
| `HatchOcto` | +8 Eggs (hatch 8 at once) | 299 | Hatch 8 eggs at once (R key). | ☐ |
| `PetStorage` | +100 Pet Storage | 59 | Store 100 more pets. | ☐ |
| `OfflineDouble` | Offline Rewards x2 | 49 | Earn twice as much Strength while you are offline. | ☐ |
| `PondGolden` | Golden Gym (3x) | 79 | Unlocks the Golden Gym (3x Strength training) in every world. | ☐ |
| `PondRainbow` | Rainbow Gym (15x) | 199 | Unlocks the Rainbow Gym (15x Strength training) in every world. | ☐ |
| `PondCosmic` | Cosmic Gym (50x) | 399 | Unlocks the Cosmic Gym (50x Strength training) in every world. | ☐ |

## Developer products (Monetization → Developer Products)
| Config name | Name to use | Price | Description | id |
|---|---|---|---|---|
| `StarterPack` | Starter Pack | 49 | Rainbow Unicat pet, +10K Strength, +500 Wins, a Strength Boost and +1 Rebirth. One-time offer! | ☐ |
| `GalaxyPack` | Galaxy Pack | 299 | Galaxy Cat pet, 3 of each boost, +1M Strength and +10 Rebirths. | ☐ |
| `HopsPack1` | +10K Strength | 19 | +10,000 Strength. | ☐ |
| `HopsPack2` | +100K Strength | 49 | +100,000 Strength. | ☐ |
| `HopsPack3` | +1M Strength | 99 | +1,000,000 Strength. | ☐ |
| `SkipRebirth` | Skip Rebirth | 29 | Rebirth right now without reaching MAX LEVEL. | ☐ |
| `PhoenixFrog` | Phoenix Stone | 249 | The Phoenix Stone: 1000 Strength per bounce. Limited to 1000! | ☐ |
| `RainbowEgg` | Rainbow Egg | 39 | Hatch one Rainbow Egg (Rainbow Golem, Galaxy Cat or Prism Dragon). | ☐ |
| `RainbowEgg3` | 3 Rainbow Eggs | 99 | Hatch 3 Rainbow Eggs. | ☐ |
| `RainbowEgg8` | 8 Rainbow Eggs | 249 | Hatch 8 Rainbow Eggs. | ☐ |
| `PotionPack` | Boost Bundle | 99 | 3 Strength, 3 Wins and 3 Luck boosts. | ☐ |
| `HopsBoost` | Strength Boost | 25 | One Strength boost. | ☐ |
| `WinsBoost` | Wins Boost | 25 | One Wins boost. | ☐ |
| `WinsPack1` | Tiny Wins Pack | 19 | +10,000 Wins. | ☐ |
| `WinsPack2` | Small Wins Pack | 49 | +50,000 Wins. | ☐ |
| `WinsPack3` | Medium Wins Pack | 99 | +200,000 Wins. | ☐ |
| `WinsPack4` | Large Wins Pack | 199 | +500,000 Wins. | ☐ |
| `WinsPackMega` | Mega Wins Pack (first time) | 349 | +1,000,000 Wins. First-time price! | ☐ |
| `WinsPackMega2` | Mega Wins Pack | 449 | +1,000,000 Wins. | ☐ |
| `RainbowTrail` | Rainbow Trail | 79 | Rainbow trail behind your rock (+10 multiplier). | ☐ |
| `VoidTrail` | Void Trail | 129 | Void trail behind your rock (+15 multiplier). | ☐ |

## Gift products (Developer Products, in `GiftIds`)
One developer product per giftable item, named `[GIFT] <item name>`, same price as the item. The buyer picks a player in the Shop › Gift section first.

| Config name | Name to use |
|---|---|
| `DoubleHops` | [GIFT] +2x Strength |
| `StrengthX4` | [GIFT] +4x Strength |
| `StrengthX8` | [GIFT] +8x Strength |
| `StrengthX16` | [GIFT] +16x Strength |
| `DoubleWins` | [GIFT] 2x Wins |
| `AutoHop` | [GIFT] Auto Lift |
| `HatchTriple` | [GIFT] +3 Eggs (hatch 3 at once) |
| `HatchOcto` | [GIFT] +8 Eggs (hatch 8 at once) |
| `ExtraPetSlots` | [GIFT] +2 Pet Slots |
| `PetStorage` | [GIFT] +100 Pet Storage |
| `OfflineDouble` | [GIFT] Offline Rewards x2 |
| `HopsPack1` | [GIFT] +10K Strength |
| `HopsPack2` | [GIFT] +100K Strength |
| `HopsPack3` | [GIFT] +1M Strength |
| `RainbowEgg` | [GIFT] Rainbow Egg |
| `RainbowEgg3` | [GIFT] 3 Rainbow Eggs |
| `RainbowEgg8` | [GIFT] 8 Rainbow Eggs |
| `PotionPack` | [GIFT] Boost Bundle |
| `GalaxyPack` | [GIFT] Galaxy Pack |
| `HopsBoost` | [GIFT] Strength Boost |
| `WinsBoost` | [GIFT] Wins Boost |
| `AutoRebirth` | [GIFT] Auto Rebirth |
| `PondGolden` | [GIFT] Golden Gym (3x) |
| `PondRainbow` | [GIFT] Rainbow Gym (15x) |
| `PondCosmic` | [GIFT] Cosmic Gym (50x) |

**Prices (2026-10-13):** a middle ladder — small things 19–59, most passes and packs 79–129, big items 199–449. Nothing under 19 or over 449.

## Limited stock
`Limited` in the same file sets how many can ever be sold across all servers (Phoenix Stone: 1000). The count is stored in the `FrogHop_LimitedStock_v1` DataStore.

See also: [[Monetization]].

## Strength multiplier tiers
Like the reference's Skill Multiplier [TIER n] (its prices are shown with the Roblox Plus 10% discount; ours are the full prices): x2 for 5, x4 for 19, x8 for 49, x16 for 129. They don't stack: the highest tier owned is the multiplier (`Monetization.strengthTier`). The HUD card and the Shop card always offer the next tier. More tiers can be added to `StrengthTiers` in `Config/Monetization`.
