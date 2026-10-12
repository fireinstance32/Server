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

Offline checks (no Studio needed): `cd tools/luau-check && npm install && npm run check`.

See [[Architecture]] for where code lives.
