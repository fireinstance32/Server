---
tags: [planning, decisions]
---
# Decisions for you

Things I need from you, or choices I made for now that you can change. Newest first. Back to [[Home]].

## Things only you can do
- [ ] **Upload images to Roblox** (Asset Manager → Bulk Import) and send me the ids:
  - Pet faces/patterns: 26 PNGs in `assets/textures/pets` → `Config/PetFaces.luau` ([[Art Pipeline]])
  - UI: 4 sheets in `assets/textures/ui` → `Config/UiImages.luau`: `icons.png` (every icon), `studs.png` (panel texture), `pets.png` + `frogs.png` (every pet/frog picture for menus)
  - Shortcut: create a Roblox **Open Cloud API key** (Assets: write) and add it as a secret for these sessions; then I can upload and fill in the ids myself.
- [ ] Create the passes/products and paste their ids ([[Monetization Setup]]).
- [ ] Run the playtests (Phases 1–4, 6, 7, 8) and send problems.

## Choices I made for now (change any time)
| Topic | What I picked | Why / alternatives |
|---|---|---|
| UI fonts | Fredoka One everywhere (Roblox `FredokaOne`) | Closest to the reference look; could use Gotham Black for numbers |
| UI images | 1 icon sheet + 1 stud texture, emoji until uploaded | Fewest uploads; icons are 3D renders from Blender |
| HUD layout | Follows the Stone Skipping HUD (grid left, passes right, level bar bottom) | — |
| Pets | Part-built cube pets with decal faces | Blender pets later for comparison (you asked to try parts first) |
| Frogs | Cube frogs built like the pets (eyes on top, frog face), extras: crowns for Kings, Ninja headband, Golden shiny, Phoenix wings, Mushroom cap, Astro helmet | Matches the cube style; the round part frog is gone |
| Menus | Translucent panel + blurred world, studded buttons, pictures of pets/frogs from image sheets | Reference look; 3D views until the sheets are uploaded |
| Halloween | 24 Oct – 3 Nov 2026 (you confirmed) | — |
| World gates | 1M / 50M / 2.5B / 100B Hops | Tune after the Phase 7 playtest |
| Max players | 12 | More = more Friend Boost and busier boards |
| Performance | No StreamingEnabled yet (forced off in default.project.json; sign/podium controllers WaitForChild on far worlds) | Decide after the Phase 8 playtest numbers |
| Sounds | Hooks everywhere (click, hover, claim, hop, splash, hatch, level up, purchase), all silent | Pick sounds from the Creator Store (or let me suggest ids) → `Config/Sounds.luau` |
