---
tags: [planning, moc]
---
# Roadmap

Build order for +1 Frog Hop. Each phase has its own note split into numbered sub-phases. Work top to bottom; a sub-phase is done when its **Done when** line is true.

**Naming:** Skill → **Hops**, Stone → **Frog**, Throw → **Hop**, Throw Zone → **Hop Zone**, Relic → **Legend Frog**. Reference: [[Stone Skipping UI Breakdown]].

| Phase | Goal | Sub-phases |
|---|---|---|
| 0 – Foundation ✅ | Rojo, saving, greybox loop, vault | done 2026-10-12 |
| [[Phase 1 - Core Systems]] | Core gameplay systems | 1.1 Multipliers ✅ · 1.2 Levels ✅ · 1.3 Training ponds ✅ · 1.4 Hop Zone + toss ✅ · 1.5 Distance + camera · 1.6 River biomes · 1.7 🧪 |
| [[Phase 2 - Collection]] | Always something to unlock | 2.1 Frog podiums · 2.2 Eggs + hatch · 2.3 Pets · 2.4 Trails · 2.5 Inventory · 2.6 🧪 |
| [[Phase 3 - Retention]] | Come back tomorrow | 3.1 Tutorial · 3.2 Potions · 3.3 Daily rewards · 3.4 Offline · 3.5 Friend Boost · 3.6 Gifts · 3.7 Polish · 3.8 🧪 |
| [[Phase 4 - Monetization]] | Full shop | 4.1 Framework · 4.2 Shop · 4.3 Passes · 4.4 Packs · 4.5 Robux ponds · 4.6 Limited items · 4.7 Eggs & extras · 4.8 Gifting · 4.9 🧪 |
| [[Phase 5 - Interface]] | UI matches the references | 5.1 Design system · 5.2 HUD · 5.3 Menus · 5.4 Animations · 5.5 World UI · 5.6 Juice · 5.7 Mobile/console · 5.8 🧪 |
| [[Phase 6 - Spectacle]] | Clip-worthy | 6.1 Models · 6.2 VFX · 6.3 Ultimate hop · 6.4 Audio · 6.5 Art pass · 6.6 🧪 |
| [[Phase 7 - Worlds]] | Long-term progression | 7.1 Framework · 7.2 Portals · 7.3–7.6 Worlds 2–5 · 7.7 🧪 |
| [[Phase 8 - Live Ops]] | Launch | 8.1 Leaderboards · 8.2 Events · 8.3 Analytics · 8.4 Hardening · 8.5 Performance · 8.6 Launch kit · 8.7 🧪 |

**Systems first, interface second.** Phases 1–4 build every system with just enough UI to test it. Phase 5 then builds the real interface once, against final data, so screens aren't redone each time a system changes.

## ⭐ Where to start: 1.1 → 1.2 → 1.3
**Status:** 1.1 ✅ · 1.2 ✅ · HUD first pass ✅ · 1.3 Training ponds ✅ · 1.4 Hop Zone + toss ✅ · next is **1.5 Distance + camera**. Every phase ends with a 🧪 playtest step ([[Testing Guide]]).
1. **1.1 Multiplier pipeline.** Ponds, levels, potions, friend boost, passes, trails and Robux ponds all feed one multiplier. Building that pipe first means every later system plugs in with one line instead of a rewrite. It's small and invisible, and it blocks the most work.
2. **1.2 Levels.** The Level bar is the centrepiece of the reference HUD, and its "MAX LEVEL until you rebirth" rule is what drives rebirths. It's the first real user of 1.1.
3. **1.3 Training ponds.** The main way players earn Hops, and the first system that uses rebirths as a gate.

After that, 1.4 → 1.6 finish the hop itself (Hop Zone + toss, distance tracking, biomes).

**Why not start with the flashy parts (models, VFX, worlds)?** Their look depends on the final loop and HUD; doing them first means redoing them later.

See also: [[Balancing]], [[Monetization]], [[Core Loop]].
