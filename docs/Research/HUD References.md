---
tags: [research, ui]
---
# HUD References

Screenshots of top "+1" / incremental simulators, compared side by side to decide the Frog Hop HUD for [[Phase 5 - Interface|5.2]]. Images live in `docs/Research/References/`.

## The games
| # | Game | Screenshot |
|---|---|---|
| A | +1 Stone Skipping | ![[stoneskip-hud-tutorial.webp]] |
| B | Web game ("Total Web") | ![[web-game-hud.webp]] |
| C | Height game ("+1M Tall") | ![[height-game-hud.webp]] |
| D | Chopper game ("Strength / Wood") | ![[chopper-game-hud.webp]] |
| E | Strength game ("Arms") | ![[strength-game-hud.webp]] |

## What they all share
| Element | A | B | C | D | E | Verdict for Frog Hop |
|---|---|---|---|---|---|---|
| **Level bar, wide, bottom-centre** ("Level N   x/y") | ✅ | ✅ | ✅ | top | ✅ | **Bottom-centre, wide** |
| **Main stat above the bar, left** ("125 SKILL", "0 Height") | ✅ | ✅ (centred) | ✅ | over head | ✅ (centred) | **"🐸 125 HOPS" left** |
| **Multiplier above the bar, right** ("x1 Multiplier") | ✅ | – | ✅ | – | – | **"x1 Multiplier" right** |
| **3 Robux stat packs under the bar** (+10K/+100K/+1M), price chip in corner | ✅ | – | ✅ (+ "+" button) | ✅ (under top bar) | right column | **3 packs + "+" under the bar** |
| **Tutorial/quest text, top-centre** ("GET 2 WINS (1/2)", "Tap to Train (0/5)") | ✅ box | ✅ big text | ✅ box | hint text | ✅ + hand icon | **Top-centre quest bar** |
| **Rebirths + Wins counters with big icons, left** | bottom-left | top-left | bottom-left | left stack | top-left | **Bottom-left** (A, C) |
| **Friend Boost +0% with "+" invite** | ✅ | icon | ✅ | "Invite 0%" button | icon "+0%" | **Bottom-left, under Wins** |
| **Square icon buttons, 2-wide grid, left** (Shop, Rebirth, Pets, Trails, Daily, Gifts…) | column | ✅ 2×3 | – | ✅ 2×3 | ✅ 2×2 | **2×3 grid, left-middle** |
| **Badges on buttons**: "!" (ready), "OP!", "NEW!", % progress, countdown timer | ✅ | ✅ | – | ✅ | ✅ | **Badge slot on every button** |
| **Pass cards, right side** ("x2 Wins Forever!", "x99 Stacks!", "Permanent! 2X") | ✅ | ✅ | – | – | ✅ | **2–3 cards, right-middle** |
| **Free / timed gift, right or bottom** | gift | timer 02:29 | – | – | "Free" | **Right, under passes** |
| **Auto toggle** ("OP Auto Clicker OFF", "AUTO CHOP") | AUTO THROW top | – | – | ✅ top-right | – | **Top-right** |
| **Ground arrows / beam to the next objective** | ✅ arrows | ✅ beam | – | ✅ arrows | – | **Arrows to quest target** (Phase 3.1) |
| **Limited stock item in the world** ("946/1000", "157/1000") | ✅ | – | – | – | ✅ | Phase 4.6 |
| **Timed world events** ("Legendary spawns in 05:26") | Halloween countdown | – | – | – | ✅ | Phase 7.2 |
| **In-world signs** (STAGE 1 / VIP x2 Wins / Spin Wheel / Group Chest) | ✅ | ✅ | ✅ | ✅ | ✅ | Signs over every interactable |
| Settings gear + invite, bottom-right | – | ✅ | – | – | – | Bottom-right |

## Visual style (all five)
- **Thick dark outlines** on every panel and button; **white text with a heavy black stroke**.
- Panels use a **studded "brick" texture** with bright gradients: yellow, red, blue, pink, rainbow.
- **Robux price chips**: a green hex icon + number in a button's bottom-right corner.
- **Tilted sticker tags** on buttons ("OP!", "NEW!", "Forever!", "Stacks!").
- Big, chunky, readable at phone size. Text never sits on the 3D world without a stroke.

## Frog Hop HUD layout (spec for 5.2)
```
┌──────────────────────────────────────────────────────────────┐
│ [Roblox]            [ QUEST: Get 2 Wins (1/2) ]   [AUTO HOP] │
│                                                              │
│ ┌────┬────┐                                  [x2 Wins  ◆90 ] │
│ │Shop│Rbth│                                  [x2 Hops  ◆90 ] │
│ ├────┼────┤                                  [Free gift 2:29]│
│ │Pets│Trls│                                                  │
│ ├────┼────┤                                                  │
│ │Dly!│Gift│             [ HOP! ] (Hop Zone only)             │
│ └────┴────┘                                                  │
│ 🔁 2        🐸 125 HOPS                  x5 Multiplier        │
│ 🏆 1.2K     [ Level 13 ███████░░░░░░░░░░░░░   5 / 10 ]       │
│ Friend +0%  [ +10K ◆10 ][ +100K ◆41 ][ +1M ◆86 ][+]   ⚙ 👥  │
└──────────────────────────────────────────────────────────────┘
```
- Slots that later phases fill in stay visible but empty or disabled now: quest bar (3.1), Daily (3.3), Gifts (3.6), Friend Boost (3.5), passes/packs/Auto (4.x), Trails (2.4).
- The multiplier text is tappable and opens the breakdown from [[Architecture#Multipliers]].

## Still missing (please send if you can)
- The **Shop** menu open (passes / products tabs)
- **Pets** inventory open, and an **egg hatch** in progress
- **Rebirth** menu open
- **Inventory / Index** menu
- The **AUTO** pad toggle and **Auto Throw** button, close up
- A phone screenshot of any of these games (mobile layout)
