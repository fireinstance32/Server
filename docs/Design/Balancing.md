---
tags: [design, balance]
---
# Balancing

All numbers live in `src/shared/Config/`. Edit there, not in services. Pricing copies the ~3× step of [[Stone Skipping Reference]].

## Frogs
| Frog | Price (Wins) | Hops / pad |
|---|---|---|
| Baby | free | 1 |
| Leaf | 2 | 2 |
| Mud | 10 | 4 |
| Pond | 40 | 8 |
| Tree | 150 | 15 |
| Poison Dart | 500 | 30 |
| Bullfrog | 1.5K | 60 |
| Golden | 4.5K | 120 |
| Ninja | 14K | 250 |
| Royal | 40K | 500 |
| Phoenix | Robux | 1000 |

## Training ponds
| Pond | Unlock | Multiplier |
|---|---|---|
| Starter | 0 rebirths | 1x |
| Lotus | 2 rebirths | 4x |
| Crystal | 4 rebirths | 10x |
| Royal | 6 rebirths | 20x |
| Golden | Robux 90 (all worlds) | 3x |
| Rainbow | Robux 225 (all worlds) | 15x |
| Cosmic | Robux 540 (all worlds) | 50x |

Training = 5 pads × frog Hops/pad × multiplier, every 0.6 s.

## Zones (World 1)
| # | Name | Distance | Wins |
|---|---|---|---|
| 1 | Lily Shallows | 0 | 1 |
| 2 | Reed Bend | 100 | 3 |
| 3 | Mossy Rocks | 250 | 8 |
| 4 | Willow Run | 450 | 20 |
| 5 | Firefly Glade | 700 | 50 |
| 6 | Waterfall Steps | 1000 | 120 |
| 7 | Misty Marsh | 1400 | 300 |
| 8 | Sunset Lagoon | 1900 | 700 |
| 9 | King's Pond | 2500 | 1600 |

Hops needed to reach a zone: `((distance − 20) / 6)^2` → Zone 2 ≈ 178, Zone 5 ≈ 12.8K, Zone 9 ≈ 171K.

## Eggs
Pets **add** their bonus to the Hops multiplier (reference "+2"). Luck multiplies the weight of Rare+ pets.

| Egg | Price | Pets (bonus, weight) |
|---|---|---|
| Common | 50 Wins | Pebble Pup +1 (40), Clover Bun +1.5 (30), Brook Otter +2 (20), Moss Turtle +3 (10) |
| Uncommon | 500 Wins | Lily Frogling +3 (40), Reed Fox +4 (30), Pond Panda +6 (20), Dragonfly Kitty +9 (10) |
| Rare | 4K Wins | Firefly Bear +8 (45), Willow Owl +12 (35), Crystal Axolotl +18 (17), Golden Toad +30 (3) |
| Rainbow | Robux 41 | Rainbow Frog +40 (60), Galaxy Cat +60 (35), Prism Dragon +120 (5) |

Hatch 1 by default; 3 / 8 at once with the HatchTriple / HatchOcto passes. Inventory 50 (+100 with PetStorage), 3 equipped (+2 with ExtraPetSlots).

## Trails
| Trail | Price | Bonus |
|---|---|---|
| Leaf | 1K Wins | +0.5 |
| Bubble | 10K Wins | +1 |
| Firefly | 50K Wins | +2 |
| Sunset | 250K Wins | +4 |
| Rainbow | Robux 99 | +10 |
| Void | Robux 149 | +15 |

## Open questions
- [ ] Playtest time-to-Zone-9 for a new player (target: ~25 min)
- [ ] Is the late game too fast once Royal Frog + pets stack?
- [ ] World 2 gate value
