# +1 Frog Hop – notes for Claude

- Roblox game synced with Rojo (`default.project.json`, port 34873). The user runs `rojo serve` locally from `C:\1FrogHop`; this cloud session cannot reach their machine, so changes reach Studio via git push → user pulls.
- Balance numbers only in `src/shared/Config/`. Reward maths only in `src/server/Stats.luau`.
- One job per file: split any module past ~200 lines or doing two things into a folder (`Name/init.luau` + parts). See docs/Tech/Architecture.md.
- Server-authoritative: the client never decides rewards. Remotes are declared in `src/shared/Net.luau`.
- Before committing: `cd tools/luau-check && npm install && npm run check` (compile + lint + unit tests; must print 0 diagnostics and 0 failed). Pure logic goes in `src/shared` so it can be unit-tested in `tools/luau-check/tests`.
- The user's Obsidian vault is the repo root (`C:\1FrogHop`); notes live in `docs/`. Keep them updated: add a devlog note per session, tick items in `docs/Roadmap/` (systems in Phases 1–4; screen UI waits for Phase 5 – Interface), and keep the phase playtest note in `docs/Testing/` current.
