---
tags: [planning, phase1]
---
# Phase 1 – Core Systems
*Goal: every core gameplay system works like Stone Skipping. Systems only: screens get just enough UI to test them; the real interface is built in [[Phase 5 - Interface]].* Back to [[Roadmap]].

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

## 1.3 Training ponds row ✅ (2026-10-12)
- [x] `Config/Ponds.luau`: ponds gated by rebirths (0→1x, 2→4x, 4→10x, 6→20x) + Robux ponds valid in all worlds (3x / 15x / 50x)
- [x] World: ponds in a row with LOCKED/UNLOCKED + requirement signs
- [x] Each pond has a **training pad**; standing on it trains, with "+N Hops" pops per bounce
- [x] Standing on an unlocked pad **trains automatically** (no toggle, no button); Auto Hop pass is launch-only
- [x] Pond multiplier added to the boost list (`Stats` → "Pond"); server checks the pad and the unlock
- [x] Signs drawn per player (lock state differs per player)
- **Done when:** a new player trains in pond 1 and sees pond 2 locked behind 2 rebirths.

## 1.4 Hop Zone + hold-and-toss ✅ (2026-10-12)
- [x] Painted **Hop Zone** strip at the river start; the HOP button shows only while you stand on it
- [x] Equipped frog held in the character's hand (tool/weld)
- [x] Wind-up + toss animation, then the frog leaves the hand and starts hopping
- Notes: the held frog is built on the server (everyone sees it) and hides while the frog is out; the arm swing is procedural and local-only until Phase 6 adds a real animation.
- **Done when:** pressing HOP in the zone plays toss → hop with no visual gap.

## 1.5 Distance tracking + camera ✅ (2026-10-12)
- [x] Live "123 m" meter at the top while the frog travels
- [x] Smooth camera follow, return to the player on landing
- [x] Landing result card (zone, Wins, best distance)
- **Done when:** a hop is readable without looking at the stats.

## 1.6 River biomes ✅ (2026-10-12)
- [x] Zones become biome sections with floating names and bank colours
- [x] Zone-cross toast and banner (already partly built)
- **Done when:** you can tell which zone you're in at a glance.

## 1.7 Playtest 🧪 ⭐ READY FOR YOU
- [ ] I write the test plan: [[Phase 1 Playtest]], plus any new test commands
- [ ] You run it in Studio (see [[Testing Guide]]) and report issues
- [ ] Fix everything found, re-test, then the phase is closed
- **Done when:** every check in the playtest note passes.

---
*HUD first pass (old 1.3) was done on 2026-10-12: layout, tile grid, pass cards, menus. Matching the references exactly continues in [[Phase 5 - Interface]].*
