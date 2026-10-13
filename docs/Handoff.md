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
  - Rock pictures: the `frogs.png` sheet still shows frogs, so the Rocks tab and the Daily Day 7 card show frogs.
  - A rock icon (`gem` is standing in).
  - The field map, gym art and Blender rock models (stage 4).
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

## Next task: live Blender MCP
The user wants Claude to drive Blender live (the "blender-mcp" add-on by ahujasid on GitHub, plus its MCP server run with `uvx blender-mcp`).
1. **Get the user's OK before downloading.** Tell them the file name, source and size, for example `addon.py` from github.com/ahujasid/blender-mcp and the `blender-mcp` PyPI package.
2. Check that `uv` is installed. If it isn't, give the user the install command.
3. The user installs `addon.py` in Blender (Edit → Preferences → Add-ons → Install from disk), opens the sidebar (N) → BlenderMCP tab → Connect.
4. Register the server: `claude mcp add blender -- uvx blender-mcp`, then restart the session.
5. Then start stage 4: model rock tiers (pebble → boulder → crystal / gold / lava / galaxy), export .fbx to `assets/models/`, and the user imports them into `ReplicatedStorage.Assets` as `Rock`. `Models.rock` already uses `Assets.template("Rock")` when it exists.
