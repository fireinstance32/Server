---
tags: [testing, phase6]
status: in progress
---
# Phase 6 Playtest

> Grows as Phase 6 is built. Setup: [[Testing Guide]]; import the models first ([[Art Pipeline]] → Importing).

## 6.2 Effects
- [ ] Training on a pond: small droplet splash on each pad
- [ ] River hop: splash on every pad; at the landing, big ripples + golden sparkle fountain + mist
- [ ] Zone change mid-hop: quick colour flash with the zone toast
- [ ] NEW BEST: confetti rains down; level up: sparkles around you; MAX LEVEL: confetti
- [ ] Hatching an Epic/Legendary pet: flash + confetti on the reveal
- [ ] No lag spikes from effects (watch FPS during a long hop)

## 6.3 Ultimate hop
- [ ] `/frogs`, equip Phoenix Frog (or a King), river hop: cut-in (speed lines + black frog silhouette + "ULTIMATE HOP!") for ~1 s, fire aura on you, beam + explosion where you throw
- [ ] Normal frogs don't play it; hop rewards arrive at the same time as before

## 6.5 World look
- [ ] Each hub's plaza has its own colours with a checker pattern; river pads match the world
- [ ] `/world swamp` → lighting fades to purple dusk; candy → bright pink; space → night; lava → red haze; back to lily → normal day

## 6.1 Pets (parts + decals)
- [ ] `/petgallery` → every pet in rows next to spawn, name + animal under each; run again to remove
- [ ] Before uploading images: pets have part-built faces (square eyes, snouts)
- [ ] After filling ids in `Config/PetFaces.luau`: faces are decals (big glossy eyes, muzzles, whiskers), dogs have spots + eye patch, cats stripes, panda eye patches
- [ ] Every animal is recognisable; note any that aren't (name + screenshot)
- [ ] Legendary/Rainbow pets sparkle; equipped pets follow you and face forward
- [ ] Hatch screen shows the new pets

## 6.1 Rocks (Blender)
- [ ] `ReplicatedStorage.Assets.Rocks` holds `Rock`, `RockPebble` … `RockPhoenix` and `Crown` (or each one straight in `Assets`)
- [ ] Rock podiums: every rock has its own shape (Pebble flat and smooth, Mossy with a moss cap, Gold Nugget bubbly, Gummy Rock a gummy bear, Rock Candy on a stick, Cupcake Rock frosted with a cherry, Mushroom Rock with spotted mushrooms…) in the rock's colour
- [ ] Glowing parts are Neon: lava seams, rune lines, toxic ooze, comet tail, galaxy ring, phoenix feathers
- [ ] The four Kings wear a gold crown on top
- [ ] The rock in your hand: right size, sits in the palm, no invisible-part gaps; thrown rock tumbles and hides/returns as before
- [ ] Rocks tab and Daily Day 7 show rock pictures (not frogs)
- [ ] Removing `Assets.Rocks` brings back the part-built rocks (fallback works)
- [ ] Stone Valley podiums go Pebble → Stone → Coal → Copper → Iron → Silver → Gold → Emerald → Ruby → Diamond (ore nuggets, then veins, then gems, then a diamond cluster); Pebble is a smooth lopsided pebble with a light vein
- [ ] Reward rocks are not on podiums; codes MOSSY / SLIME / ROYAL give Mossy Stone / Toxic Rock / Royal Gem; tooltip says "Only from …"

## 6.1 Lift + rock effects
- [ ] Train in a gym: each rep squats with the rock at the shoulder, drives it overhead (arms straight), flexes the other arm, then relaxes; works on R15 and R6
- [ ] At the squat: dust at the feet, motes rush into the rock; at the top: flash, rings, sparks, stars, light pop, small camera punch. Stronger rocks = bigger. Not blinding with auto-lift
- [ ] Every rock (in hand and on podiums) has its aura: glints; lava embers, phoenix flames, toxic bubbles, rune wisps, gem twinkles…; comets orbit strong rocks, a halo on the strongest
- [ ] Settings → effects off removes the particles (the pose stays)
- [ ] Throw: wind-up and swing look right, rock leaves the hand

## 6.1 Props (Blender)
- [ ] `ReplicatedStorage.Assets.Props` holds LiftPlatform, Dumbbell, Kettlebell, Bench, BarbellRack, PlateTree, WeightPile, Podium, PortalArch, Trophy
- [ ] Each gym: lifting platform on the stand pad (frame in the gym colour), rack, bench, plate tree, dumbbells, kettlebell, weight pile; nothing blocks walking onto the pad; training still works on the platform
- [ ] Rock podiums are stone with gold trim and a glow ring in the rock's colour; the rock floats above; Buy prompt works
- [ ] Portals are stone arches with a glowing rune in the target world's colour; Travel prompt works; you can't walk through the pillars

## 6.1 Models (Blender frog/egg)
- [ ] `ReplicatedStorage.Assets` has `Frog`, `Pet`, `Egg`
- [ ] Frog podiums show cube frogs in each frog's colour (belly lighter, feet darker, white eyes)
- [ ] The frog in your hand is the cube frog and faces forward; it hides while hopping
- [ ] Hopping frog faces down the river (+X), not sideways or backwards
- [ ] Equipped pets are cube pets in their colours, facing the way they walk, name tag above
- [ ] Egg stands and the hatch screen show the spotted egg in each egg's colour
- [ ] Removing `Assets.Frog` brings the old part frog back (fallback works)
- [ ] Note anything that looks off (size, facing, colours) with a screenshot
