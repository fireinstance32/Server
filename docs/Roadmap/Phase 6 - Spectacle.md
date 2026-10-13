---
tags: [planning, phase6]
---
# Phase 6 – Spectacle
*Goal: moments worth clipping for TikTok and YouTube Shorts (3D models, effects, audio, world art). Screen UI lives in [[Phase 5 - Interface]].* Back to [[Roadmap]].

> **Style (decided 2026-10-12): cube style** — chunky rounded cubes with big eyes for frogs and pets, like the reference pets. One base model per kind, recoloured per frog/pet in code.

## 6.1 Models 🟡
- [x] Cube frog, pet and egg built in Blender (`tools/blender/build_models.py`), exported to `assets/models/` — preview: ![[Models Preview.png]]
- [x] Game uses `ReplicatedStorage.Assets.Frog/Pet/Egg` when imported, recoloured per frog/pet; placeholders otherwise
- [ ] You import the 3 FBX files ([[Art Pipeline]] → Importing) and check them in [[Phase 6 Playtest]]
- [x] **Pets in Studio without Blender:** part-built cube pets, 21 animal looks with 3D details (ears, tails, wings, collars, horns, shells…), face + pattern **decals**, sparkles on Legendary/Rainbow — preview: ![[Pets Closeup.png]]
- [ ] You upload the 26 pet images and send the ids ([[Art Pipeline]] → Uploading); check with `/petgallery`
- [ ] Then compare with Blender pets and pick
- [x] Crowns for the King rocks (Blender `Crown`, worn by ToadKing / CandyKing / GalaxyKing / VolcanoKing)
- [x] **Rocks in Blender (Rock Pivot stage 4):** 19 high-quality rock shapes (`tools/blender/build_rocks.py`), each rock picks one in `Config/RockLooks` — preview: ![[Rocks Preview.png]]
- [x] Rock pictures rendered from the models (`tools/blender/render_rocks.py` → `frogs.png`, uploaded)
- [x] Ore ladder shapes (Ore, OreRich, GemOre, GemCluster) and a proper pebble
- [x] One lift animation (squat, clean, press, flex) + lift effects (`Effects/Lift`) + rock auras (`Effects/RockAura`)
- [x] Props in Blender (`tools/blender/build_props.py`): gym equipment, Podium, PortalArch, Trophy — preview: ![[Props Preview.png]]; used by gyms, podiums and portals (`WorldBuilder/GymKit`, `Parts.prop`)
- [ ] You import `Rocks/Rocks.fbx` and `Props/Props.fbx` ([[Art Pipeline]]) and check them in [[Phase 6 Playtest]]
- [x] Nature models in Blender (`tools/blender/build_nature.py`): 24 trees, pines, cacti, mushrooms, boulders, ice, crystals, candy, pumpkins, reeds, flowers — preview: ![[Nature Preview.png]]
- [ ] You import `Nature/Nature.fbx` ([[Art Pipeline]] → Nature) and check the lane in [[Phase 6 Playtest]]
- [x] Training locks you on the stand pad while lifting (STOP / jump to leave)
## 6.2 VFX 🟡
- [x] `Effects/World`: droplet splash on every pad, landing burst (ripples, golden sparkle fountain, mist), sparkles around you on level up
- [x] `Effects/Screen`: confetti on NEW BEST / MAX LEVEL / Epic+ hatch, colour flash on new zone and rare hatch
- [ ] Tune in Studio (amounts, sizes) after the playtest
## 6.3 Legend Frog ultimate hop 🟡
- [x] Top frogs (`ultimate = true`: Shooting Star, Phoenix, the 4 Kings) play it on every river hop: anime cut-in (frog silhouette over speed lines in the frog's colour, "ULTIMATE HOP!"), fire aura on the player, beam from the sky + explosion at the throw
- [ ] Tune timing/size in Studio
## 6.4 Audio
- [ ] Hop, splash, buy, hatch, level up, music per world
## 6.5 World art pass 🟡
- [x] Per-world themes (`Config/Worlds` Themes): plaza colours with a 40-stud checker, lily pad colour, stud texture on the plaza once uploaded
- [x] `WorldLighting`: lighting fades to each world's mood (Swamp dusk, Candy bright pink, Space night, Lava red haze)
- [x] **Map rebuilt like the reference:** 9 biome zones down the lane (grass banks, checker walls, water tint, props, floating zone signs), studded hub with paths and chevrons, checker cliffs with trees, studded Throw Zone, sunrise sky (`WorldBuilder/Lane`, `Hub`, `Style`)
- [x] ~~Stud texture on every walkable surface~~ removed 2026-10-13: the user adds studs with a plugin
- [x] **Lobby like the reference screenshots** (2026-10-13): a small walled courtyard with two-tier terraced checker walls, gyms down one side, a rock shelf and portals on the other, eggs, boards and waterfalls at the back, and a wide checker Throw Zone at the water (`Config/Lobby`, `WorldBuilder/Terraces`, `Hub/*`)
- [x] Map saved in `Workspace.Map` (built only if missing), so it can be edited in Studio; walk speed 24
- [x] **Lobby round 2** (2026-10-13): green checker grass, lavender checker walks with raised borders and a round spawn plaza (`Util/LobbyGrid`); themed gym pools with decor and a marked stand pad (`PondRow/`, `Util/GymGrid`); zones evenly 300 studs apart (`Zones.distanceForStrength`); opaque water with caustics (`WorldBuilder/Water`); midday lighting with shadows; 13 Blender decor models (`build_decor.py`)
- [x] Caustics texture uploaded (`UiImages.Ids.caustics`)
- [ ] Import `Decor.fbx`
- [ ] Check the map in Play and polish (sign/checker facing, prop placement, performance: ~31k instances)
- [ ] Skyboxes per world

## 6.6 Playtest 🧪
- [ ] I write the test plan: [[Phase 6 Playtest]] (started: models)
- [ ] You run it in Studio (see [[Testing Guide]]) and report issues
- [ ] Fix everything found, re-test, then the phase is closed
- **Done when:** every check in the playtest note passes.
