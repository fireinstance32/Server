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
- [ ] Extras later: crowns for the King frogs
## 6.2 VFX 🟡
- [x] `Effects/World`: droplet splash on every pad, landing burst (ripples, golden sparkle fountain, mist), sparkles around you on level up
- [x] `Effects/Screen`: confetti on NEW BEST / MAX LEVEL / Epic+ hatch, colour flash on new zone and rare hatch
- [ ] Tune in Studio (amounts, sizes) after the playtest
## 6.3 Legend Frog ultimate hop 🟡
- [x] Top frogs (`ultimate = true`: Shooting Star, Phoenix, the 4 Kings) play it on every river hop: anime cut-in (frog silhouette over speed lines in the frog's colour, "ULTIMATE HOP!"), fire aura on the player, beam from the sky + explosion at the throw
- [ ] Tune timing/size in Studio
## 6.4 Audio
- [ ] Hop, splash, buy, hatch, level up, music per world
## 6.5 World art pass
- [ ] Hub layout, props, banks, lighting

## 6.6 Playtest 🧪
- [ ] I write the test plan: [[Phase 6 Playtest]] (started: models)
- [ ] You run it in Studio (see [[Testing Guide]]) and report issues
- [ ] Fix everything found, re-test, then the phase is closed
- **Done when:** every check in the playtest note passes.
