---
tags: [tech, art]
---
# Art Pipeline

## UI → Figma
- Connector: **Figma** (connected 2026-10-12, team "Ben Lewis's team", **Starter** plan).
- ⚠️ Figma's published MCP limits for Starter plans are very low (a handful of tool calls per month; see https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/). So: **you design in Figma, I read each finished frame once** (screenshot + design context) and turn it into Roblox UI code. A Professional plan raises the limit if we want Claude to generate designs in Figma too.
- Planned file: **"Frog Hop UI"**, pages: Design System · HUD (1920×1080) · Menus · Hatch · World UI.
- Exported icons/textures (PNG) → uploaded to Roblox → ids kept in one config file → used by the UI code.
- Used in [[Phase 5 - Interface]].

## Models → Blender
- Blender 5.2 runs here headless (`bpy`), so models are **Blender Python scripts in the repo**, built and exported here.
- Output per model: `.fbx` (import into Studio with the **3D Importer**) + a preview render for approval.
- Meshes can't sync through Rojo: imported models live in Studio (e.g. `ReplicatedStorage.Assets`) and the code looks them up by name. The part-built placeholders in `Shared/Util/Models` stay until each real model lands.
- Roblox limits to respect: ≤ 20k triangles per mesh, textures ≤ 1024².
- Used in [[Phase 6 - Spectacle]].
