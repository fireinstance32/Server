---
tags: [art, models]
---
# Models

Every 3D model in the game, built by Blender scripts in `tools/blender/` (never edited by hand: change the script and rebuild). Import steps: [[Art Pipeline]].

| Folder | What | Built by | In Studio |
|---|---|---|---|
| `Rocks/Rocks.fbx` | **All rock shapes in one file** (import this one) | `build_rocks.py` | `ReplicatedStorage.Assets.Rocks` |
| `Rocks/Shapes/` | The same shapes one file each (fallback import) | `build_rocks.py` | `ReplicatedStorage.Assets.<Shape>` |
| `Props/Props.fbx` | **All world props in one file** (gym, podium, portal, decor) | `build_props.py` | `ReplicatedStorage.Assets.Props` |
| `Props/Shapes/` | The same props one file each | `build_props.py` | `ReplicatedStorage.Assets.<Prop>` |
| `Pets/Pet.fbx` | Cube pet (recoloured per pet) | `build_models.py` | `ReplicatedStorage.Assets.Pet` |
| `Eggs/Egg.fbx` | Egg (recoloured per egg) | `build_models.py` | `ReplicatedStorage.Assets.Egg` |
| `Legacy/Frog.fbx` | The cube frog from before the Rock Pivot (unused) | `build_models.py` | – |

## Rock shapes
Which rock uses which shape: `src/shared/Config/RockLooks.luau`. Preview: [[Rocks Preview.png]]

- **Ore ladder (Stone Valley):** RockPebble (Pebble), Rock (Stone), RockOre (Coal, Copper, Iron), RockOreRich (Silver, Gold), RockGemOre (Emerald, Ruby), RockGemCluster (Diamond)
- **Uniques:** RockMossy, RockRiver, RockBoulder, RockNugget, RockToxic, RockRune, RockRoyal, RockMeteor, RockPhoenix
- **Swamp / Candy / Space / Lava:** RockMushroom, RockGummy, RockCandy, RockFrosted, RockMoon, RockComet, RockGalaxy, RockLava
- **Crown** (worn by the four Kings)

## Rebuild
```
blender -b -P tools/blender/build_rocks.py -- assets/models/Rocks --preview "docs/Art/Rocks Preview.png"
blender -b -P tools/blender/build_props.py -- assets/models/Props --preview "docs/Art/Props Preview.png"
python tools/blender/build_models.py assets/models
```
