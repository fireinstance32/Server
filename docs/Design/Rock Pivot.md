---
tags: [design, planning]
---
# Rock Pivot (2026-10-13)

The game changes from +1 Frog Hop to a **rock-lifting** game on the same [[Stone Skipping Reference|Stone Skipping]] loop. Every system and all the UI carry over; what changes is the theme, the held item, two animations and the art. Back to [[Home]] · [[Core Loop]] · [[Decisions]].

**Why:** "+1 Lift Rock" makes a stronger thumbnail (tiny character under a giant glowing boulder), lifting/strength simulators are a proven Roblox genre, and it's the cheapest switch: the game already holds an item in your hands (`HeldFrogService`), rocks are simple shapes, and it needs 1–2 animations instead of a sword game's swing sets.

**Title:** *+1 Lift Rock For Pets* (decided 2026-10-13).

## Core loop
```
Lift rock (click, +1 Strength × multipliers) ──► Throw it down the field ──► farther zone = more Wins
      ▲                                                                              │
      └──── Rocks / Eggs → Pets / Gyms / Rebirth (more Strength per lift) ◄──────────┘
```
Same maths as before: Strength sets throw distance, the zone you land in pays Wins, rebirth resets Strength + Level and keeps Wins ([[Core Loop#Formulas]]).

## Naming
| Stone Skipping | Frog Hop (old) | Now |
|---|---|---|
| Skill | Hops | **Strength** |
| Stone (equipped, bought with Wins) | Frog | **Rock** |
| Throw | Hop / Launch | **Throw** |
| Training | Hopping pads in a pond | **Lifting** the rock |
| Training zones | Ponds | **Gyms** |
| River | River | **Field** |
| Skips | Pads | **Bounces** |
| Relic | Legend Frog | **Legend Rock** |
| Auto Throw pass | Auto Hop | **Auto Lift** |

Code keeps its internal names (`data.hops`, `HopService`, `Config/Frogs`, `Ponds`...) so saves and systems don't break; only what players see changes. A full internal rename can come later if it's worth it.

## Pets
Kept. Eggs are usually the biggest earner in these games and pets are what players collect; the system is finished. Frog-themed pets (Lily Frogling...) get renamed in stage 3.

## Stages
1. ✅ **Words** – every on-screen Hops/Frog/Pond/Hop/River string → the new names; game title *+1 Lift Rock For Pets*.
2. 🟡 **Gameplay** (first pass 2026-10-13: part-built rocks, procedural lift + throw; camera follow kept) – hold a rock instead of a frog; click = lift animation (+Strength pop); throw animation; rock bounces down the field; camera follows the rock.
3. 🟡 **Content names** – zones, worlds, rocks (pebble → boulder → crystal / gold / lava / galaxy), pets, eggs, codes, trails.
   - ✅ 2026-10-13: Stone Valley rocks are an **ore ladder** (Pebble, Stone, Coal, Copper, Iron, Silver, Gold, Emerald, Ruby, Diamond); its old unique rocks are now **reward rocks** (codes MOSSY / SLIME / ROYAL, Level 20 and Rebirth quests, Daily Day 4, the 45 min gift) and stay off the podiums.
4. 🟡 **Art** – rock models in tiers (Blender `bpy`), gyms, the throwing field, world themes, lift/throw animations (Roblox Animation Editor).
   - ✅ 2026-10-13: **19 Blender rock shapes + Crown** (`tools/blender/build_rocks.py`, [[Art Pipeline#Rocks (Rock Pivot stage 4)]]), every rock mapped in `Config/RockLooks`, rock pictures re-rendered from the models (frogs.png re-uploaded). ![[Rocks Preview.png]]
   - ✅ 2026-10-13: ore shapes (Ore, OreRich, GemOre, GemCluster), a proper pebble; **one lift animation** (squat → clean → press overhead, bicep flex, procedural on any rig: `Controllers/Pose` + `LiftAnimation`) with charge and lockout effects (`Effects/Lift`); every rock has an **aura** (`Effects/RockAura`: shape style, glints, orbiting comets, halo for strong rocks); the throw uses the same pose system.
   - ✅ 2026-10-13: **props** (`build_props.py`: gym equipment, lifting platform, Podium, PortalArch, Trophy) used by gyms, podiums and portals once imported. ![[Props Preview.png]]
   - Still to do: you import `Rocks/Rocks.fbx` and `Props/Props.fbx`; the throwing field map.
5. **Icon test before ads** – 2–3 icons/thumbnails, a few dollars of ads each (or Roblox thumbnail testing); build on the winner. No real ad budget until day-1 retention and session length look good in playtests.
