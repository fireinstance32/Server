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

### Rocks (Rock Pivot stage 4)
- Script: `tools/blender/build_rocks.py`: **19 rock shapes + a Crown**, high-poly (5–20k tris each), shaped with noise, chiselled facets, craters, metaballs and "coats" (moss, frosting, ooze, gold inlays, lava plates). Preview: [[Rocks Preview.png]]
  - Pebble, River (banded), Mossy, Rock (chiselled), Boulder, Nugget, Lava (glowing seams), Meteor (glow shards), Moon (craters), Candy (rock candy on a stick), Gummy (gummy bear), Frosted (cupcake), Mushroom, Toxic (glowing ooze), Rune (glowing carved lines), Royal (gold inlays), Comet (glowing tail), Galaxy (ringed orb), Phoenix (flame feathers); Crown for the 4 Kings.
  - Rebuild: `blender -b -P tools/blender/build_rocks.py -- assets/models --preview "docs/Art/Rocks Preview.png"`
  - Live: in a Blender MCP session, `exec` the file and call `showcase()` → a "Rocks" scene with every shape.
- Output: `assets/models/Rocks.fbx` (all shapes, each under an empty named after it) and `assets/models/rocks/<Shape>.fbx` (one per file).
- Parts are named `<Shape>_<Role>`; `Models/Assets.luau` colours each role from the rock's colour (Body, Shade, Crust, Glow = Neon, Crystal, Band, Cap, Jelly, Moss …; Stone/Gold/Frosting… keep a fixed colour). `Root` is a hidden centre part everything welds to.
- Which rock uses which shape, and which wear the Crown: `src/shared/Config/RockLooks.luau` (unit-tested against `Config/Frogs`).
- Rock pictures (Rocks tab, Daily, tooltips) are rendered from the same models: `blender -b -P tools/blender/render_rocks.py -- <dir>` then `python tools/textures/pack_icons.py <dir> rock_ frogs FrogIconAtlas 128 8`, upload `frogs.png`, put the id in `Config/UiImages`.

#### Importing the rocks into Studio
1. **Home → Import 3D** → `C:\1FrogHop\assets\models\Rocks.fbx` → Import.
2. Drag the imported model into `ReplicatedStorage.Assets` and rename it exactly `Rocks`. Inside it there should be one Model per shape (`Rock`, `RockPebble`, … `Crown`).
   - If the importer flattens it into one model instead, delete it and import the files in `C:\1FrogHop\assets\models\rocks\` one by one; put each straight into `Assets`, named as its file (`RockLava`, `Crown`…).
3. **File → Save**. Play: podiums, the held rock, the thrown rock and the 3D views use the new rocks; Kings wear the crown. Delete `Assets.Rocks` to go back to the part-built rocks.
