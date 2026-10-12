---
tags: [testing, phase3]
status: ready
---
# Phase 3 Playtest

> Ready to run. Setup: [[Testing Guide]].

## 3.2 Potions
- [ ] `/potion hops 2` → Inventory › Boosts shows "Hops Boost x2"
- [ ] Use → "Hops Boost active! x2"; a "🧪 x2 hops 9:59" timer appears on the left of the HUD and counts down
- [ ] Multiplier doubles; the breakdown lists "Hops Boost x2"
- [ ] Using a second one while active adds 10 more minutes (not x4)
- [ ] When it ends the timer disappears and the multiplier drops back within ~5 s
- [ ] Wins and Luck boosts do the same for Wins earned / egg odds (egg signs' % change)

## 3.3 Daily rewards
- [ ] First join (`/reset` then rejoin): the Daily Rewards window opens by itself after ~2 s; 📅 top-right shows "!"
- [ ] Day 1 highlighted → Claim → "Day 1: 1 Hops Boost!", potion added, ✅ on Day 1, button "Come back tomorrow!"
- [ ] `/daily next` → Day 2 claimable → Fortune Neko pet arrives (+5)
- [ ] Repeat to Day 7 → Shooting Star Frog unlocked (its podium sign says "🎁 Daily Day 7", can't be bought)
- [ ] `/daily next` twice in a row without claiming → back to Day 1 (missed a day)

## 3.4 Offline training
- [ ] Leave the game for 2+ minutes (in Studio: stop, wait, Play again with API access on) → "Welcome back! 🐸 You trained offline for Nm: +X Hops" banner and Hops went up
- [ ] Under 1 minute away → nothing

## 3.5 Friend Boost
- [ ] Alone: "Friend Boost +0%"
- [ ] With a Roblox friend in the same server: "+10%" each (max +50%), and "Friend Boost" appears in the multiplier breakdown (needs a live server with a real friend; Studio test players aren't friends)

## 3.6 Playtime gifts
- [ ] Gifts tile shows a countdown ("00:59") to the first gift, then "!" when it's ready
- [ ] Gifts window: 10 cards with countdowns; ready ones say CLAIM; claiming gives the reward and shows ✅
- [ ] Rejoining starts the timers again (gifts reset each session)

## 3.1 Tutorial quests
- [ ] New player (`/reset`, rejoin): yellow "TUTORIAL" bar: "Train at the Starter Pond (0/50)" and a gold beam to the Starter Pond pad
- [ ] Completing each step shows "✅ Quest complete: … (+reward)" and the bar moves on: Get Wins (x/2) → Buy a new frog → Hatch an egg → Reach Level 20 → Rebirth!
- [ ] The beam points at the Hop Zone, the 2nd frog podium, the Common Egg, the pond in turn; it hides when you're close
- [ ] After the Rebirth quest the bar disappears for good

## 3.7 Polish
- [ ] A rainbow tip line at the very top cycles every ~8 s
- [ ] Badges: Rebirth tile % → "!" at max level; Gifts tile countdown → "!"; 📅 "!" when the daily is ready
