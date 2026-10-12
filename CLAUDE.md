# +1 Frog Hop – notes for Claude

- Roblox game synced with Rojo (`default.project.json`, port 34873). The user runs `rojo serve` from `C:\1FrogHop`.
  - **Local session (on the user's PC, in `C:\1FrogHop`):** edit files directly — Rojo syncs them into Studio live. Still commit + push so the branch stays the record. Local assets (e.g. `C:\1FrogHop\Gvesster Icon Pack v8`, a paid icon pack — never commit it, add it to .gitignore) can be read directly.
  - **Cloud session:** it can't reach the PC; changes reach Studio via git push → Obsidian Git pulls.
- Two-way sync: Obsidian Git also commits and pushes the user's note edits. **Always `git pull --rebase origin <branch>` before pushing**, and keep their edits when merging.
- Art pipeline: no Figma — UI is built in Luau and checked with `tools/ui-preview` (needs Node + `npx playwright install chromium` locally). Icons: the user wants the Gvesster Icon Pack v8 for ALL UI icons (pick one per `Config/IconAtlas` name, pack into `assets/textures/ui/icons.png` with `tools/textures/pack_icons.py <dir> icon_ icons IconAtlas 170 6 flat`); the hand-drawn vectors in `assets/vectors/icons` are the fallback. Models in Blender via `bpy` → .fbx → user imports in Studio. See docs/Tech/Art Pipeline.md.
- Balance numbers only in `src/shared/Config/`. Reward maths only in `src/server/Stats.luau`.
- One job per file: split any module past ~200 lines or doing two things into a folder (`Name/init.luau` + parts). See docs/Tech/Architecture.md.
- Server-authoritative: the client never decides rewards. Remotes are declared in `src/shared/Net.luau`.
- Before committing: `cd tools/luau-check && npm install && npm run check` (compile + lint + unit tests; must print 0 diagnostics and 0 failed). Pure logic goes in `src/shared` so it can be unit-tested in `tools/luau-check/tests`.
- The user's Obsidian vault is the repo root (`C:\1FrogHop`); notes live in `docs/`. Keep them updated: add a devlog note per session, tick items in `docs/Roadmap/` (systems in Phases 1–4; screen UI waits for Phase 5 – Interface), and keep the phase playtest note in `docs/Testing/` current.
