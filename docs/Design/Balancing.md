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
| Egg | Price | Pets (weight) |
|---|---|---|
| Pond | 50 | Fly x1.1 (50), Snail x1.25 (30), Dragonfly x1.5 (15), Turtle x2 (5) |
| Swamp | 2.5K | Duck x1.4 (50), Koi x1.8 (32), Crab x2.5 (15), Axolotl x4 (2.9), Rainbow Toad x8 (0.1) |

## Open questions
- [ ] Playtest time-to-Zone-9 for a new player (target: ~25 min)
- [ ] Is the late game too fast once Royal Frog + pets stack?
- [ ] World 2 gate value
