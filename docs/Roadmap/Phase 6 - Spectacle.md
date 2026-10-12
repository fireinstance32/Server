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
- [ ] Extras later: crowns for the King frogs, wings/horns for Legendary pets
## 6.2 VFX
- [ ] Splash per pad, landing burst, confetti on new zone/level up
## 6.3 Legend Frog ultimate hop
- [ ] Anime cut-in (silhouette + speed lines), beam, explosion, aura
## 6.4 Audio
- [ ] Hop, splash, buy, hatch, level up, music per world
## 6.5 World art pass
- [ ] Hub layout, props, banks, lighting

## 6.6 Playtest 🧪
- [ ] I write the test plan: [[Phase 6 Playtest]] (started: models)
- [ ] You run it in Studio (see [[Testing Guide]]) and report issues
- [ ] Fix everything found, re-test, then the phase is closed
- **Done when:** every check in the playtest note passes.
