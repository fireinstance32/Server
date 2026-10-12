---
tags: [monetization, setup]
---
# Monetization Setup

Every Robux item is wired in code but has `id = 0` until you create it. Until then its button says "not on sale yet". Create each item on the **Creator Dashboard** (Creations → your experience → Monetization), then paste its id into `src/shared/Config/Monetization.luau` (`id = …`). Test without paying using `/grant <Pass>` and `/buy <Product>` in Studio.

## Game passes (Monetization → Passes)
| Config name | Name to use | Price | Description | id |
|---|---|---|---|---|
| `AutoHop` | Auto Hop | 23 | Automatically hops down the river while you stand in the Hop Zone. | ☐ |
| `AutoRebirth` | Auto Rebirth | 99 | Rebirths for you as soon as you reach MAX LEVEL. | ☐ |
| `DoubleHops` | +2x Hops | 5 | Doubles all the Hops you earn, forever. | ☐ |
| `DoubleWins` | 2x Wins | 54 | Doubles all the Wins you earn, forever. | ☐ |
| `ExtraPetSlots` | +2 Pet Slots | 149 | Equip 2 more pets at once. | ☐ |
| `HatchTriple` | +3 Eggs (hatch 3 at once) | 149 | Hatch 3 eggs at once (R key). | ☐ |
| `HatchOcto` | +8 Eggs (hatch 8 at once) | 399 | Hatch 8 eggs at once (R key). | ☐ |
| `PetStorage` | +100 Pet Storage | 99 | Store 100 more pets. | ☐ |
| `OfflineDouble` | Offline Rewards x2 | 79 | Earn twice as many Hops while you are offline. | ☐ |
| `PondGolden` | Golden Pond (3x) | 90 | Unlocks the Golden Pond (3x Hops training) in every world. | ☐ |
| `PondRainbow` | Rainbow Pond (15x) | 225 | Unlocks the Rainbow Pond (15x Hops training) in every world. | ☐ |
| `PondCosmic` | Cosmic Pond (50x) | 540 | Unlocks the Cosmic Pond (50x Hops training) in every world. | ☐ |

## Developer products (Monetization → Developer Products)
| Config name | Name to use | Price | Description | id |
|---|---|---|---|---|
| `StarterPack` | Starter Pack | 36 | +10K Hops, +500 Wins and +1 Rebirth. One-time offer! | ☐ |
| `HopsPack1` | +10K Hops | 10 | +10,000 Hops. | ☐ |
| `HopsPack2` | +100K Hops | 41 | +100,000 Hops. | ☐ |
| `HopsPack3` | +1M Hops | 86 | +1,000,000 Hops. | ☐ |
| `SkipRebirth` | Skip Rebirth | 25 | Rebirth right now without reaching MAX LEVEL. | ☐ |
| `PhoenixFrog` | Phoenix Frog | 199 | The Phoenix Frog: 1000 Hops per pad. Limited to 1000! | ☐ |
| `RainbowEgg` | Rainbow Egg | 41 | Hatch one Rainbow Egg (Rainbow Frog, Galaxy Cat or Prism Dragon). | ☐ |
| `RainbowTrail` | Rainbow Trail | 99 | Rainbow trail behind your frog (+10 multiplier). | ☐ |
| `PotionPack` | Potion Pack (3 of each) | 49 | 3 Hops, 3 Wins and 3 Luck boosts. | ☐ |
| `VoidTrail` | Void Trail | 149 | Void trail behind your frog (+15 multiplier). | ☐ |

## Gift products (Developer Products, in `GiftIds`)
One developer product per giftable item, named `[GIFT] <item name>`, same price as the item. The buyer picks a player in the Shop › Gift section first.

| Config name | Name to use |
|---|---|
| `DoubleHops` | [GIFT] +2x Hops |
| `DoubleWins` | [GIFT] 2x Wins |
| `AutoHop` | [GIFT] Auto Hop |
| `HatchTriple` | [GIFT] +3 Eggs (hatch 3 at once) |
| `HatchOcto` | [GIFT] +8 Eggs (hatch 8 at once) |
| `ExtraPetSlots` | [GIFT] +2 Pet Slots |
| `PetStorage` | [GIFT] +100 Pet Storage |
| `OfflineDouble` | [GIFT] Offline Rewards x2 |
| `HopsPack1` | [GIFT] +10K Hops |
| `HopsPack2` | [GIFT] +100K Hops |
| `HopsPack3` | [GIFT] +1M Hops |
| `RainbowEgg` | [GIFT] Rainbow Egg |
| `PotionPack` | [GIFT] Potion Pack (3 of each) |

## Limited stock
`Limited` in the same file sets how many can ever be sold across all servers (Phoenix Frog: 1000). The count is stored in the `FrogHop_LimitedStock_v1` DataStore.

See also: [[Monetization]].
