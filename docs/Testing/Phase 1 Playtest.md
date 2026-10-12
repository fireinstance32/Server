---
tags: [testing, phase1]
status: draft
---
# Phase 1 Playtest

> Draft – filled in as Phase 1 steps land. Run it once 1.7 is done. Setup: [[Testing Guide]].

## 1.1 Multipliers
- [ ] New player (`/reset`): stats panel shows **Hops x1 • Wins x1**
- [ ] `/rebirths 2` → Hops multiplier rises (x3 from rebirths, plus level bonus)
- [ ] Hatch a pet → Hops multiplier rises by the pet's bonus

## 1.2 Levels
- [ ] Training fills the **Level bar**; a "LEVEL N!" toast appears on level up
- [ ] A long river hop can give several levels at once
- [ ] `/level 19` then train → reaches **Level 20 – MAX LEVEL**, bar turns gold, big banner
- [ ] At MAX LEVEL, XP stops but Hops keep going up
- [ ] Rebirth menu shows **Level 20 / 20**; Rebirth works → Level 1, cap now 40
- [ ] Rebirth below max level shows "Reach Level N to rebirth"
- [ ] Leave and rejoin → level and XP are saved

## 1.3 HUD & menus
- [ ] Layout matches [[HUD References#Frog Hop HUD layout (spec for 1.3)]]: tile grid left, pass cards right, AUTO HOP top, Hops / multiplier / Level bar / packs bottom-centre, Rebirths / Wins / Friend Boost bottom-left
- [ ] HOP button only appears at the Training Pond ("TRAIN 💪") or River Dock ("HOP! 🐸"); `/goto train`, `/goto river`
- [ ] AUTO REBIRTH button only shows at the Training Pond
- [ ] Click "xN Multiplier" → breakdown panel lists Rebirths / Pets / Level
- [ ] Rebirth tile badge shows % to max level, "!" at max
- [ ] Every Robux button (packs, passes, Starter Pack, Skip Rebirth, Auto Hop) shows "…: not on sale yet" (ids are still 0)
- [ ] Shop: scrolls through Pack, Passes, Hops, Codes; code WELCOME works once
- [ ] Rebirth window: Before/After shows x1 → x2 (then x2 → x3 after a rebirth); bar shows Level N / Level cap
- [ ] Pets tile opens Inventory on the Pets tab; Equip Best equips your 3 strongest; Inventory tile opens the Frogs tab
- [ ] Trails / Gifts open "Coming soon"
- [ ] Clicking the same tile again closes the window; red ✕ closes it

## 1.4 – 1.7
*(added as each step is built)*
