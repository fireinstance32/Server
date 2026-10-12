---
tags: [tech, art]
---
# Art Pipeline

## UI → Figma
- Connector: **Figma** (connected 2026-10-12, team "Ben Lewis's team", **Starter** plan).
- ⚠️ The Starter plan allows **20 Figma MCP tool calls per month** (https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/). So: **you design in Figma, I read each finished frame once** (screenshot + design context) and turn it into Roblox UI code. A Professional plan raises the limit if we want Claude to generate designs in Figma too.
- Planned file: **"Frog Hop UI"**, pages: Design System · HUD (1920×1080) · Menus · Hatch · World UI.
- Exported icons/textures (PNG) → uploaded to Roblox → ids kept in one config file → used by the UI code.
- Used in [[Phase 5 - Interface]].

## Models → Blender
- Blender 5.2 runs here headless (`bpy`), so models are **Blender Python scripts in the repo**, built and exported here.
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
