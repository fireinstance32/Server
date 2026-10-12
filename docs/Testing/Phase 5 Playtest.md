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
- [ ] Left tiles show the pack icons poking out of grey tiles; studs on level bar, packs, passes, tutorial bar, buttons
- [ ] Pass cards have bolt / trophy icons over their top edge; Auto Hop has a crown
- [ ] Pet and frog pictures in Inventory, Daily (Day 2 Fortune Neko, Day 7 Shooting Star Frog), Gifts, egg signs, hatch screen

## HUD
- [ ] Hops and Wins roll up when they increase; jump down on rebirth
- [ ] Buttons and tiles grow a little on hover and squish on click
- [ ] Clicking "x… Multiplier" opens the breakdown above it (sized to its lines)
- [ ] On a pond: AUTO REBIRTH button with icon and "ONLY ⏣ 99" (or ON/OFF if owned)
- [ ] Toasts are coloured outlined text (no pill) under the quest bar, or at the very top while a menu is open; the landing banner appears mid-screen

## Screen sizes
- [ ] Resize the Studio window / use the Device Emulator (phone, tablet): the whole UI shrinks evenly, the right-side buttons stay at the right edge, nothing spills off-screen (`Components/ScreenScale`; tell me if anything sits in the wrong place)

## Menus
- [ ] Every menu pops in (and shrinks away on close), world blurred behind it, big icon top-left, red square X button top-right; Auto Hop, quest bar, tips and the bottom bar hide while it's open and come back after
- [ ] Rebirth window is short (no empty space); bolt cards, studded progress bar
- [ ] Daily Rewards: orange DAY tabs, reward pictures, CLAIMED overlays on past days, today outlined green, rainbow Day 7 "Limited!"
- [ ] Daily: click today's (green-outlined) card to claim; "Next reward in: h:mm:ss" counts down under the window; hovering a card shows the white info card beside it
- [ ] Gifts: 4 cards per row; orange with a red timer while counting down, purple with green CLAIM when ready, blue with a tick once claimed; last gift rainbow
- [ ] Window sizes look like the reference at 1920×1080 and still fit on a small window / phone (ScreenScale)
- [ ] Shop: Starter Pack; gamepasses as coloured cards in 2 columns with a gift button (giftable ones) and price/OWNED; Hops packs 2×2; the gift button opens a player list (test with 2 players)
- [ ] Inventory: big tabs left of the window; title changes to My Frogs / My Pets / My Trails / My Boosts / My Titles
- [ ] My Pets: click a tile → left panel shows it on spinning rays with EQUIP/UNEQUIP, lock, delete; trash "Auto" opens the rarity toggles; Delete asks "Sure?"; sort icon cycles; INDEX swaps the grid
- [ ] My Boosts: click a potion → white card shows it; USE uses one; timer shows on the tile while active
- [ ] Claiming a daily reward or a gift shows a "YOU GOT …" pop-up with the picture on spinning rays + confetti
- [ ] My Titles: "N / 27 Titles"; first throw unlocks Tadpole (toast + appears unlocked); clicking it shows it above your head for everyone; the boost shows in the multiplier breakdown
- [ ] Worlds (globe, top right): World 1 says YOU ARE HERE; locked worlds say NEEDS … HOPS and LOCKED; with enough Hops it says UNLOCK and teleports

## Settings & pets
- [ ] Gear button (top right) opens Settings; volume sliders drag smoothly and save on release; each toggle flips ON/OFF; everything stays after rejoining
- [ ] Camera Shake OFF: no shake on landings / ultimate hop; ON: a small thump per landing, a big one on the ultimate
- [ ] Sound effects OFF: no UI/game sounds; Big effects OFF: no droplets/confetti (ripples stay); other players' pets OFF: their pets vanish for you only (test with 2 players)
- [ ] My Pets: Sort cycles Best → Rarity → Name (equipped stay first); INDEX shows every pet, unhatched as black silhouettes with ???

## Hatch & world
- [ ] Hatch reveal: pet picture, name, chance, tilted NEW!, ⚡ +bonus, "Click to continue" (compare [[Hatch Preview.png]])
- [ ] Egg signs: name + price from afar; walking up shows the odds panel with pet pictures and E / R / T keys (compare [[Egg Signs Preview.png]])
- [ ] Portal signs: OPEN (portal icon) for unlocked worlds, UNLOCK! when you have the Hops, padlock + "1M HOPS" otherwise
- [ ] Leaderboard boards: coloured title banner, striped rows, top 3 in gold/silver/bronze
- [ ] Pond signs show the rebirth icon pill; frog podium signs show name, ⚡ Hops, 🏆 price
- [ ] Frogs everywhere (podiums, in hand, hopping) are cube frogs; Kings wear crowns, Ninja a headband, Astro a helmet
