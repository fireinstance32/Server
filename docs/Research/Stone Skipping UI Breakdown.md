---
tags: [research, ui]
---
# Stone Skipping – Systems & UI Breakdown

Taken from the user's screenshots and the 32 s trailer (2026-10-12). Each item maps to a Frog Hop system in [[Roadmap]]. HUD comparison with other games: [[HUD References]].

## Screenshots
| | |
|---|---|
| ![[stoneskip-hud-river.webp]] | ![[stoneskip-throw-zone.webp]] |
| ![[stoneskip-training-pools.webp]] | ![[stoneskip-training-pad.webp]] |
| ![[stoneskip-stone-podiums.webp]] | ![[stoneskip-egg-row.webp]] |
| ![[stoneskip-daily-rewards.webp]] | ![[stoneskip-holding-stone.png]] |
| ![[stoneskip-shop-page1.png]] | ![[stoneskip-shop-page2.png]] |

Trailer frames (1 per second): ![[stoneskip-trailer-1.jpg]] ![[stoneskip-trailer-2.jpg]] ![[stoneskip-trailer-3.jpg]] ![[stoneskip-trailer-4.jpg]]

## HUD
| Where | What | Frog Hop equivalent |
|---|---|---|
| Top centre | **Tutorial quest bar** ("GET 2 WINS (1/2)") | Tutorial quests |
| Top centre | Rainbow marquee tips ("You'll still train offline…") | Tip ticker |
| Top centre | **AUTO THROW** button (Robux) + live **distance meter** ("103 m") during a throw | Auto Hop + distance meter |
| Bottom centre | Skill counter (left) + **xN Multiplier** (right) above a **Level bar** ("Level 50 3.07K/4.05K", "Level 20 MAX LEVEL") | Hops + multiplier + Level bar |
| Bottom centre | 3 Robux packs under the bar: **+10K / +100K / +1M** | Hops packs |
| Bottom-left | Rebirths, Wins, **Friend Boost +0%** with a "+" invite button | Same |
| Left side | Menu: **Shop, Rebirth (100% badge), Pets, Trails, Inventory, Gifts** with red notification dots | Side menu |
| Right side | **Starter Pack**, **2x Skill**, **2x Wins** pass buttons | Pass buttons |
| Pop-up | **Daily Rewards**: 7 days, potions on days 1/3–6, a pet on day 2, limited relic on day 7 | Daily rewards |

## World (hub per world)
- **Training pools in a row**, each gated by rebirths: 0 → 1x, 2 → 4x, 4 → 10x, 6 → 20x. Robux pools valid in **all worlds**: 90 → 3x, 225 → 15x, 540 → 50x. A sign shows LOCKED/UNLOCKED. Standing on a pool's pad gives "+1 Skill" pops per bounce, plus an **AUTO** toggle on the pad.
- **Stone podiums**: every stone stands on its own pedestal with LOCKED/UNLOCKED, "+N Skill" and its Wins price. A **relic** (Robux, "ALWAYS 200% BETTER", **STOCK 997/1000**) sits in front.
- **Egg row**: Common 50, Uncommon 500, Rare 4K (Wins), Rainbow Egg (Robux). In the centre is a **limited premium pet** ("BEST IN GAME, Always 1200% better, STOCK 157/1000"). Ad boards ("ADMIN ABUSE").
- **Hacked Admin Egg** (Robux) placed next to the throw zone.
- **THROW ZONE**: a painted strip at the river start; standing on it shows a big green THROW button.
- **River biomes** with floating names: Palm Beach (Cactus Desert), Autumn Woods, Mushroom Marsh, Starfall Shores…
- **World portal**: "WORLD 2 – THROW WITH 100M" over a themed gate. Later worlds: Pirate, Space, Lava hubs, each with the same layout.
- **Leaderboards**: Top Time Played, Top Robux Spent.
- **Seasonal layer**: Halloween props + "HALLOWEEN EVENT IN 4D 21H" countdown.

## Throw feel
- The character **holds the stone** in their hand, winds up and throws. The camera follows the stone; the distance meter counts up.
- **Relic ultimate**: an anime cut-in (silhouette + speed lines), a red beam from the sky, an explosion and an aura on the character. This is the trailer's hero moment.

## Monetization seen
Auto Throw, 2x Skill, 2x Wins, Starter Pack, +10K/+100K/+1M packs, Robux pools, relics with limited stock, limited premium pet, Rainbow/Hacked Admin eggs, gifts. See [[Monetization]].

## Menus (screenshots 2026-10-12)
| | |
|---|---|
| ![[stoneskip-hud-full.webp]] | ![[stoneskip-shop-menu.webp]] |
| ![[stoneskip-pets-menu.webp]] | ![[stoneskip-rebirth-menu.webp]] |

- **Window style:** dark translucent panel, thick black border, big white title across the top edge, large icon overlapping the top-left corner, red ✕ overlapping the top-right corner.
- **Shop:** scrolling sections with "~ Pack ~" headers. The Starter Pack card is rainbow, with content tiles (x30 pet, x10K skill, x1 potion, +1 rebirth), the old price struck out (199) and a green Robux buy button (36).
- **My Pets:** tabs down the left (Stones, Pets, Eggs, Boosts, Titles), "🎒 0 / 200 +" storage, "Equipped: 0 / 3 +", a list panel plus a details panel, and Auto Delete, Delete, **Equip Best** and Sort buttons. INDEX button. Hint: "Hatch an egg to collect your first pet!"
- **Rebirth:** **Before → After** cards (x2 SKILL → x3 SKILL, so +1x per rebirth), red "Resets your LEVEL and SKILL!", a "Level 1 / Level 40" bar, **Rebirth** (green) and **Skip Rebirth** (purple, Robux).
- **HUD extras:**
  - AUTO THROW "ONLY ◎ 23" at the top centre
  - Starter Pack icon and "+2x SKILL ONLY ◎5" / "2x WINS ONLY ◎54" cards on the right
  - Rebirth tile shows a "2%" progress badge; Gifts tile shows a "!" badge
  - a world "CLAIM" chest ("Join Group/Like To Claim!")
- **Auto Rebirth** button appears only while training.

## Egg hatch flow (screen recording)
![[stoneskip-egg-hatch-1.jpg]] ![[stoneskip-egg-hatch-2.jpg]]
1. Walk up to an egg and a **billboard panel** appears over it: the egg name ("Common"), a pet grid with % chances, multi-hatch passes on the left (+3 / +8 / +16 Eggs), and keybind buttons **E Hatch**, **R Multi**, **T Auto**.
2. Hatching **blurs the world and hides the HUD**. One big egg sits in the centre: "Click to hatch" (clicking wobbles and cracks it).
3. The **reveal card** shows the pet's name, its % chance, a **NEW!** tag, the pet icon, its bonus ("⚡ +2"), and "Click to continue".
4. **Multi hatch** shows 2+ eggs side by side ("Click to hatch 2"), then reveals the pets side by side.
5. Pets are cute **cube animals** (Pebble Pup, Brook Otter, Clover Bun). Their bonus is shown as **+N** and adds to the multiplier (x7 → x9 → x10 in the video).

→ Built in [[Phase 2 - Collection|2.2 Egg row + hatch flow]].
