---
tags: [planning, moc]
---
# Roadmap

Build order for +1 Frog Hop. Each phase has its own note split into numbered sub-phases. Work top to bottom; a sub-phase is done when its **Done when** line is true.

**Naming:** Skill → **Hops**, Stone → **Frog**, Throw → **Hop**, Throw Zone → **Hop Zone**, Relic → **Legend Frog**. Reference: [[Stone Skipping UI Breakdown]].

| Phase | Goal | Sub-phases |
|---|---|---|
| 0 – Foundation ✅ | Rojo, saving, greybox loop, vault | done 2026-10-12 |
| [[Phase 1 - Core Loop]] | Loop feels like Stone Skipping | 1.1 Multiplier pipeline · 1.2 Levels · 1.3 HUD · 1.4 Training ponds · 1.5 Hop Zone + toss · 1.6 Distance meter · 1.7 River biomes |
| [[Phase 2 - Collection]] | Always something to unlock | 2.1 Frog podiums · 2.2 Eggs + hatch · 2.3 Pets UI · 2.4 Trails · 2.5 Inventory |
| [[Phase 3 - Retention]] | Come back tomorrow | 3.1 Tutorial · 3.2 Potions · 3.3 Daily rewards · 3.4 Offline · 3.5 Friend Boost · 3.6 Gifts · 3.7 Polish |
| [[Phase 4 - Monetization]] | Full shop | 4.1 Framework · 4.2 Shop UI · 4.3 Passes · 4.4 Packs · 4.5 Robux ponds · 4.6 Limited items · 4.7 Eggs & extras · 4.8 Gifting |
| [[Phase 5 - Spectacle]] | Clip-worthy | 5.1 Models · 5.2 VFX · 5.3 Ultimate hop · 5.4 Audio · 5.5 Art pass |
| [[Phase 6 - Worlds]] | Long-term progression | 6.1 Framework · 6.2 Portals · 6.3–6.6 Worlds 2–5 |
| [[Phase 7 - Live Ops]] | Launch | 7.1 Leaderboards · 7.2 Events · 7.3 Analytics · 7.4 Hardening · 7.5 Platform · 7.6 Launch kit |

## ⭐ Where to start: 1.1 → 1.2 → 1.3
**Status:** 1.1 done ✅ · next is 1.2.
1. **1.1 Multiplier pipeline.** Ponds, levels, potions, friend boost, passes, trails and Robux ponds all feed one multiplier. Building that pipe first means every later system plugs in with one line instead of a rewrite. It's small and invisible, and it blocks the most work.
2. **1.2 Levels.** The Level bar is the centrepiece of the reference HUD, and its "MAX LEVEL until you rebirth" rule is what drives rebirths. It's the first real user of 1.1.
3. **1.3 HUD rework.** With Hops, multiplier and Level real, lay out the final screen once, leaving empty slots (Friend Boost, side-menu dots, pass buttons) for later phases so the UI isn't redone repeatedly.

After that, 1.4 → 1.7 are the visible "feel" work (ponds, Hop Zone + toss, distance meter, biomes).

**Why not start with the flashy parts (models, VFX, worlds)?** Their look depends on the final loop and HUD; doing them first means redoing them later.

See also: [[Balancing]], [[Monetization]], [[Core Loop]].
