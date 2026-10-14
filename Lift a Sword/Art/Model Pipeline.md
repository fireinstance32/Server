---
tags: [lift-a-sword, art, tech]
---
# Model Pipeline

How Lift a Sword models get from code to Studio. My taste rules are in [[3D Modelling Preferences]]; this note is the mechanics. Back to [[Lift a Sword]].

## Where things live
- Game files: `C:\LiftASword` (not a git repo yet, so I back a file up before rewriting it). Notes live here in the vault.
- Builders: `C:\LiftASword\tools\blender\*.py`. Exports: `C:\LiftASword\assets\models\<Category>\Shapes\<Name>.fbx`, textures in `<Category>\Textures`.
- Your references: `C:\LiftASword\refs` (copies in [[#References]]).

## Builders
| File | Builds |
|---|---|
| `build_swords.py` | 16 swords, plus the shared shape helpers (box, cylinder, ball, sweep, gem, blade, harden, merge, aim…) |
| `sword_textures.py` | procedural PBR recipes (steel, gold, wood, stone, ice, crystal, galaxy, lacquer…) baked to 1024 Color/Normal/Roughness/Metalness. `STYLE = "toon+"` (Stylised+, the look for everything) swaps them for `toon()`. Toon kinds include `plank` (grain along X, for sign boards) and `void` (zone 16: violet cracks and star specks) |
| `build_pedestals.py` | 16 themed pedestals: `rock()`, `slot()`, `collar()`/`shards()` |
| `build_eggs.py` | 16 zone eggs: `Egg` surface, `cap`, `strap`, `badge`, `crack`, `lathe`/`torus`, `flat`, shapes (SHIELD, STAR, GEAR, BOLT…) |
| `build_stand.py` | the octagonal egg stand (glowing `Accent` ring) |
| `build_signs.py` | sign sizes (board 2.4 × 1.5 units) and per-zone colours |
| `build_zone_sign.py` | the 16 hanging wooden signs in use: planks on chains from a beam, posts and caps in the zone's material, a gem lamp on each post |
| `build_landmarks.py` | World 2 portal and group chest. **Flat colours by default** (`--textured` to bake) |
| `build_props.py` | unused props; kept as a helper source (`drum`, `sector`) |
| `build_pets.py` | the 84 cube pets. Shapes are in `pets/shapes.py` (body, ears, tails, wings, antlers, spikes…), one roster file per egg is `pets/eggNN_*.py` (registered with `@pet` from `pets/registry.py`), and the face is a `<Pet>_Face` quad textured with a per-pet PNG from `pets/faces.py`. Fur markings are a `marks=[...]` list (`pets/marks.py`: `blob`, `below`, `above`), mixed into the colour before the bake. `<Pet>_Outline` is an inverted shell for the dark outline (`OUTLINE = False` turns it off). Run with `--egg WoodenEgg`, `--preview <png>`, `--back` (3/4 rear view), `--no-export`. The old chibi builder is `build_pets.py.bak-chibi` |
| `pets/faces.py` | plain Python + Pillow: `python tools/blender/pets/faces.py assets/models/Pets/Faces` is run by `build_pets.py`, which writes `Faces/_spec.json` from the registry and gets one `Face_<Pet>.png` per pet (the old shared faces are `faces_v1.py`) |

Each builder works the same way: register a model with its role colours, kinds (texture recipe) and glow roles, then `build()` hardens the normals, bakes (if textured) and `B.export` writes the FBX plus `colors.json`.

## Running Blender
- Headless:
  ```bash
  "/c/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b -P tools/blender/<builder>.py -- assets/models/<Category> [--only A,B] [--preview x.png] [--reuse-textures]
  ```
- Live Blender MCP for quick looks. `B._fresh()` needs a window, so pass `scene=` when headless.
- Always render a preview PNG and show it to you before exporting.

## Conventions
- Meshes are named `<Model>_<Role>`, one material per role. Glow roles stay flat and become **Neon** with the role colour in Studio.
- Base at z=0, front is −Y in Blender. The pivot is the Blender origin.
- Lids and other moving parts get roles starting with `Lid…` (or similar) so code can find them.
- Keep each mesh under 20k triangles (check with a quick FBX reimport count).

## Into Studio
1. You import the FBX (3D Importer). It arrives at **100 studs per Blender unit**, nested Model > Model > MeshParts, with SurfaceAppearances if textured.
2. I flatten it into one Model, `ScaleTo(studsPerUnit / 100)`, set the glow roles to Neon, anchor it, turn CanCollide off on small parts, and place it.
3. Blender −Y (front) becomes −Z in Roblox model space. To face +X use yaw −90°.
4. Flat-colour imports: set each role's Color from `colors.json`; SmoothPlastic for normal roles, Neon for glow.

| Model | Studs per Blender unit |
|---|---|
| Swords | 3.43 |
| Pedestals, signs | 3.9 |
| Eggs + stands | 2.3 |
| Portal | ~11 (fills the 24 × 30 opening) |
| Group chest | ~8 (chest ≈ 19 studs wide) |

## References
![[LS Ref Portal.jpg]]
![[LS Ref Group Chest Angle.jpg]]
![[LS Ref Group Chest Front.jpg]]
![[LS Ref Group Chest Side.jpg]]
