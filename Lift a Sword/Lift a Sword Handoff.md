---
tags: [lift-a-sword, handoff]
---
# Lift a Sword: Handoff

Paste everything below the line into a new Claude Code session (working dir `C:\1FrogHop`, the vault; game files are in `C:\LiftASword`). Back to [[Lift a Sword]].

---

I'm making **Lift a Sword**, a Roblox strength simulator in the style of "Lift a Weight". One long runway of 15 themed zones, each with a giant sword stuck in a themed pedestal that the player pulls out. It's a separate game from +1 Frog Hop, which shares this vault.

**Read first, in this order** (all in the vault folder `C:\1FrogHop\Lift a Sword`):
1. `Art/3D Modelling Preferences.md`: how I like models. Follow it, and add to it whenever I react to a model.
2. `Lift a Sword.md` (the index), then `Art/Model Status.md`, `Art/Model Pipeline.md`, `Studio/Studio Layout.md`, `Design/Zones.md`.
3. `Lift a Sword Decisions.md`: open questions for me.
4. Your memory files `lift-game-plan.md`, `3d-modelling-preferences.md`, `lift-pets-on-hold.md`, `galaxy-sword-animated.md`.

**Tools:** Roblox Studio MCP (studio_id `0dcafac6-1b19-460f-8750-6700ea1cafe6`; screen capture is black for you, so ask me for screenshots), the live Blender MCP, and headless Blender 5.2 (see Model Pipeline).

**Where we are (2026-10-14)**
- Swords, pedestals, eggs + stands, and signs are all built, imported and placed.
- The World 2 portal and the group chest (v2: bigger, more detailed) are exported **without textures** and waiting for me to import them.

**Next**
1. When I've imported them, place the portal (replace `Map.World2Portal`, about 11 studs per unit) and the group chest (spawn island, about 8 studs per unit). Colour every role from `assets/models/Landmarks/colors.json` (SmoothPlastic, glow roles Neon).
2. Group chest code: a ProximityPrompt opens the "join the group" UI and the `GroupChest_Lid*` parts pop open.
3. Later: VFX auras from my VFX pack, pull particles, then the game code (Rojo project, server-authoritative Strength, data saving, the group chest / daily rewards / spin wheel UIs).

**Keep the notes current:** update Model Status and Decisions, add a devlog note in `Lift a Sword/Devlog/` per session, and keep this handoff up to date.
