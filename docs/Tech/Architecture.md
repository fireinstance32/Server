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
- `Remotes.luau` – `Remotes.handle(name, fn)`: every RemoteFunction goes through per-player rate limits (`Config/Security`) and pcall isolation.
- `Rewards.luau` – grants `{ kind, id, amount }` rewards (potion, pet, frog, wins, hops); shared by daily, gifts, quests.
- `Services/`
  - `WorldBuilder/` – builds each world at local coordinates, then moves it by `Worlds.offset(world)`. Scenery goes in `Workspace.Map.<WorldId>` (`buildMap`; saved with the place, only built if missing, so it can be edited in Studio); interactive parts go in `Workspace.World.<WorldId>` (`buildWorld`; rebuilt every start). Lobby layout: `Config/Lobby`.
    - `init` (entry) · `Parts` (block/sign helpers, palette) · `Environment` (lighting, per-zone biome banks, river water) · `Props` (trees, palms, rocks, reeds, flowers, mushrooms) · `River` (pads, zone arches) · `Plaza` (Hop Zone strip, spawn / landing pad) · `PondRow` (training ponds) · `FrogPodiums` (frog pedestals) · `Stands` (egg stands) · `Portals` (one portal per other world) · `Leaderboards` (board stands)
  - `WorldService` – `TravelWorld`: unlocks a world once you hold its Hops gate, teleports to its hub.
  - `DataService/` – `init` (profiles, `Changed`/`Loaded`, autosave) · `Template` (new profile, upgrades) · `Snapshot` (client view) · `Store` (DataStore + session locking)
  - `HopService` – Train/Launch; server-authoritative; validates position + cooldown.
  - `HeldFrogService` – equipped frog in every character's right hand; hidden while it hops.
  - `ProgressionService` – XP/levels, rebirths, codes.
  - `ShopService` – buy/equip frogs.
  - `TrailService` – buy/equip trails; Robux trail grants.
  - `PotionService` – potion inventory, use (stacking time), expiry loop.
  - `DailyService` – 7-day calendar claims.
  - `OfflineService` – welcome-back offline training grant (on `DataService.Loaded`).
  - `FriendService` – "FriendBoost" attribute from friends in the server.
  - `GiftService` – playtime gifts ("SessionStart" / "GiftsClaimed" attributes).
  - `QuestService` – tutorial quest chain: pays rewards and advances on data changes.
  - `PetService/` – `init` (equip, Equip Best, pet models in `Workspace.Pets.<UserId>`) · `Hatching` (1/3/8 hatch, luck, discovered, Robux eggs) · `Management` (delete, lock, auto delete)
  - `MonetizationService/` – `init` (idempotent receipts, pass purchases, `/buy` simulation) · `Handlers` (each product's effect) · `Stock` (limited stock across servers) · `Gifting` ([GIFT] products, gifted passes, pending gifts)
  - `LeaderboardService` – time played, OrderedDataStore writes/reads, fills the hub boards.
  - `AnalyticsTracker` – onboarding funnel (`Config/Funnel`) + Wins sink events.
  - `EventService` – active seasonal event, event currency, event egg stand + props.
  - `SettingsService` – `SetSetting`: saves the player's settings (`Config/Settings`: toggles and 0–100 sliders).
  - `TitleService` – unlocks titles (`Config/Titles`) as milestones are reached, `EquipTitle`, name tag above the head; the boost is in `Stats`.
  - `DevService/` – `init` (chat plumbing, permissions) · `Commands` (Studio-only test commands, see [[Testing Guide]]).

## Shared (`src/shared`)
- `Config/` – all balance numbers: `Game`, `Worlds`, `WorldContent/` (one file per world 2–5: frogs, pets, eggs, zones), `Frogs`, `Pets`, `Zones`, `Levels`, `Ponds`, `Trails`, `Potions`, `DailyRewards`, `Gifts`, `Quests`, `Codes`, `Monetization`, `Sounds`, `Dev`, `Security`, `Leaderboards`, `Events`, `Funnel`, `PetLooks` (animal per pet + features per animal), `PetFaces` (decal image ids + patterns).
- `Config/` also: `UiImages` (UI image ids + emoji fallbacks), `IconAtlas` / `PetIconAtlas` / `FrogIconAtlas` (generated sheet layouts), `Worlds.Themes` (plaza/pad colours, lighting per world).
- `Util/` – `Format` (number text), `Models/` (`init` picks imported meshes or part-built models; `Assets` clones/recolours `ReplicatedStorage.Assets`; `Pet/` part-built cube pets: `Builder`, `Features/` (`Face`, `Head`, `Body`) + face/pattern decals; `Placeholders` frog/egg), `Multipliers` (pure boost maths), `Hatch` (pure egg odds/picks), `RateLimit` (token bucket), `SessionLock` (save locking rules).
- `Net.luau` – every remote, declared once.

## Client (`src/client`)
- `State` – latest snapshot + `observe()`.
- `UI/Theme` – colours, fonts, `new()` helper, chunky buttons.
- `Purchases` – prompts passes/products/gifts by config name; `owns(pass)`, `stock(product)`.
- `Settings` – the local player's settings from the snapshot (`get(id)`).
- `Sfx` – plays named sounds from `Config/Sounds` (silent until ids are filled in).
- `Effects/` – `World` (splashes, landing burst, sparkles), `Screen` (confetti, flashes), `Ultimate/` (`init` aura + beam, `CutIn`).
- `PondAccess` – which ponds this player can use (signs, HOP button, auto-train).
- `UI/Components/` – reusable pieces: `Gradient` (presets), `RobuxChip`, `Badge`, `IconTile`, `PassCard`, `Icon` (icon sheet or emoji), `Studs` (panel texture), `CountUp` (rolling numbers), `ModelView` (ViewportFrame), `PetImage` (pet/frog picture or 3D), `RewardIcon`, `Rays` (spinning sunburst), `Slider` (0–100 with studded knob).
- `UI/Hud/` – `init` (layout + HOP button) · `StatRow` · `MultiplierInfo` · `LevelBar` · `PackRow` · `BottomLeft` · `IconGrid` · `PassColumn` · `TopBar` (Auto Hop) · `DistanceMeter` · `PotionTimers` · `TopRight` (Daily button) · `QuestBar` · `TipTicker` · `EventBanner` · `AutoRebirth` · `AutoTrain` · `Popups`
- `UI/HatchScreen` – full-screen hatch sequence (blur, eggs, wobble, reveal cards).
- `UI/Menus/` – `init` (open/close by name; `show` never toggles) · `Window/` (`init`: window chrome on its own ScreenGui, pop in/out, `setTitle`; `Layout`: list, grid, card, inset panel, studded `button`/`priceButton`, `recolor`) · `Shop/` (`PackSection`, `PassSection`, `HopsSection`, `GiftPicker`, `CodesSection`) · `RebirthMenu` · `TrailsMenu` · `DailyMenu` · `GiftsMenu` · `SettingsMenu` · `WorldsMenu/` (`Scene`) · `Inventory/` (side tabs; `FrogsTab`, `PetsTab/` (`PetTile`, `Details`, `Toolbar`, `Index`), `BoostsTab`, `TitlesTab`)
- `UI/Hud/Visibility` – show/hide HUD parts without fighting the menu (the centre HUD hides while a window is open).
- Menus re-render only when what they show changes: `Shared/Util/Signature` (`of` / `guard`).
- `Controllers/`
  - `HopController` – spot detection (pond pad / Hop Zone), server call, auto-train and Auto Hop
  - `HopAnimation` – frog hop visuals, splashes, camera, landing banner
  - `TossAnimation` – face the river, wind-up and swing, release point
  - `FollowCamera` – smooth chase camera during a hop
  - `NotifyController` – level-up banners, dev messages, sound hook
  - `PetFollowController` – moves pets behind owners locally
  - `PromptController` – world prompts (egg stands, frog podiums)
  - `EggController` – E/R/T hatching, auto-hatch, Robux egg reveals
  - `EggSigns/` – `init` (shows the odds panel near an egg) · `Sign` (name + price, odds panel with pet pictures and E/R/T keys)
  - `WorldLighting` – fades lighting to the current world's theme
  - `FrogPodiums` – per-player podium signs + Buy/Equip prompt text
  - `QuestGuide` – gold beam to the current quest target
  - `PondSigns` – per-player pond signs (requirement, LOCKED/UNLOCKED, multiplier)

## Worlds
World positions are converted with `Worlds.toLocal(position) → (world, localPos)`; all layout helpers (`Game.padPosition`, `Ponds.at`, `Frogs.podiumPosition`, egg positions) stay in World 1 coordinates. Hop results carry `world`, and the client adds `Worlds.offset(world)` when animating. Adding a world = a `Worlds.List` entry + `Config/WorldContent/<World>.luau` + a line in `WorldContent/init.luau`.

## Previewing without Studio
- `tools/ui-preview` runs the real UI code under a Roblox stub and screenshots it (`node run.mjs hud`, `menu:Shop`, `hatch`, `signs`, `overlays`, `ultimate`).
- `tools/luau-check/dump-pets.mjs` + `tools/blender/preview/render_pets.py` render the part-built pets/frogs (grid or one picture each, for the UI sheets).

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
| Rebirths | hops | add `rebirths` |
| Pets | hops | add `Σ pet bonus` |
| 2x Hops pass | hops | mult 2 |
| Level | hops | add `0.02 × (level − 1)` |
| Pond (training only) | hops | mult = pond multiplier |
| Trail | hops | add trail bonus |
| Potions | hops / wins / luck | mult x2 while active |
| Friend Boost | hops | add 0.1 per friend (max 0.5) |
| 2x Wins pass | wins | mult 2 |
