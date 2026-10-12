---
tags: [planning, phase1]
---
# Phase 1 – Core Loop
*Goal: the moment-to-moment loop feels like Stone Skipping.* Back to [[Roadmap]].

## 1.1 Stat & multiplier pipeline ✅ (2026-10-12)
Every later system (ponds, levels, potions, friend boost, passes, trails) adds a multiplier. Build the pipe once.
- [x] Refactor `Stats.luau` into a **modifier stack**: named sources (rebirth, level, pond, pets, potions, friends, passes, trails) → one `hopsMultiplier` / `winsMultiplier` / `luck`
- [x] Send the breakdown to the client (for a "why is my multiplier x12?" tooltip later)
- [x] Unit-style sanity checks in `tools/luau-check` for the maths
- [x] Luck stat wired into egg hatching (multiplies Rare+ weights)
- **Done when:** adding a new boost is one line in one file.

## 1.2 Level system ✅ (2026-10-12)
- [x] XP from pads hopped (not Hops, so multipliers don't trivialise it); `xpForLevel(n)` curve in `Config/Levels.luau`
- [x] Level adds to the multiplier (via 1.1)
- [x] **Level cap per rebirth** (cap 20 at rebirth 0, +20 per rebirth); rebirth now requires MAX LEVEL, "MAX LEVEL" state
- [x] Level-up pop + sound hook
- **Done when:** the Level bar fills, caps, and rebirth raises the cap.

## 1.3 HUD rework (reference layout) ⭐ NEXT
- [ ] Bottom centre: Hops (left) + xMultiplier (right) above the **Level bar**
- [ ] Bottom-left: Rebirths, Wins, Friend Boost (placeholder 0%)
- [ ] Left side menu column (Shop, Rebirth, Pets, Trails, Inventory, Gifts), icons + notification-dot slot
- [ ] Right side pass-button column (placeholders)
- **Done when:** the screen matches the reference layout, with empty slots for later systems.

## 1.4 Training ponds row
- [ ] `Config/Ponds.luau`: ponds gated by rebirths (0→1x, 2→4x, 4→10x, 6→20x)
- [ ] World: ponds in a row with LOCKED/UNLOCKED + requirement signs
- [ ] Each pond has a **training pad**; standing on it trains, with "+N Hops" pops per bounce
- [ ] **AUTO** toggle on the pad (free)
- **Done when:** a new player trains in pond 1 and sees pond 2 locked behind 2 rebirths.

## 1.5 Hop Zone + hold-and-toss
- [ ] Painted **Hop Zone** strip at the river start; the HOP button shows only while you stand on it
- [ ] Equipped frog held in the character's hand (tool/weld)
- [ ] Wind-up + toss animation, then the frog leaves the hand and starts hopping
- **Done when:** pressing HOP in the zone plays toss → hop with no visual gap.

## 1.6 Distance meter + camera
- [ ] Live "123 m" meter at the top while the frog travels
- [ ] Smooth camera follow, return to the player on landing
- [ ] Landing result card (zone, Wins, best distance)
- **Done when:** a hop is readable without looking at the stats.

## 1.7 River biomes
- [ ] Zones become biome sections with floating names and bank colours
- [ ] Zone-cross toast and banner (already partly built)
- **Done when:** you can tell which zone you're in at a glance.

## 1.8 Playtest 🧪
- [ ] I write the test plan: [[Phase 1 Playtest]], plus any new test commands
- [ ] You run it in Studio (see [[Testing Guide]]) and report issues
- [ ] Fix everything found, re-test, then the phase is closed
- **Done when:** every check in the playtest note passes.
