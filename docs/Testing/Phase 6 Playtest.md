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

## 6.1 Pets (parts + decals)
- [ ] `/petgallery` → every pet in rows next to spawn, name + animal under each; run again to remove
- [ ] Before uploading images: pets have part-built faces (square eyes, snouts)
- [ ] After filling ids in `Config/PetFaces.luau`: faces are decals (big glossy eyes, muzzles, whiskers), dogs have spots + eye patch, cats stripes, panda eye patches
- [ ] Every animal is recognisable; note any that aren't (name + screenshot)
- [ ] Legendary/Rainbow pets sparkle; equipped pets follow you and face forward
- [ ] Hatch screen shows the new pets

## 6.1 Models (Blender frog/egg)
- [ ] `ReplicatedStorage.Assets` has `Frog`, `Pet`, `Egg`
- [ ] Frog podiums show cube frogs in each frog's colour (belly lighter, feet darker, white eyes)
- [ ] The frog in your hand is the cube frog and faces forward; it hides while hopping
- [ ] Hopping frog faces down the river (+X), not sideways or backwards
- [ ] Equipped pets are cube pets in their colours, facing the way they walk, name tag above
- [ ] Egg stands and the hatch screen show the spotted egg in each egg's colour
- [ ] Removing `Assets.Frog` brings the old part frog back (fallback works)
- [ ] Note anything that looks off (size, facing, colours) with a screenshot
