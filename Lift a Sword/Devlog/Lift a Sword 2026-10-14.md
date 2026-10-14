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
- **Pet fixes** (your feedback): the patches are kept inside the flat front, the owl has a rounded beak and soft tufts and tail feathers, and the hedgehog's quills are soft and lie back. All 5 are re-exported.
- **Pets, quality pass** (after your references: everything except the eyes needed to be better). All 5 Wooden pets are re-exported.
  - **Shapes:** rounder corners, thick leaf-shaped ears with inner ears and coloured tips, smooth tails (the radius used to step, which made rings), feather tufts for the owl, and branching antlers with rounded tips.
  - **Fur markings** are painted into the texture (`pets/marks.py`): the squirrel's back stripes, the fox's socks and white chest, the deer's spots, and pale bellies.
  - **Faces:** the eyes are unchanged. The muzzles are raised shapes per animal: puffy squirrel cheeks, white fox cheeks, an owl face disc, a deer snout. Noses are glossy, mouths have a shaded inside and a tongue, and teeth and beak are shaded.
  - **Outline:** a dark outline shell, `<Pet>_Outline`. Its CastShadow must be off in Studio.
  ![[LS Pets Wooden Egg.png]]
- **Pet look approved** ("that looks good as it is"), owl wings stay folded. Rolling it out egg by egg.
- **Stone egg pets built and exported:** Mole, RockTurtle, Badger, GolemPup, MossBear. New add-ons are in `pets/props.py` (moss cap, turtle shell, claws, crystals, sprouts, toadstool). New face options: whiskers, a badger stripe, a pink mole nose, and turtle nostrils. The GolemPup's crystals are Neon. ![[LS Pets Stone Egg.png]]
- **Bronze egg pets built and exported** (BronzeEgg): Beaver (buck teeth, scaly paddle tail), ClockworkMouse (wind-up key, side gear, curly tail), GearBug (bronze wing cases, gear on its back, antennae), SteamPig (sunglasses, steam pipe), BronzeBull (bronze body, horns, nose ring, gear studs). ![[LS Pets Bronze Egg.png]]
- **Iron egg pets built and exported** (IronEgg): Raccoon (eye mask, ringed tail), Armadillo (overlapping riveted steel bands), KnightDog (steel helmet with a red crest, blue cape), IronRhino (big horn out of the snout, riveted saddle plate), EmberWolf (glowing ember ears, flame crest and tail tip). ![[LS Pets Iron Egg.png]]
- **Steel egg pets built and exported** (SteelEgg): Penguin (white tummy, beak, folded flippers), ShieldCrab (steel shield shell, pincers, eye stalks), RoboCat (steel body, glowing cyan ears and antenna bulb, bolts, banded tail), SteelRam (wool cap, curled steel horns), MechLion (spiky steel mane, sunglasses). ![[LS Pets Steel Egg.png]]
- **Golden egg pets built and exported** (GoldenEgg): Hamster (puffy cheeks, buck teeth, a stashed gold coin), GoldPig (gold piggy bank with a coin slot, sunglasses), Peacock (feather fan with eye spots, head crest), KingFrog (gold crown with rubies, eye bumps, webbed feet), RoyalLion (mane, crown, red cape). ![[LS Pets Golden Egg.png]]
- **Ice egg pets built and exported** (IceEgg): SnowBunny (long ears, buck teeth, knitted scarf), Seal (whiskers, side flippers and tail flippers), PolarBear (snow cap with icicles, red scarf), FrostFox (ice-blue ear tips and tail, glowing ice crystals), Yeti (fluffy white fur, ice horns). New eye types are allowed if they match the current quality (the user, 2026-10-14). ![[LS Pets Ice Egg.png]]
- **Emerald egg pets built and exported** (EmeraldEgg): Frog (eye bumps, lily pad hat with a flower, webbed feet), Gecko (turquoise with orange spots, long tail, sticky toe pads), JadeTurtle (jade gem shell), LeafDragon (horns, leaf-green bat wings, back fins, spade tail), EmeraldStag (antlers, glowing emerald crystals, pale spots). ![[LS Pets Emerald Egg.png]]
- **Lava egg pets built and exported** (LavaEgg): FireSalamander (black spots, flame crest, flame-tipped tail), AshBat (ash speckles, glowing ear insides, bat wings), MagmaSlime (glowing lava dripping off the top, crusted rocks), LavaHound (stone body, glowing lava shards, flame tail tip), Phoenix (spread wings, flame crest, flame-tipped tail feathers). ![[LS Pets Lava Egg.png]]
