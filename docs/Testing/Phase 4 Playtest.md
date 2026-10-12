---
tags: [testing, phase4]
status: ready
---
# Phase 4 Playtest

> Ready to run. Setup: [[Testing Guide]]. Real purchases need the ids from [[Monetization Setup]]; until then use the Studio commands below.

## Without ids (Studio)
- [ ] Every Robux button says "<item>: not on sale yet"
- [ ] `/grant doublehops` → "+2x HOPS" card says OWNED, multiplier doubles; `/grant autohop` → AUTO HOP becomes ON/OFF and repeats river hops
- [ ] `/grant hatchocto` → R at an egg hatches 8; `/grant pondcosmic` → Cosmic Pond unlocks
- [ ] `/buy hopspack3` → +1M Hops; `/buy starterpack` → Starter Pack card turns OWNED
- [ ] `/buy rainbowegg` → hatch screen with a Rainbow Egg pet; `/buy phoenixfrog` → Phoenix Frog equipped, podium stock drops by 1
- [ ] `/buy potionpack` → 3 of each potion; `/buy skiprebirth` → rebirth without max level
- [ ] Shop › Gift with 2 players (Test → 2 Players): picker cycles players; gift buttons say "not on sale yet"

## With ids (published game, real Robux or a test account)
- [ ] Buying a product grants it once; reconnecting during purchase doesn't grant it twice
- [ ] Gifting a pass to a friend: they get a "🎁 You got a gift!" banner and own it after rejoining
