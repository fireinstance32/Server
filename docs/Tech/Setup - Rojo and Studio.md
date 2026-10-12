---
tags: [tech]
---
# Setup – Rojo and Studio

1. Clone the repo into `C:\1FrogHop`.
2. Install [Rokit](https://github.com/rojo-rbx/rokit), then in `C:\1FrogHop` run `rokit install` (installs Rojo, Selene, StyLua from `rokit.toml`).
3. Install the **Rojo** Studio plugin (Studio → Plugins, or `rojo plugin install`).
4. `rojo serve` — the port **34873** comes from `default.project.json`.
5. In Studio: open a new Baseplate → Rojo plugin → host `localhost`, port `34873` → **Connect**.
6. Game Settings → Security → **Enable Studio Access to API Services** (for DataStores).
7. Press Play.

Offline checks (no Studio needed): `cd tools/luau-check && npm install && npm run check` (compile + lint + unit tests).

## Auto-pull with Obsidian Git
The vault is the repo, so the **Obsidian Git** plugin keeps notes *and* code up to date (Rojo then syncs the code into Studio).
1. Settings → Community plugins → Turn on → Browse → **Git** (by Vinzent) → Install → Enable.
2. Plugin settings:
   - **Auto pull interval (minutes):** `1`
   - **Pull on startup:** on
   - **Auto commit-and-sync interval:** `0` (off – only Claude pushes)
   - **Push on commit-and-sync:** off
3. Command palette → "Git: Pull" to pull on demand.

See [[Architecture]] for where code lives.
