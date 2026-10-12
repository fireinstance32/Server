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
- `Leaderstats.luau` – the Roblox player-list stats.
- `Services/`
  - `WorldBuilder/` – generates the greybox map from config (skipped if `Workspace.World` exists)
    - `init` (entry) · `Parts` (block/sign helpers, palette) · `Environment` (lighting, per-zone biome banks, river water) · `Props` (trees, palms, rocks, reeds, flowers, mushrooms) · `River` (pads, zone arches, portal) · `Plaza` (Hop Zone strip, spawn) · `PondRow` (training ponds) · `FrogPodiums` (frog pedestals) · `Stands` (egg stands, frog shop)
  - `DataService` – DataStore load/save, leaderstats, `DataChanged` snapshots.
  - `HopService` – Train/Launch; server-authoritative; validates position + cooldown.
  - `HeldFrogService` – equipped frog in every character's right hand; hidden while it hops.
  - `ProgressionService` – XP/levels, rebirths, codes.
  - `ShopService` – buy/equip frogs.
  - `PetService` – hatch (uses luck), equip, pet models in `Workspace.Pets.<UserId>`.
  - `MonetizationService` – receipts, pass purchases.
  - `DevService` – Studio-only test commands (see [[Testing Guide]]).

## Shared (`src/shared`)
- `Config/` – all balance numbers: `Game`, `Frogs`, `Pets`, `Zones`, `Levels`, `Ponds`, `Codes`, `Monetization`, `Sounds`, `Dev`.
- `Util/` – `Format` (number text), `Models` (placeholder models), `Multipliers` (pure boost maths).
- `Net.luau` – every remote, declared once.

## Client (`src/client`)
- `State` – latest snapshot + `observe()`.
- `UI/Theme` – colours, fonts, `new()` helper, chunky buttons.
- `Purchases` – prompts passes/products by config name; `owns(pass)` from the snapshot.
- `PondAccess` – which ponds this player can use (signs, HOP button, auto-train).
- `UI/Components/` – reusable pieces: `Gradient` (presets), `RobuxChip`, `Badge`, `IconTile`, `PassCard`.
- `UI/Hud/` – `init` (layout + HOP button) · `StatRow` · `MultiplierInfo` · `LevelBar` · `PackRow` · `BottomLeft` · `IconGrid` · `PassColumn` · `TopBar` (Auto Hop) · `DistanceMeter` · `AutoRebirth` · `AutoTrain` · `Popups`
- `UI/Menus/` – `init` (open/close by name) · `Window` (panel, list, grid, card, button) · `Shop/` (`PackSection`, `PassSection`, `HopsSection`, `CodesSection`) · `RebirthMenu` · `Inventory/` (`FrogsTab`, `PetsTab`) · `ComingSoonMenu`
- `Controllers/`
  - `HopController` – spot detection (pond pad / Hop Zone), server call, auto-train and Auto Hop
  - `HopAnimation` – frog hop visuals, splashes, camera, landing banner
  - `TossAnimation` – face the river, wind-up and swing, release point
  - `FollowCamera` – smooth chase camera during a hop
  - `NotifyController` – level-up banners, dev messages, sound hook
  - `PetFollowController` – moves pets behind owners locally
  - `PromptController` – egg stands and shop prompts
  - `FrogPodiums` – per-player podium signs + Buy/Equip prompt text
  - `PondSigns` – per-player pond signs (requirement, LOCKED/UNLOCKED, multiplier)

## Rules
- Server decides every reward; the client only animates.
- Remotes are declared once in `src/shared/Net.luau`.
- Balance numbers only in `src/shared/Config/`.
- **One job per file.** When a module grows past ~200 lines or does two things, split it into a folder (`Name/init.luau` + parts).

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
| Rebirths | hops | mult `1 + rebirths` |
| Pets | hops | mult `1 + Σ(pet − 1)` |
| 2x Hops pass | hops | mult 2 |
| Level | hops | add `0.02 × (level − 1)` |
| Pond (training only) | hops | mult = pond multiplier |
| 2x Wins pass | wins | mult 2 |
