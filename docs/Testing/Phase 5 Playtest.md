---
tags: [testing, phase5]
status: ready
---
# Phase 5 Playtest

> Ready to run. Setup: [[Testing Guide]]. Without uploaded images the game shows emoji icons and 3D pet views; after uploading (see [[Decisions]]) it should look like the previews in [[Phase 5 - Interface]].

## Before uploading images
- [ ] HUD layout matches [[HUD Preview.png]] (emoji in place of icons is fine)
- [ ] No errors in Output when opening every menu

## After uploading icons / studs / pets / frogs sheets (ids in `Config/UiImages.luau`)
- [ ] Left tiles show 3D icons poking out of dark tiles; studs on level bar, packs, passes, tutorial bar, buttons
- [ ] Pass cards have bolt / trophy icons over their top edge; Auto Hop has a crown
- [ ] Pet and frog pictures in Inventory, Daily (Day 2 Fortune Neko, Day 7 Shooting Star Frog), Gifts, egg signs, hatch screen

## HUD
- [ ] Hops and Wins roll up when they increase; jump down on rebirth
- [ ] Buttons and tiles grow a little on hover and squish on click
- [ ] Clicking "x… Multiplier" opens the breakdown above it (sized to its lines)
- [ ] On a pond: AUTO REBIRTH button with icon and "ONLY ⏣ 99" (or ON/OFF if owned)
- [ ] Toasts are rounded coloured pills; the landing banner appears mid-screen, not over the distance meter

## Menus
- [ ] Every menu: world is blurred behind it, translucent panel, big 3D icon top-left, red X top-right; the tip ticker hides while it's open
- [ ] Rebirth window is short (no empty space); bolt cards, studded progress bar
- [ ] Daily Rewards: orange DAY tabs, reward pictures, CLAIMED overlays on past days, today outlined green, rainbow Day 7 "Limited!"
- [ ] Shop: Starter Pack icon + content tiles with icons; pass rows with icons

## Hatch & world
- [ ] Hatch reveal: pet picture, name, chance, tilted NEW!, ⚡ +bonus, "Click to continue" (compare [[Hatch Preview.png]])
- [ ] Egg signs: name + price from afar; walking up shows the odds panel with pet pictures and E / R / T keys (compare [[Egg Signs Preview.png]])
- [ ] Pond signs show the rebirth icon pill; frog podium signs show name, ⚡ Hops, 🏆 price
- [ ] Frogs everywhere (podiums, in hand, hopping) are cube frogs; Kings wear crowns, Ninja a headband, Astro a helmet
