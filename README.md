# +1 Frog Hop 🐸

A Roblox "+1" incremental game: press **HOP**, your frog leaps across lily pads, every pad is **+1 Hops**, and the farther it goes the more **Wins** you earn.

## Quick start (Windows)

```powershell
git clone https://github.com/fireinstance32/Server.git C:\1FrogHop
cd C:\1FrogHop
git checkout claude/focused-meitner-7df7ik
rokit install        # installs rojo, selene, stylua (see rokit.toml)
rojo serve           # serves on port 34873 (set in default.project.json)
```

In Roblox Studio: open a Baseplate → **Rojo** plugin → `localhost` : `34873` → **Connect** → Play.
Enable *Game Settings → Security → Studio Access to API Services* so progress saves.

## Layout

| Path | What |
|---|---|
| `src/shared` | Configs (balance), remotes, utilities → ReplicatedStorage.Shared |
| `src/server` | Services → ServerScriptService.Server |
| `src/client` | UI + controllers → StarterPlayerScripts.Client |
| `docs/` | Obsidian vault: design, research, architecture, roadmap, devlog |
| `tools/luau-check` | Offline Luau compile + lint (`npm install && npm run check`) |

Design and architecture details: open `docs/` as an Obsidian vault and start at **Home**.
