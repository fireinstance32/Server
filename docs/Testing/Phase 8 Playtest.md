---
tags: [testing, phase8]
status: ready
---
# Phase 8 Playtest

> Ready to run. Setup: [[Testing Guide]]. Leaderboards and saves need **Game Settings → Security → Enable Studio Access to API Services**.

## Leaderboards
- [ ] Three boards behind the frog podiums (Best Distance, Time Played, Top Supporters) in Lily Valley and every other hub
- [ ] Do a river hop, wait ~1 min: you appear on Best Distance (metres)
- [ ] Stay ~2 min: Time Played shows minutes; it keeps counting after rejoining
- [ ] Studio without API access: boards say "Loading..." and Output shows **one** warning per board, not a spam

## Events
- [ ] `/event halloween` → orange pill under the Daily button: "🎃 Halloween event · … left", Candy Corn count
- [ ] Pumpkins appear around spawn; the Pumpkin Egg stand (left of the Common Egg) appears with its sign "🎃 25 Candy Corn"
- [ ] River hop → landing card adds "+N 🎃" (N = zone number); pill count goes up
- [ ] `/event halloween 100` → 100 more Candy Corn; E at the Pumpkin Egg hatches an event pet, cost comes off Candy Corn (Wins unchanged)
- [ ] `/event none` → pill, pumpkins and Pumpkin Egg stand/sign disappear; E there does nothing
- [ ] `/event auto` → back to the calendar (off until 24 Oct)

## Hardening
- [ ] Normal play (auto-train, auto-hatch with E/R/T, Auto Hop) never shows "Slow down!"
- [ ] Spamming a button (e.g. Claim on a gift, Rebirth) shows "Slow down!" instead of breaking anything
- [ ] Data still saves and loads (change Hops, leave, rejoin); old saves from earlier playtests load fine
- [ ] Published game, 2 servers: join server A, then join server B right away → B waits and either loads your latest data or kicks with "still saving… rejoin" — never an older copy

## Analytics (published game only, data shows up after ~1 day)
- [ ] Creator Dashboard → Analytics → Funnels shows the Onboarding funnel steps
- [ ] Economy → Wins sinks show Frog / Egg / Trail spending

## Performance (record the numbers in the devlog)
- [ ] View → Stats / Developer Console (F9) → Memory: note total MB and `PhysicsParts` / Instances count
- [ ] Play with the device emulator (Test → Device → a low-end phone): FPS in Lily Valley and in Lava Springs
- [ ] MicroProfiler (Ctrl+F6) during a long river hop: no frame spikes over ~33 ms
