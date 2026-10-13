---
tags: [design]
---
# Core Loop

> **2026-10-13:** being reworked as a rock-lifting game (Hops → Strength, frogs → rocks, ponds → gyms) — see [[Rock Pivot]].

```
Train (pond) ──► Hops ──► Launch (river) ──► Wins ──► Frogs / Eggs ──► more Hops per pad
      ▲                                                             │
      └──────────────────── Rebirth (reset, permanent multiplier) ◄─┘
```

## Modes
| Mode | Where | What happens | Reward |
|---|---|---|---|
| Train | Training Pond | Frog hops `TrainingBounces` (5) pads around the pond | Hops = pads × perBounce × multiplier |
| Launch | River Dock | Frog hops down the river; distance from Hops | Hops per pad **and** Wins for the farthest zone |

## Formulas (source: `src/shared/Config/Game.luau`)
- `distance = 20 + 6 × Hops^0.5` studs, capped at river length (3200)
- `pads = floor(distance / 12)`
- `Hops gained = pads × frog.perBounce × hopsMultiplier`
- `hopsMultiplier = (1 + rebirths + Σ pet bonuses + 0.02 × (level − 1)) × pond × (best Strength pass tier: 2 / 4 / 8 / 16)` (training: pond multiplier applies)
- `Wins gained = zone.wins × winsMultiplier`

## Progression systems
- **Frogs** – the "stones". Buy with Wins, equip one. See [[Balancing#Frogs]].
- **Eggs → Pets** – weighted random; up to 3 equipped (5 with pass).
- **Levels** – XP = pads hopped. XP for the next level = `10 × 1.15^(level−1)`. Max level = `20 + 20 × rebirths`. Each level gives +2% Hops.
- **Rebirth** – needs MAX LEVEL; resets Hops and Level, keeps Wins, frogs & pets, +1x Hops forever (x2 → x3 …) and +20 max level.
- **Codes** – WELCOME, RIBBIT, FROGHOP.
