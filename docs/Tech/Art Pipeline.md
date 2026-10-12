---
tags: [tech, art]
---
# Art Pipeline

## UI → built in code (no Figma)
- Decided 2026-10-12: **no Figma**. I design and build every screen directly in Luau from the reference screenshots ([[HUD References]], [[Stone Skipping UI Breakdown]]); you review in Studio and send screenshots/feedback.
- Icons and textures I need are drawn as PNGs in the repo, then uploaded to Roblox (ids in one config file).
- Used in [[Phase 5 - Interface]].

## Pets → parts + decals (in Studio, no meshes)
- Each pet is a cube built from parts with 3D details (ears, tails, wings, collars, horns…) chosen by its animal look (`Config/PetLooks`), plus **decals**: a face on the front and tinted patterns (spots, stripes, eye patches) on the sides.
- Face/pattern images: `tools/textures/pet_textures.py` → `assets/textures/pets/*.png` (21 faces + eye + 4 patterns).
- Preview without Studio: `cd tools/luau-check && node dump-pets.mjs > pets.json`, then `python tools/blender/preview/render_pets.py pets.json out.png` → [[Pets Preview.png]] · [[Pets Closeup.png]]. It runs the game's own pet code.
- In Studio: `/petgallery` lines every pet up next to spawn.

### Uploading the pet images (once)
1. Studio → **View → Asset Manager** → **Bulk Import** → select all PNGs in `C:\1FrogHop\assets\textures\pets`.
2. In Asset Manager → Images, right-click each → **Copy Asset ID**.
3. Paste each id into `src/shared/Config/PetFaces.luau` next to its file name (`face_dog = 1234567890,`), or send me the list (name → id) and I'll fill it in.
4. Until an id is filled in, that pet uses its part-built face.

## Models → Blender
- Blender 5.2 runs here headless (`bpy`), so models are **Blender Python scripts in the repo**, built and exported here. (Pets are parts + decals for now — see above; Blender pets come back later for comparison.)
- Output per model: `.fbx` (import into Studio with the **3D Importer**) + a preview render for approval.
- Meshes can't sync through Rojo: imported models live in Studio (e.g. `ReplicatedStorage.Assets`) and the code looks them up by name. The part-built placeholders in `Shared/Util/Models` stay until each real model lands.
- Roblox limits to respect: ≤ 20k triangles per mesh, textures ≤ 1024².
- **Style: cube** (rounded cubes, big eyes, flat colours).
- Script: `tools/blender/build_models.py` → `assets/models/Frog.fbx`, `Pet.fbx`, `Egg.fbx` + preview [[Models Preview.png]].
  - Rebuild: `python tools/blender/build_models.py assets/models --preview "docs/Art/Models Preview.png"`
- One model per kind; the game recolours parts by name (Frog: Body/Belly/Foot · Pet: Body/Ear/Foot · Egg: Shell/Spots), so 28 frogs and 40+ pets share 3 meshes.

### Importing the models into Studio (once per model change)
1. In Studio: **Explorer → ReplicatedStorage → + → Folder**, name it `Assets`.
2. **Home → Import 3D** (3D Importer) → pick `C:\1FrogHop\assets\models\Frog.fbx` → Import.
3. Drag the imported model into `ReplicatedStorage.Assets` and rename it exactly `Frog`.
4. Repeat for `Pet.fbx` → `Pet` and `Egg.fbx` → `Egg`.
5. **File → Save** (the models live in the place file, not in Rojo).
6. Play: podiums, held frog, hopping frog, pets, egg stands and the hatch screen use the new models. Delete a model from `Assets` to go back to the placeholder.
- Used in [[Phase 6 - Spectacle]].
