---
tags: [planning, phase5]
---
# Phase 5 – Interface
*Goal: every screen looks and feels like the references. All systems exist by now (Phases 1–4), so the UI is built once against final data.* Back to [[Roadmap]]. References: [[HUD References]], [[Stone Skipping UI Breakdown]].

> **How we work (decided 2026-10-12): no Figma.** I design and build every screen in Luau from the references; you review it in Studio and send screenshots + feedback. Order: Design System → HUD → Menus → Hatch → World UI.

> **Preview tool:** `tools/ui-preview` runs the real UI code offline and screenshots it, so every screen is checked against the references before it reaches Studio. Current HUD: ![[HUD Preview.png]]

## 5.1 Design system 🟡
- [x] Fonts/tokens: Fredoka One, near-black 3px outlines, dark glassy tiles, silver/colour gradients
- [x] 27 glossy 3D icons rendered in Blender (`tools/blender/build_icons.py`) packed into **one sheet** (`assets/textures/ui/icons.png`, layout `Config/IconAtlas`) — emoji until uploaded
- [x] Stud texture (`assets/textures/ui/studs.png`) on bars, packs, passes, buttons
- [x] Components: `Icon` (sheet icon or emoji), `Studs`, restyled `IconTile`, `PassCard`
- [ ] Upload the 2 images ([[Decisions]])

## 5.2 HUD to reference 🟡
- [x] HUD restyled to the references with the preview tool: icon tiles, bolt stat row, studded level bar + packs with bolts, icon pass cards, crowned Auto Hop, studded tutorial bar, icon counters, frog HOP button, potion timers with icons
- [ ] Check in Studio and fine-tune
- [ ] Tile grid, pass cards, Auto Hop, Level bar + stat row + packs, bottom-left counters, quest bar
- [ ] Badges (! / % / NEW! / timers) driven by real systems

## 5.3 Menus pass 🟡
- [x] Window: translucent panel, blurred world, 3D corner icon, icon close button, per-menu height, studded buttons
- [x] Shop (starter icon, content tiles, pass icons), Rebirth (studded bolt cards, studded bar), Daily (DAY tabs, reward pictures, CLAIMED overlay, rainbow Day 7), Gifts (reward pictures), Inventory tabs with icons, pet and frog pictures on cards — ![[Daily Preview.png]]
- [x] Frogs rebuilt as cube frogs (pet builder) with per-frog extras; pet/frog picture sheets (`pets.png`, `frogs.png`)
- [ ] My Pets details panel, Sort, Index; Settings menu

## 5.4 Reward & hatch animations 🟡
- [x] Egg hatch reveal to the reference: floating pet picture, name, chance, tilted NEW!, bolt +bonus, lighter overlay — ![[Hatch Preview.png]]
- [ ] Level up, rebirth, purchase, daily claim celebrations

## 5.5 World UI 🟡
- [x] Egg signs: name + price from afar, odds panel with pet pictures and E / R / T keys up close — ![[Egg Signs Preview.png]]
- [x] Pond signs (rebirth-icon pill, UNLOCKED/LOCKED, bolt + multiplier) and frog podium signs (status, name, bolt Hops, trophy price, Phoenix stock)
- [ ] Zone names, portal gates, leaderboards styling

## 5.6 Feedback & juice 🟡
- [x] Hover grow + press squish on every button and tile, click/hover sound hooks (`Sfx`, ids in `Config/Sounds`), Hops/Wins count up
- [x] Toast pills, landing banner mid-screen, Auto Rebirth with icon, multiplier breakdown panel
- [ ] Sound ids (Phase 6.4)

## 5.7 Mobile & console layouts
- [ ] Phone layout (scaled tiles, thumb-reach HOP button), tablet, gamepad navigation

## 5.8 Playtest 🧪
- [x] I write the test plan: [[Phase 5 Playtest]]
- [ ] You run it in Studio (see [[Testing Guide]]), we fix what you find
- **Done when:** every check in the playtest note passes.
