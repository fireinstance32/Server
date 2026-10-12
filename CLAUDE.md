# +1 Frog Hop – notes for Claude

- Roblox game synced with Rojo (`default.project.json`, port 34873). The user runs `rojo serve` locally from `C:\1FrogHop`; this cloud session cannot reach their machine, so changes reach Studio via git push → user pulls.
- Balance numbers only in `src/shared/Config/`. Reward maths only in `src/server/Stats.luau`.
- Server-authoritative: the client never decides rewards. Remotes are declared in `src/shared/Net.luau`.
- Before committing: `cd tools/luau-check && npm install && npm run check` (must print 0 diagnostics).
- Keep the Obsidian vault in `docs/` updated: add a devlog note per session, tick items in `docs/Roadmap.md`.
