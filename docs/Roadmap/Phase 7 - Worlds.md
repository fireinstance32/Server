---
tags: [planning, phase7]
---
# Phase 7 – Worlds
*Goal: long-term progression.* Back to [[Roadmap]].

## 7.1 World framework ✅
- [x] `Config/Worlds.luau`: id, name, Hops gate, Wins scale, map offset; `worldsUnlocked` in player data
- [x] Every hub (plaza, Hop Zone, river, ponds, podiums, eggs) built from the same local layout, moved along +Z per world
- [x] Server and client turn a world position into (world, local position) and reuse the World 1 layout code
- [x] Per-world content in `Config/WorldContent/<World>.luau` (frogs, pets, eggs, river zones); Wins scale per world
- **Done when:** a new world is one `Worlds` entry + one content file (unit-tested in `WorldContent.spec`).
## 7.2 Portals & travel ✅
- [x] A portal to every other world in each hub, signed "WORLD N – Unlock with X Hops"
- [x] Walking up and pressing E travels; first trip with enough Hops unlocks the world permanently
- [x] Frogs and eggs from a locked world can't be bought; `/world <id>` test command
- [ ] Teleport menu for unlocked worlds → Phase 5 (UI)
- *Gate is Hops held (not distance), like the reference "World 2" buttons.*
## 7.3 World 2 – Mushroom Swamp ✅
- [x] 1M Hops gate · Wins x25 · 4 frogs · Swamp + Mushroom eggs (6 pets) · 9 swamp zones
## 7.4 World 3 – Candy Falls ✅
- [x] 50M Hops gate · Wins x600 · 4 frogs · Candy + Cupcake eggs (6 pets) · 9 candy zones
## 7.5 World 4 – Cosmic Cove ✅
- [x] 2.5B Hops gate · Wins x15K · 4 frogs · Moon + Galaxy eggs (6 pets) · 9 space zones
## 7.6 World 5 – Lava Springs ✅
- [x] 100B Hops gate · Wins x400K · 4 frogs · Ember + Inferno eggs (6 pets) · 9 lava zones
- *Greybox only: same plaza/ponds in every world, biome colours on the river banks. Themed hubs, skyboxes and models come in [[Phase 6 - Spectacle]].*

## 7.7 Playtest 🧪
- [x] I write the test plan: [[Phase 7 Playtest]], plus `/world <id>`
- [ ] You run it in Studio (see [[Testing Guide]]) and report issues
- [ ] Fix everything found, re-test, then the phase is closed
- **Done when:** every check in the playtest note passes.
