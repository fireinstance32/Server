---
tags: [design]
---
# Core Loop

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
- `hopsMultiplier = (1 + 0.5 × rebirths) × petMultiplier × (2 if DoubleHops)`
- `petMultiplier = 1 + Σ(pet.multiplier − 1)` over equipped pets
- `Wins gained = zone.wins × winsMultiplier`

## Progression systems
- **Frogs** – the "stones". Buy with Wins, equip one. See [[Balancing#Frogs]].
- **Eggs → Pets** – weighted random; up to 3 equipped (5 with pass).
- **Rebirth** – needs `5000 × 4^rebirths` Hops; resets Hops & Wins, keeps frogs & pets, +50% Hops forever.
- **Codes** – WELCOME, RIBBIT, FROGHOP.
