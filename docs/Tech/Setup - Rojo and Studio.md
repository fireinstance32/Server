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

## Two-way sync with Obsidian Git (no more stash/pull)
The vault is the repo. Obsidian Git now **commits your note edits and pushes them**, and **pulls Claude's changes** every minute, so nothing gets stuck. Rojo then syncs the pulled code into Studio.

### One-time setup (PowerShell, in `C:\1FrogHop`)
```powershell
git config user.name "Ben Lewis"
git config user.email "fireinstance32@gmail.com"
git config pull.rebase true
git config rebase.autoStash true
```
`pull.rebase` + `rebase.autoStash` mean a plain `git pull` never refuses because of local edits; they're set aside and put back automatically.

### Obsidian Git settings
| Setting | Value |
|---|---|
| Sync method | **Rebase** |
| Auto commit-and-sync interval (minutes) | **1** |
| Auto pull interval (minutes) | **1** |
| Pull on startup | **On** |
| Push on commit-and-sync | **On** |
| Pull before push | **On** |
| Commit message | `vault: {{date}}` |

Also turn off **Settings → Files and links → Automatically update internal links**. Obsidian rewriting links on its own is what caused the stuck pulls.

### If it ever gets stuck
Command palette → **Git: Pull**. If it reports a conflict, tell Claude which note; Claude merges it.
