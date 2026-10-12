---
tags: [planning, decisions]
---
# Decisions for you

Things I need from you, or choices I made for now that you can change. Newest first. Back to [[Home]].

## Things only you can do
- [ ] **Upload images to Roblox** (Asset Manager → Bulk Import) and send me the ids:
  - Pet faces/patterns: 26 PNGs in `assets/textures/pets` → `Config/PetFaces.luau` ([[Art Pipeline]])
  - UI: 4 sheets in `assets/textures/ui` → `Config/UiImages.luau`: `icons.png` + `icons2.png` + `icons3.png` (every icon), `studs.png` (panel texture), `pets.png` + `frogs.png` (every pet/frog picture for menus)
  - Shortcut: create a Roblox **Open Cloud API key** (Assets: write) and add it as a secret for these sessions; then I can upload and fill in the ids myself.
- [ ] Create the passes/products and paste their ids ([[Monetization Setup]]).
- [ ] Run the playtests (Phases 1–4, 6, 7, 8) and send problems.

## Choices I made for now (change any time)
| Topic | What I picked | Why / alternatives |
|---|---|---|
| UI fonts | Fredoka One everywhere (Roblox `FredokaOne`) | Closest to the reference look; could use Gotham Black for numbers |
| UI images | 2 icon sheets (170 px cells, 72 icons) + 1 stud texture, emoji until uploaded | Best quality you asked for; 1 extra upload |
| Icons | Gvesster Icon Pack v8 (Outline 256 px) for every icon, scaled and packed only (licence: no edits). Frog is the only hand-drawn vector left | Pack folder never committed, only the packed sheets. Swap any icon by changing the pick in the pack script |
| UI text & colours | Menus, hatch screen and pop-ups in GothamBlack (= Montserrat Black in Roblox), HUD in Fredoka One; window titles with a thick black outline + solid black drop shadow; colours sampled from the reference screenshots | Matches the reference; say if any colour feels off in Studio |
| HUD details | Green HOP button; Auto Hop hidden during the tutorial; square studs with a soft shadow; red square close button with a white × (dark-red outline); bare Starter Pack icon; white pet names on the hatch screen | Copied from the Stone Skipping references |
| Rebirth | Resets Hops and Level only; **Wins are kept** | Your rule (the reference resets its currency) |
| Menus open | Whole HUD hides while a window is open; windows centred on the full view (design size 1920×1056 = your screenshots minus the Windows title bar) | Matches the reference screenshots exactly |
| Playtime Rewards | 12 rewards copied from the reference (Hops, Wins, boosts, Common/Uncommon/Rare eggs that hatch straight into your pets) at 1–65 min | Numbers in `Config/Gifts.luau`; Uncommon/Rare egg pictures are vectors (pack has no coloured eggs) |
| Window sizes | Fixed pixel sizes measured from the screenshots (ScreenScale shrinks them on smaller screens); Daily claims by clicking today's card, no Claim button | Matches the reference |
| Titles | 27 milestone titles (throws, distance, eggs, playtime, frogs, pets, rebirths, level, Wins), +0.5…+15 Hops or x1.05…x2 Wins, shown above the head | Names/numbers in `Config/Titles.luau` – rename or retune freely |
| Worlds menu pictures | Painted in code from each world's colours | Send me Studio screenshots of each hub (or upload them) and the cards can show real pictures like the reference |
| Settings | Volume sliders for sound/music; Camera Shake, Effects, Other pets toggles; no "Hide HUD" yet | Hide HUD needs a way back (key/button) – say if you want it |
| HUD layout | Follows the Stone Skipping HUD (grid left, passes right, level bar bottom) | — |
| Pets | Part-built cube pets with decal faces | Blender pets later for comparison (you asked to try parts first) |
| Frogs | Cube frogs built like the pets (eyes on top, frog face), extras: crowns for Kings, Ninja headband, Golden shiny, Phoenix wings, Mushroom cap, Astro helmet | Matches the cube style; the round part frog is gone |
| Menus | Translucent panel + blurred world, studded buttons, pictures of pets/frogs from image sheets | Reference look; 3D views until the sheets are uploaded |
| Halloween | 24 Oct – 3 Nov 2026 (you confirmed) | — |
| World gates | 1M / 50M / 2.5B / 100B Hops | Tune after the Phase 7 playtest |
| Max players | 12 | More = more Friend Boost and busier boards |
| Performance | No StreamingEnabled yet (forced off in default.project.json; sign/podium controllers WaitForChild on far worlds) | Decide after the Phase 8 playtest numbers |
| Sounds | Hooks everywhere (click, hover, open, tab, error, claim, hop, splash, hatch, level up, purchase, music), all silent | Pick sounds from the Creator Store (or let me suggest ids) → `Config/Sounds.luau` |
