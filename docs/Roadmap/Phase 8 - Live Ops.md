---
tags: [planning, phase8]
---
# Phase 8 – Live Ops & Launch
*Goal: ship it and keep it fresh.* Back to [[Roadmap]].

## 8.1 Leaderboards ✅
- [x] Best Distance, Time Played, Top Supporters (Robux spent) — OrderedDataStores, refreshed every 60 s
- [x] Three boards behind the frog podiums in every hub (`Config/Leaderboards`)
- [x] `stats.timePlayed` and `stats.robuxSpent` tracked in player data (products + passes)
## 8.2 Seasonal events ✅
- [x] Event framework (`Config/Events`): start/end times, currency, event pets + egg
- [x] First event: **Halloween** (24 Oct – 3 Nov 2026 UTC): Candy Corn from river hops (zone number per hop), Pumpkin Egg with 4 event pets, pumpkins in Lily Valley
- [x] HUD countdown pill, egg stand/sign only while running, `/event` test command
- [ ] Event UI polish → [[Phase 5 - Interface]]; event models/music → [[Phase 6 - Spectacle]]
## 8.3 Analytics ✅
- [x] Onboarding funnel (Creator Dashboard → Analytics → Funnels): Joined → First Hops → First River Hop → Bought a Frog → Hatched an Egg → First Rebirth → Reached World 2
- [x] Economy sinks: Wins spent on frogs, eggs, trails
## 8.4 Hardening ✅
- [x] Every remote rate-limited per player (`Config/Security`) and error-isolated (`Remotes.handle`)
- [x] Session-locked saves: a second server waits for the first to let go, then kicks with "rejoin" instead of loading a copy (stops rejoin duplication)
- [x] Existing saves convert automatically to the new locked format
## 8.5 Performance pass 🟡
- [x] Generated parts don't fire touch events; river props cast no shadows and skip raycasts
- [ ] Measure in Studio (see [[Phase 8 Playtest]]): part count, FPS on a low-end phone emulator, memory
- [ ] Then decide: StreamingEnabled (needs client code to tolerate unloaded worlds) vs fewer props
## 8.6 Launch kit 🟡
- [x] Store page text, tags and publish checklist: [[Launch Kit]]
- [ ] Icon, thumbnails, trailer — after the Phase 6 models (rendered in Blender)

## 8.7 Playtest 🧪
- [x] I write the test plan: [[Phase 8 Playtest]], plus `/event`
- [ ] You run it in Studio (see [[Testing Guide]]) and report issues
- [ ] Fix everything found, re-test, then the phase is closed
- **Done when:** every check in the playtest note passes.
