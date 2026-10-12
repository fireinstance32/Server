---
tags: [tech]
---
# Architecture

Rojo maps:
| Folder | Studio location |
|---|---|
| `src/shared` | ReplicatedStorage.Shared |
| `src/server` | ServerScriptService.Server (Script) |
| `src/client` | StarterPlayerScripts.Client (LocalScript) |

## Server (`src/server`)
- `init.server.luau` – requires services in order, calls `init()` then `start()`.
- `Stats.luau` – every boost in one `MODIFIERS` list (see [[#Multipliers]]); the only place reward maths lives.
- `Passes.luau` – game-pass ownership cache.
- `Services/`
  - `WorldBuilder` – generates the greybox map from config (skipped if `Workspace.World` exists).
  - `DataService` – DataStore load/save, leaderstats, `DataChanged` snapshots.
  - `HopService` – Train/Launch; server-authoritative; validates position + cooldown.
  - `ShopService` – buy/equip frogs.
  - `PetService` – hatch, equip, pet models in `Workspace.Pets.<UserId>`.
  - `ProgressionService` – rebirths, codes.
  - `MonetizationService` – receipts, pass purchases.

## Client (`src/client`)
- `State` – latest snapshot + `observe()`.
- `UI/Theme` – colours, fonts, `new()` helper, chunky buttons.
- `UI/Hud` – stats, HOP button, side menu, toasts, banners.
- `UI/Menus` – Frog Shop, Pets, Rebirth, Codes windows.
- `Controllers/HopController` – mode detection, server call, hop animation + camera.
- `Controllers/PetFollowController` – moves pets behind owners locally.
- `Controllers/PromptController` – egg stands and shop prompts.

## Rules
- Server decides every reward; the client only animates.
- Remotes are declared once in `src/shared/Net.luau`.
- Balance numbers only in `src/shared/Config/`.

## Multipliers
`total = (1 + sum of "add" parts) × product of "mult" parts`, computed by the pure module `src/shared/Util/Multipliers.luau` (unit-tested in `tools/luau-check/tests`).

Stats: `hops`, `wins`, `luck`. To add a boost, add one entry to `MODIFIERS` in `src/server/Stats.luau`:
```lua
{ id = "pond", label = "Pond", stat = "hops", kind = "mult", value = function(player, data, context)
	return Ponds.multiplierFor(context.pond) -- nil = doesn't apply
end },
```
`context` carries the situation (`{ mode = "Train" }`, `{ mode = "Launch", zone = 3 }`). The client receives `snapshot.multipliers.<stat> = { total, parts }` for breakdown UI.

| Source | Stat | Kind |
|---|---|---|
| Rebirths | hops | mult `1 + 0.5 × rebirths` |
| Pets | hops | mult `1 + Σ(pet − 1)` |
| 2x Hops pass | hops | mult 2 |
| 2x Wins pass | wins | mult 2 |
