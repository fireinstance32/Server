---
tags: [testing, phase2]
status: ready
---
# Phase 2 Playtest

> Ready to run. Setup: [[Testing Guide]].

## 2.1 Frog podiums
- [ ] A row of 11 pedestals along the south side of the plaza, each with its frog on top
- [ ] Signs: Baby Frog "EQUIPPED"; others "LOCKED · +N Hops · 🏆 price Wins"; Phoenix "ONLY ◎ 199"
- [ ] Walk up → prompt "Buy" (or "Equip" once owned); buying with enough Wins unlocks + equips it, sign turns UNLOCKED/EQUIPPED, frog in hand swaps
- [ ] Not enough Wins → "Not enough Wins" toast (`/wins 100000` to test)
- [ ] Phoenix prompt shows "not on sale yet"
- [ ] The old Frog Shop stand is gone

## 2.2 Eggs + hatch flow
- [ ] Four egg stands south of spawn: Common (white), Uncommon (green), Rare (blue), Rainbow (pink)
- [ ] Each has a sign: name, price, every pet with "+bonus" and % chance, "E Hatch · R Multi · T Auto"
- [ ] E at Common Egg (with 50+ Wins): screen blurs, HUD hides, egg appears → click → it wobbles → reveal card: name (rarity colour), chance %, NEW! the first time, ⚡ +bonus → click to continue → HUD back
- [ ] The pet follows you and the multiplier goes up by its bonus (e.g. x1 → x2 with a +1 pet)
- [ ] R without the pass → "+3 Eggs: not on sale yet"; T → auto-hatches until you walk away or run out of Wins (screens advance by themselves)
- [ ] Rainbow Egg E → "Rainbow Egg: not on sale yet"
- [ ] `/rebirths 1` → multiplier shows x2 (rebirths add +1 each)

## 2.3 Pets
- [ ] Pets tab header: "🎒 n / 50 · Equipped n / 3 (+bonus) · Index n / 15"
- [ ] 🔓 → 🔒 locks a pet; locked pets have no 🗑 and survive Delete Unequipped
- [ ] 🗑 deletes one pet; "Delete Unequipped" asks "Tap again!" then deletes every unequipped, unlocked pet
- [ ] Auto Delete: turn on Common, hatch Common Eggs → already-discovered Commons show "AUTO DELETED" on the reveal and don't enter the inventory
- [ ] Equip Best equips your 3 highest bonuses

## 2.4 Trails
- [ ] Trails tile opens the Trails window: Leaf 1K, Bubble 10K, Firefly 50K, Sunset 250K (Wins), Rainbow ◎99, Void ◎149
- [ ] Buying a Wins trail equips it; the multiplier rises by its bonus (breakdown shows "Trail")
- [ ] River hop: the frog leaves a coloured trail
- [ ] Unequip removes the trail and its bonus; Robux trails show "not on sale yet"

## 2.5 Inventory
- [ ] Inventory tile: tabs Frogs, Pets, Trails, Boosts (coming soon), Titles (coming soon); all fit
