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
- `Stats.luau` – multipliers; the only place reward maths lives.
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
