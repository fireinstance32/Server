---
tags: [lift-a-sword, devlog]
---
# Lift a Sword: 2026-10-14

Back to [[Lift a Sword]].

- **Style:** Stylised+ is the look for everything: a clean toon base with bold painted details (`STYLE = "toon+"` in `sword_textures.py`). Metal scratches were dropped because they read as white cracks.
- **Swords:** all 15 were polished and re-exported. The Stone Sword guard became one rock with ropes that look tied. The Steel Greatsword got a solid ricasso and proper hooks. You imported them, and they're swapped into `ReplicatedStorage.Swords` and every zone.
- **Pedestals:** the Wooden stump got bark ridges. All 16 are exported in Stylised+ and waiting to be re-imported.
- **Signs:** after two tries (a framed board looked like a screen and was "out of place"), they're real hanging wooden signs. Planks hang on chains from a beam, the posts take each zone's material, and a gem lamp sits on each post. All 16 are exported; `build_zone_sign.py`, plank grain is the `"plank"` texture kind.
- **Zone 16 = Void / Shadow:** added in Studio by copying zone 15. It has a dark floor and neon mat, the banks are extended, the portal moved to z = −1870, and it shows 💪 10Qi. Built so far:
  - VoidSword: a rift blade, a claw guard with an eye, and a black-hole pommel. Three orbiting shards are their own `Orbit` mesh.
  - VoidSwordPedestal: rock chunks float around it as a `Float` mesh.
  - VoidEgg.
- **Pets:** the style is a cube body, stubby legs, and the face as one decal texture. The red angry eyes were rejected. The chosen face mixes big sparkly eyes with a small smile and blush, and dark pets get a version with a white rim. The 84-pet roster is approved ([[Pets]]): 16 eggs, 1–12 hold 5 and 13–16 hold 6. There are 12 different faces.
- **Saved for later:** always-on animation (levitating rocks and eggs, animated swords and pets) and big VFX, not yet.
- **Placed:** all 16 hanging signs (the 💪 text stays on `SignFace`), plus zone 16's Void sword, pedestal and sign. The Void sword master is in `ReplicatedStorage.Swords`, and the Void egg is on stand 16.
- **Zone 16 decor** comes from the asset pack, not new models. The NatureLibrary rocks, bones and dead trees are plain MeshParts that tint well, so I recoloured zone 13's layout to void purple and added neon void pools, purple crystals and 14 levitating rocks (tag `Levitate`).
- **Eggs, all Stylised+:** all 16 are re-exported in the new look (the old realistic ones are backed up). Waiting on re-import: ![[LS Eggs Stylised+.png]]
- **Pets started:** the Wooden egg's five are built and exported. A new pet builder (`build_pets.py` plus `pets/`) makes a cube body with stubby legs and adds the parts that make each animal. The face is one quad carrying the face PNG, from 12 faces (each with a dark-pet version). Tails and wings are separate meshes for animating later. ![[LS Pets Wooden Egg.png]]
- **Open questions** for you are in [[Lift a Sword Decisions]] (pet look sign-off, face transparency in Studio, pet size).
