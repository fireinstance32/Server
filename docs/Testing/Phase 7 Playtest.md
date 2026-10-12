---
tags: [testing, phase7]
status: ready
---
# Phase 7 Playtest

> Ready to run. Setup: [[Testing Guide]]. Worlds sit 4000 studs apart along +Z; each has the full hub.

## Portals and gates
- [ ] Spawn hub has 4 portals next to spawn (Worlds 2–5) with "Unlock with 1M / 50M / 2.5B / 100B Hops"
- [ ] Press E at the World 2 portal with few Hops → "Mushroom Swamp needs 1M Hops", you stay put
- [ ] `/hops 1000000`, E at the World 2 portal → teleported to Mushroom Swamp, it stays unlocked after `/hops 0` and rejoining
- [ ] Each hub has portals back to every other world (incl. Lily Valley, always open)
- [ ] `/world candy`, `/world space`, `/world lava`, `/world lily` all unlock and teleport

## Each world (check 2 and 5 at least)
- [ ] Hub has a Hop Zone, river with pads, 7 ponds, frog podiums with that world's 4 frogs and 2 egg stands
- [ ] River banks use the world's biome colours; zone toasts show the world's zone names
- [ ] Training on a pond pad works (pond signs show correctly, locked ponds still need rebirths/passes)
- [ ] A hop from the Hop Zone lands on that world's river; landing card shows that world's zone + Wins (much bigger than World 1)
- [ ] Podium prices/Hops per pad match [[Balancing]]; each world's podiums only sell its own frogs
- [ ] Egg signs show the world's odds; E hatches; the hatch screen shows the new pets
- [ ] Pets follow you between worlds; held frog stays in hand after teleport

## Regression
- [ ] World 1 hops, training, eggs and podiums unchanged
- [ ] Auto Hop and auto-hatch still work after travelling
