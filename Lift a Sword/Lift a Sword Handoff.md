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

**Coding rules:** follow the `karpathy-guidelines` skill (installed in `~/.claude/skills/karpathy-guidelines`): think before coding, simplicity first, surgical changes, goal-driven execution with a check for each step.

**Tools:** Roblox Studio MCP (studio_id `0dcafac6-1b19-460f-8750-6700ea1cafe6`; screen capture is black for you, so ask me for screenshots), the live Blender MCP, and headless Blender 5.2 (see Model Pipeline).

**Where we are (2026-10-14, end of session)**
- All the art is built, imported and placed: 16 swords, pedestals, signs and stylised eggs on stands 1–16.
- **All 84 pets** are in Studio under `ReplicatedStorage.Pets.<Egg>.<Pet>`, at about 3 studs (Mythics 1.25x). They're anchored and non-colliding, glow roles are Neon, the outline has CastShadow off, `Egg` attribute.
- **Egg textures:** the Stylised+ maps were re-uploaded with the Studio MCP and set on stands 1–15. Fresh uploads can show grey until Roblox finishes processing them. If any egg is still grey, re-upload its four maps from `C:\LiftASwordssets\models\Eggs\Textures`: serve the folder with `python -m http.server 8765 --bind 127.0.0.1`, call `upload_image` 4 files at a time (bigger batches time out), then set the SurfaceAppearance maps. **Don't use ChangeHistoryService:Undo**: it only half-undid an MCP edit. The replaced eggs are in `ServerStorage.OldEggs`, so delete that folder once the eggs look right.
- **The core loop is designed:** read `Design/Core Loop.md` first. It's agreed with me except for the numbers. Summary:
  - an auto-lifting dumbbell gives Strength (× pets, × dumbbell) and XP (not boosted by pets);
  - you level up automatically, and Level walls gate the zones;
  - mash-pulling swords pays Cash;
  - Cash buys eggs, 6 chests (one every 3 zones, each with a Robux x5-luck version, 27 dumbbells in 6 rarities) and Speed/Grip pads (Grip = an aura that shortens the lift time);
  - a 5x bubble (screen UI) gives 5 seconds of 5x training;
  - level-ups shake the screen. **No "+N Levels" popup.**
  - No Evolve and no rebirth at launch.
- No game code exists yet.

**Next: balancing (it has to be right before any code)**
1. My goals: progression should **feel fast**, but World 1 must **not be a 1-hour game** (aim for many hours; agree a target with me). Robux **Strength passes stack: x2, then x4, and so on**, and they must clearly speed players up.
2. The start of a simulator is in `C:\LiftASword	oolsalancealance_sim.py` (1-second ticks, greedy shopper, random chest/egg rolls). It's **too slow as written**: use bigger ticks or work out each phase analytically.
   - First finding: XP only comes from the dumbbell, so a Strength pass barely helped, because the Level walls are the bottleneck.
   - Chest rolls (rarer dumbbells give far more XP) are what link Strength → Cash → XP. Check that link holds.
3. Show me a timing table: minutes to each zone for free players and for x2/x4/x8 Strength pass players. Tune it with me, then put the numbers in Config.
4. Then build the game code: a Rojo project like Frog Hop's, a server-authoritative server, data saving, Strength/XP/Level/Cash, mash-pulling, pads, chests, eggs and pets, then the UIs.
5. Later: the World 2 portal import and placement, VFX auras from my VFX pack, pull particles, and the ambient animation script.

**Keep the notes current:** update Model Status and Decisions, add a devlog note in `Lift a Sword/Devlog/` per session, and keep this handoff up to date.
