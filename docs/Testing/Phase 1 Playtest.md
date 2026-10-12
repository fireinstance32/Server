---
tags: [testing, phase1]
status: ready
---
# Phase 1 Playtest

> Ready to run. Setup: [[Testing Guide]]. Report anything that fails (what you did → expected → what happened, + Output window screenshot).

## 1.1 Multipliers
- [ ] New player (`/reset`): stats panel shows **Hops x1 • Wins x1**
- [ ] `/rebirths 2` → Hops multiplier rises (+2 from rebirths → x3, plus level bonus)
- [ ] Hatch a pet → Hops multiplier rises by the pet's +bonus

## 1.2 Levels
- [ ] Training fills the **Level bar**; a "LEVEL N!" toast appears on level up
- [ ] A long river hop can give several levels at once
- [ ] `/level 19` then train → reaches **Level 20 – MAX LEVEL**, bar turns gold, big banner
- [ ] At MAX LEVEL, XP stops but Hops keep going up
- [ ] Rebirth menu shows **Level 20 / 20**; Rebirth works → Level 1, cap now 40
- [ ] Rebirth below max level shows "Reach Level N to rebirth"
- [ ] Leave and rejoin → level and XP are saved

## HUD first pass (layout, menus)
- [ ] Layout matches [[HUD References#Frog Hop HUD layout (spec for 5.2)]]: tile grid left, pass cards right, AUTO HOP top, Hops / multiplier / Level bar / packs bottom-centre, Rebirths / Wins / Friend Boost bottom-left
- [ ] HOP button only appears at the Hop Zone ("HOP! 🐸") or on a locked pond; `/goto pond 1`, `/goto river` (Hop Zone)
- [ ] AUTO REBIRTH button only shows on a pond pad
- [ ] Click "xN Multiplier" → breakdown panel lists Rebirths / Pets / Level
- [ ] Rebirth tile badge shows % to max level, "!" at max
- [ ] Every Robux button (packs, passes, Starter Pack, Skip Rebirth, Auto Hop) shows "…: not on sale yet" (ids are still 0)
- [ ] Shop: scrolls through Pack, Passes, Hops, Codes; code WELCOME works once
- [ ] Rebirth window: Before/After shows x1 → x2 (then x2 → x3 after a rebirth); bar shows Level N / Level cap
- [ ] Pets tile opens Inventory on the Pets tab; Equip Best equips your 3 strongest; Inventory tile opens the Frogs tab
- [ ] Trails / Gifts open "Coming soon"
- [ ] Clicking the same tile again closes the window; red ✕ closes it

## 1.3 Training ponds
- [ ] A row of 7 ponds sits along the north side of the plaza (`/goto pond 1` … `/goto pond 7`)
- [ ] Signs: Starter "🔁 0 · UNLOCKED · 1x HOPS"; Lotus "🔁 2 · LOCKED · 4x HOPS"; Golden/Rainbow/Cosmic "ALL WORLDS ◎ 90/225/540 · LOCKED"
- [ ] Standing on the orange stand pad **trains automatically** (no button); stepping off stops it
- [ ] Training hops the frog around that pond's lily pads; Hops gained = 5 × frog × multiplier
- [ ] On a locked rebirth pond nothing trains and a "🔒 2 REBIRTHS" button appears; a Robux pond shows "UNLOCK ◎90" (shows "not on sale yet" for now)
- [ ] `/rebirths 2` → Lotus turns UNLOCKED; training there shows the "Pond x4" line in the multiplier breakdown
- [ ] AUTO HOP (pass) now only repeats river launches, not training

## 1.4 Hop Zone + hold-and-toss
- [ ] A painted orange **HOP ZONE** strip with blue edges sits where the plaza meets the river; the old dock is gone
- [ ] Your character holds your equipped frog in the right hand; a second player (Test → 2 Players) sees it too
- [ ] Equipping a different frog swaps the one in your hand
- [ ] HOP button shows only while standing on the strip
- [ ] Pressing HOP: character turns to face the river, winds the arm back, swings, and the frog leaves the hand and hops down the river
- [ ] The frog in your hand disappears while it's hopping and comes back when it lands
- [ ] Wins/Hops arrive as it lands (not before the toss)

## 1.5 Distance + camera
- [ ] During a river hop a big "123 m" counts up at the top, with "Best: N m" under it
- [ ] Beating your best turns the number gold and shows NEW BEST!
- [ ] The camera chases the frog smoothly from behind and returns to your character on landing
- [ ] Landing card: "ZONE 3: Mossy Rocks" + "123 m • +8 Wins" (+ "NEW BEST!")

## 1.6 River biomes
- [ ] Each zone's river banks have their own colour/material (green → mossy → slate → mud → sand…)
- [ ] Props line the banks: flowers and reeds early, trees, willows, rocks, mushrooms, palms in Sunset Lagoon / King's Pond
- [ ] The banks and riverbed actually exist (they were missing before this fix)
- [ ] Crossing into a new zone during a hop shows a "Zone N: Name!" toast
