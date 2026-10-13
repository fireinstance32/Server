---
tags: [handoff]
---
# Handoff (2026-10-13)

Paste this into a new Claude Code session in `C:\1FrogHop`.

---

Continue my Roblox game **+1 Lift Rock For Pets** (repo `C:\1FrogHop`, branch `claude/focused-meitner-7df7ik`). Read `CLAUDE.md` and `docs/Design/Rock Pivot.md` first. Commit and push when a task is done (it's OK). Always run `git pull --rebase origin claude/focused-meitner-7df7ik` before pushing. Stage with `git add -A -- . ':!Progression'` because `Progression/` must never be committed. The checks are `cd tools/luau-check && npm run check`, which must show 0 diagnostics and 0 failed (the "boom" line is expected). Commit as Claude through env vars:

```
GIT_AUTHOR_NAME=Claude GIT_AUTHOR_EMAIL=noreply@anthropic.com GIT_COMMITTER_NAME=Claude GIT_COMMITTER_EMAIL=noreply@anthropic.com
```

## Where things are
- **Pivot from +1 Frog Hop to rock lifting.** The loop is the same as Stone Skipping:
  - Stand in a gym and the rock is lifted automatically for +Strength.
  - Throw the rock down the field; landing farther pays more Wins.
  - Rebirth resets Strength and Level and **keeps Wins**.
  - Pets are kept.
- **Code names stay old so saves keep working:**

  | Code | Players see |
  |---|---|
  | `data.hops` | Strength |
  | `Config/Frogs`, `HeldFrogService` | Rocks |
  | `Ponds` | Gyms |
  | `HopService` (`Train` / `Launch`) | lift / throw |
- **Done:**
  - Stage 1: every player-facing word changed.
  - Stage 2, first pass:
    - `Models.rock` (`src/shared/Util/Models/Rock.luau`) is a part-built faceted rock.
    - The rock is held in the right hand, tumbles when thrown, and shows on the podiums and in the Rocks tab.
    - Gym training plays a lift rep (`Controllers/LiftAnimation.luau`).
    - The arm is posed through `Controllers/Shoulder.luau`, which rotates the joint's `Transform` every PreSimulation. The user's avatar has an **AnimationConstraint** shoulder, not a Motor6D, so C0 edits don't work.
  - Shop replica, with prices on one ladder from 19 to 449. The list is in `docs/Design/Monetization Setup.md`.
  - Starter Pack (49 Robux) includes the new **Rainbow Unicat** pet. The HUD picture is `UI/Hud/StarterPackIcon.luau`.
- **Not done:**
  - (Rock pictures: done 2026-10-13, rendered from the Blender rocks.)
  - A rock icon (`gem` is standing in).
  - Field map: lobby redone like the user's reference screenshots (2026-10-13: `Config/Lobby`, `WorldBuilder/Terraces`, `Hub/*`). **No stud texture in code** (the user has a plugin). Checked by eye with **edit-mode** `screen_capture` + `camera_position` (works; Play-mode captures are black). Blender rocks, props and nature models are imported.
  - **Map vs World:** `Workspace.Map.<World>` (scenery + terrain water) is saved with the place and only built if missing; `Workspace.World.<World>` (interactive) is rebuilt every server start. To rebuild a map from Studio MCP in Edit, the command-bar `require` cache serves stale modules: clone `ReplicatedStorage.Shared` (rename the original away, put the clone in its place) and a clone of `WorldBuilder`, require the clone, call `buildMap(id)` / `buildWorld()`, then restore. Walk speed: `Config/Game.WalkSpeed` (24).
  - Training now locks the player on the stand pad (`Controllers/TrainLock`). The pad is marked (corner brackets + chevron, `PondRow/StandPad`).
  - Lobby round 2 (2026-10-13): grid-based floor and walks (`Util/LobbyGrid`), themed gym pools (`PondRow/`, `Util/GymGrid`), zones evenly 300 studs (`Zones.distanceForStrength`), opaque water (`WorldBuilder/Water`), midday lighting. Caustics uploaded (`UiImages.Ids.caustics`). **Waiting on the user:** importing `assets/models/Decor/Decor.fbx` as `Assets.Decor`; saving the place; setting Lighting.Technology to Future.
  - Real lift and throw animations.
- **The user said stages 3 and 5 (icon/ad tests) are NOT next.** The game isn't ready. Focus on gameplay and art.
- **All Robux product and pass ids are 0.** The user creates them on the dashboard.

## Tools
- **Studio MCP:**
  - Studio id: call `list_roblox_studios` (it was `55632880-…`).
  - **Never `require` server services from `execute_luau`.** It re-runs `Shared/Net` and destroys the live Remotes folder, which breaks the session.
  - `screen_capture` doesn't show the 3D world. Check things with numbers instead.
- **Rojo:** run `rojo serve` in the Terminal panel (port 34873).
- **Uploading images:**
  1. Serve the folder over HTTP with `python -m http.server 34901` in a scratch folder.
  2. Call `upload_image` with the `http://127.0.0.1:34901/<file>` URLs (Studio must be in Edit mode).
  3. Put the new id in `Config/UiImages`.
  4. Re-upload whenever a sheet is regenerated.
- **Pet pictures:**
  1. `cd tools/luau-check && node dump-pets.mjs > pets.json`
  2. `blender -b --python tools/blender/preview/render_pets.py -- pets.json --icons <dir>`
  3. `python tools/textures/pack_icons.py <dir> pet_ pets PetIconAtlas 128 8`
- **Blender 5.2** is at `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe` (headless `bpy` works).
- **Gvesster Icon Pack** (paid): icons may only be scaled and packed, never edited or tinted. Never commit the pack folder.

## Blender (live)
- The Blender MCP server is registered for this project (`.mcp.json`) and the add-on is installed. Blender must be open with the add-on connected; tools are `mcp__blender__*` (`execute_blender_code`, `look`, `get_scene_info`).
- Models: `tools/blender/build_rocks.py` (23 rock shapes + Crown) and `build_props.py` (gym/world props); everything exported under `assets/models/` (index: `assets/models/README.md`). Live: `exec` it with a non-main `__name__` and call `showcase()` → "Rocks" scene. Headless rebuild + export: see [[Art Pipeline#Rocks (Rock Pivot stage 4)]].
- Rock → shape map: `Config/RockLooks.luau`. Rock pictures: `tools/blender/render_rocks.py` → `pack_icons.py ... rock_ frogs FrogIconAtlas 128 8` → upload (port 34901 may be taken by an old server; 34902 worked).

## Next task
1. **The user imports `assets/models/Rocks/Rocks.fbx` (as `Assets.Rocks`) and `assets/models/Props/Props.fbx` (as `Assets.Props`)** ([[Art Pipeline]]); auto-import isn't possible. Then Claude can check them through Studio MCP and the user runs [[Phase 6 Playtest]] → 6.1 Rocks / Lift + rock effects / Props. Check: held rock grip, prop placement (`Parts.prop` sits each prop's bounding box on the floor), arch facing.
2. Rest of stage 4: the throwing field map (the gyms still sit on the old pond water).
3. A rock icon to replace `gem` in the HUD/menus (Gvesster pack first, per CLAUDE.md).
